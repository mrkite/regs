/** @copyright 2020 Sean Kasun */

#include <dirent.h>
#include <stdarg.h>
#include <iostream>
#include <fstream>
#include <utility>

#include "parser.h"

void Parser::add(const char *token, Intrinsic value) {
  Token t;
  t.asStr = token;
  t.filename = "(intrinsic)";
  t.curLine = 0;
  Symbol *symbol = find(t);
  symbol->isKnown = true;
  symbol->definedLine = symbol->referencedLine;
  symbol->definedFile = symbol->referencedFile;
  symbol->kind = isIntrinsic;
  symbol->asIntrinsic = value;
}

bool Parser::run(std::string directory) {
  DIR *dir = opendir(directory.c_str());
  if (!dir) {
    std::cerr << "Couldn't open directory: " << directory << std::endl;
    return false;
  }
  struct dirent *file;
  while ((file = readdir(dir)) != nullptr) {
    if (file->d_name[0] == '.') {
      continue;
    }
    std::string filename = directory + "/" + file->d_name;
    if (!load(filename)) {
      closedir(dir);
      return false;
    }
  }
  closedir(dir);
  return true;
}

Symbol *Parser::find(const Token &t) {
  std::string key = t.asStr;
  if (symbols.count(key) == 0) {
    Symbol s;
    s.name = key;
    s.referencedLine = t.curLine;
    s.referencedFile = t.filename;
    symbols.insert(std::pair<std::string, Symbol>(key, s));
  }
  return &symbols[key];
}

bool Parser::load(std::string filename) {
  std::ifstream f(filename, std::ios::in | std::ios::binary | std::ios::ate);
  if (!f.is_open()) {
    return false;
  }
  std::streamoff len = f.tellg();
  char *data = new char[len + 1];
  f.seekg(0, std::ios::beg);
  f.read(data, len);
  f.close();

  data[len] = 0;

  File file;
  file.p = data;
  file.end = data + len;
  file.name = filename;
  file.curLine = 1;

  bool okay = parse(&file);
  delete [] data;
  return okay;
}

bool Parser::parse(File *file) {
  Token token;
  while ((token = file->token()).type != END) {
    switch (token.type) {
      case VAR:
        if (!addDefinition(token, file)) {
          return false;
        }
        break;
      default:
        error(file, "Expected a definition\n");
        return false;
    }
  }
  return true;
}

bool Parser::addDefinition(const Token &def, File *file) {
  Symbol *s = find(def);
  if (s->isKnown) {
    error(file, "Duplicate definition: '%s'\nDefined in '%s' on line %d\n",
          s->name.c_str(), s->definedFile.c_str(), s->definedLine);
    return false;
  }
  s->definedLine = def.curLine;
  s->definedFile = def.filename;
  s->isKnown = true;
  Token token = file->token();
  switch (token.type) {
    case ENUM:
      return parseEnum(s, file);
    case SYMBOL:
      switch (token.asSym) {
        case '(':
          return parseFunc(s, file);
        case '=':
          return parseAlias(s, file);
        default:
          error(file, "Expected '=' or '(', found '%c'\n", token.asSym);
          return false;
      }
    case STRUCT:
      s->kind = isStruct;
      s->asStruct = new Struct();
      return parseStruct(s->asStruct, file);
    case UNION:
      s->kind = isUnion;
      s->asStruct = new Struct();
      return parseStruct(s->asStruct, file);
    default:
      error(file, "Parser error.\n");
      return false;
  }
}

bool Parser::parseEnum(Symbol *s, File *f) {
  Enum *e = new Enum();
  s->kind = isEnum;
  s->asEnum = e;
  if (!f->token().expect('<')) {
    return false;
  }
  Token token = f->token();
  if (token.type != VAR) {
    error(f, "Expected a type name\n");
    return false;
  }
  e->type = find(token);
  if (!f->token().expect('>')) {
    return false;
  }
  if (!f->token().expect('{')) {
    return false;
  }
  int32_t prevVal = -1;
  while ((token = f->token()).type == VAR) {
    std::string key = token.asStr;
    token = f->token();
    if (token.type == SYMBOL && token.asSym == '=') {
      prevVal = f->token().asNum;
      token = f->token();
    } else {
      prevVal++;
    }
    e->entries.insert(std::pair<std::string, int32_t>(key, prevVal));
    if (!token.expect(",}")) {
      return false;
    }
    if (token.asSym == '}') {
      break;
    }
  }
  return token.expect('}');
}

bool Parser::parseFunc(Symbol *s, File *f) {
  Function *func = new Function();
  s->kind = isFunction;
  s->asFunction = func;

  Token token;
  while ((token = f->token()).type == VAR) {
    Argument arg;
    if (!parseArgument(&arg, token, f)) {
      return false;
    }
    func->arguments.push_back(arg);
    token = f->token();
    if (!token.expect(",)")) {
      return false;
    }
    if (token.asSym == ')') {
      break;
    }
  }
  if (!token.expect(')')) {
    return false;
  }
  token = f->token();
  if (!token.expect(":;{")) {
    return false;
  }
  func->retType.symbol = nullptr;
  if (token.asSym == ':') {
    if (!parseRef(&func->retType, f)) {
      return false;
    }
    token = f->token();
    if (!token.expect(";{")) {
      return false;
    }
  }
  if (token.asSym == '{') {
    while ((token = f->token()).type == NUMBER) {
      func->signature.push_back(token.asNum);
      token = f->token();
      if (!token.expect(",}")) {
        return false;
      }
      if (token.asSym == '}') {
        break;
      }
    }
    if (!token.expect('}')) {
      return false;
    }
  }
  return true;
}

bool Parser::parseAlias(Symbol *s, File *f) {
  Ref *ref = new Ref();
  s->asAlias = ref;
  s->kind = isAlias;
  if (!parseRef(ref, f)) {
    return false;
  }
  return f->token().expect(';');
}

bool Parser::parseStruct(Struct *s, File *f) {
  if (!f->token().expect('{')) {
    return false;
  }
  Token token;
  while ((token = f->token()).type == VAR || token.type == STRUCT ||
         token.type == UNION) {
    Field field;
    if (!parseField(&field, token, f)) {
      return false;
    }
    s->fields.push_back(field);
    token = f->token();
    if (!token.expect(";}")) {
      return false;
    }
    if (token.asSym == '}') {
      break;
    }
  }
  return token.expect('}');
}

bool Parser::parseArgument(Argument *arg, const Token &def, File *f) {
  arg->key = def.asStr;
  if (!f->token().expect(':')) {
    return false;
  }
  return parseRef(&arg->ref, f);
}

bool Parser::parseRef(Ref *ref, File *f) {
  ref->pointer = 0;
  ref->array = -1;

  Token token;
  while ((token = f->token()).type == SYMBOL && token.asSym == '^') {
    ref->pointer++;
  }
  if (token.type != VAR) {
    error(f, "Expected a type or a pointer.\n");
    return false;
  }
  ref->symbol = find(token);
  token = f->token();
  if (token.type == SYMBOL && token.asSym == '[') {
    ref->array = 0;  // empty bracket
    token = f->token();
    if (token.type == NUMBER) {
      ref->array = token.asNum;
      token = f->token();
    }
    if (!token.expect(']')) {
      return false;
    }
  } else {
    f->reset();
  }
  token = f->token();
  if (token.type == SYMBOL && token.asSym == '|') {
    token = f->token();
    if (token.type != VAR) {
      error(f, "Expected a register\n");
      return false;
    } else {
      ref->reg = token.asStr;
    }
  } else {
    f->reset();
  }
  return true;
}

bool Parser::parseField(Field *field, const Token &def, File *f) {
  if (def.type == STRUCT) {
    field->kind = isStruct;
    field->theStruct = new Struct();
    return parseStruct(field->theStruct, f);
  } else if (def.type == UNION) {
    field->kind = isUnion;
    field->theStruct = new Struct();
    return parseStruct(field->theStruct, f);
  } else {
    field->kind = isRef;
    field->key = def.asStr;
    if (!f->token().expect(':')) {
      return false;
    }
    field->ref = new Ref();
    return parseRef(field->ref, f);
  }
}

void Parser::error(File *f, const char *format, ...) {
  va_list args;
  va_start(args, format);

  fprintf(stderr, "Error: %s:%d: ", f->name.c_str(), f->curLine);
  vfprintf(stderr, format, args);

  va_end(args);
}
