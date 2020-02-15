/** @copyright 2020 Sean Kasun */
#include <stdarg.h>
#include <iostream>
#include "compiler.h"
#include "avl.h"

bool Compiler::run(std::map<std::string, Symbol> &symbols) {
  numErrors = 0;

  for (auto it = symbols.begin(); it != symbols.end(); it++) {
    if (!it->second.isKnown) {
      if (!refErr(&it->second, "Unknown type: '%s'\n",
                  it->second.name.c_str())) {
        return false;
      }
    } else if (!it->second.isSized) {
      calculateSizes(&it->second);
    }
  }
  AVL avl;

  // verify functions only passed 32-bits or smaller
  // also verify functions have unique signatures
  for (auto it = symbols.begin(); it != symbols.end(); it++) {
    if (it->second.kind == isFunction) {
      Function *f = it->second.asFunction;
      for (auto arg = f->arguments.begin(); arg != f->arguments.end(); arg++) {
        if (arg->ref.pointer == 0 &&
            (arg->ref.symbol->size > 4 || arg->ref.array == 0)) {
          if (!defErr(&it->second, "Argument too large: '%s'\n",
                      arg->key.c_str())) {
            return false;
          }
        }
      }
      if (f->retType.symbol != nullptr && f->retType.pointer == 0 &&
          (f->retType.symbol->size > 4 || f->retType.array >= 0)) {
        if (!defErr(&it->second, "Return value too large on '%s'\n",
                    it->second.name.c_str())) {
          return false;
        }
      }
      if (f->signature.size() > 0) {
        if (!avl.insert(f->signature)) {
          if (!defErr(&it->second, "Duplicate signature on '%s'\n",
                      it->second.name.c_str())) {
            return false;
          }
        }
      }
    }
  }
  return true;
}

bool Compiler::calculateSizes(Symbol *s) {
  s->isSizing = true;
  switch (s->kind) {
    case isFunction:
      s->size = 4;
      break;
    case isAlias:
    case isRef:
      s->size = calcRefSize(s->asAlias, s);
      break;
    case isStruct:
      s->size = calcStructSize(s->asStruct, s);
      if (s->size < 0) {
        return false;
      }
      break;
    case isUnion:
      s->size = calcUnionSize(s->asStruct, s);
      if (s->size < 0) {
        return false;
      }
      break;
    case isEnum:
      if (!s->asEnum->type->isKnown) {
        refErr(s->asEnum->type, "Unknown type: '%s'\n",
               s->asEnum->type->name.c_str());
        return false;
      }
      if (!s->asEnum->type->isSized) {
        if (s->asEnum->type->isSizing) {
          defErr(s, "Recurisve type found: '%s'\n", s->name.c_str());
          return false;
        }
        if (!calculateSizes(s->asEnum->type)) {
          return false;
        }
      }
      s->size = s->asEnum->type->size;
      break;
    case isIntrinsic:
      switch (s->asIntrinsic) {
        case U8:
        case S8:
          s->size = 1;
          break;
        case U16:
        case S16:
          s->size = 2;
          break;
        case U32:
        case S32:
          s->size = 4;
          break;
        default:
          defErr(s, "Unknown intrinsic\n");
          return false;
      }
      break;
    default:
      defErr(s, "Uknown symbol type\n");
      return false;
  }
  s->isSized = true;
  s->isSizing = false;
  return true;
}

int32_t Compiler::calcRefSize(Ref *ref, Symbol *parent) {
  if (!ref->symbol->isKnown) {
    refErr(ref->symbol, "Unknown type: %s'\n", ref->symbol->name.c_str());
    return -1;
  }
  // prevent recursion errors
  if (ref->pointer > 0) {
    return 4;
  }
  if (!ref->symbol->isSized) {
    if (ref->symbol->isSizing) {
      defErr(parent, "Recursive type found: '%s'\n", parent->name.c_str());
      return -1;
    }
    if (!calculateSizes(ref->symbol)) {
      return -1;
    }
  }
  int32_t size = ref->symbol->size;
  if (ref->array >= 0) {
    size *= ref->array;
  }
  return size;
}

int32_t Compiler::calcStructSize(Struct *s, Symbol *parent) {
  int32_t size = 0;
  for (auto it = s->fields.begin(); it != s->fields.end(); it++) {
    switch (it->kind) {
      case isRef:
        it->size = calcRefSize(it->ref, parent);
        break;
      case isStruct:
        it->size = calcStructSize(it->theStruct, parent);
        break;
      case isUnion:
        it->size = calcUnionSize(it->theStruct, parent);
        break;
      default:
        defErr(parent, "Unknown field type: '%s'\n", it->key.c_str());
        return -1;
    }
    if (it->size < 0) {
      return -1;
    }
    size += it->size;
  }
  return size;
}

int32_t Compiler::calcUnionSize(Struct *s, Symbol *parent) {
  int32_t size = 0;
  for (auto it = s->fields.begin(); it != s->fields.end(); it++) {
    switch (it->kind) {
      case isRef:
        it->size = calcRefSize(it->ref, parent);
        break;
      case isStruct:
        it->size = calcStructSize(it->theStruct, parent);
        break;
      case isUnion:
        it->size = calcUnionSize(it->theStruct, parent);
        break;
      default:
        defErr(parent, "Unknown field type: '%s'\n", it->key.c_str());
        return -1;
    }
    if (it->size < 0) {
      return -1;
    }
    if (it->size > size) {
      size = it->size;
    }
  }
  return size;
}

bool Compiler::refErr(Symbol *symbol, const char *format, ...) {
  va_list args;
  va_start(args, format);

  fprintf(stderr, "Error: %s:%d: ", symbol->referencedFile.c_str(),
          symbol->referencedLine);
  vfprintf(stderr, format, args);

  va_end(args);

  numErrors++;
  return numErrors < 10;
}

bool Compiler::defErr(Symbol *symbol, const char *format, ...) {
  va_list args;
  va_start(args, format);

  fprintf(stderr, "Error: %s:%d: ", symbol->definedFile.c_str(),
          symbol->definedLine);
  vfprintf(stderr, format, args);

  va_end(args);

  numErrors++;
  return numErrors < 10;
}
