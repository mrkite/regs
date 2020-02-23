/** @copyright 2020 Sean Kasun */
#pragma once
#include <map>
#include <string>

#include "types.h"
#include "file.h"

class Parser {
 public:
  void add(const char *token, Intrinsic value);
  bool run(std::string directory);
  std::map<std::string, Symbol> symbols;

 private:
  Symbol *find(const Token &t);
  bool load(std::string filename);
  bool parse(File *file);
  bool addDefinition(const Token &def, File *file);
  bool parseFunc(Symbol *s, File *f);
  bool parseEnum(Symbol *s, File *f);
  bool parseStruct(Struct *s, File *f);
  bool parseAlias(Symbol *s, File *f);
  bool parseField(Field *field, const Token &def, File *f);
  bool parseArgument(Argument *arg, const Token &def, File *f);
  bool parseRef(Ref *ref, File *f);
  void error(File *f, const char *format, ...);
};
