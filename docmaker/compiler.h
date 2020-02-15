/** @copyright 2020 Sean Kasun */
#pragma once

#include <map>
#include <string>
#include "types.h"

class Compiler {
 public:
  bool run(std::map<std::string, Symbol> &symbols);

 private:
  int numErrors;
  bool calculateSizes(Symbol *s);
  int32_t calcRefSize(Ref *ref, Symbol *parent);
  int32_t calcStructSize(Struct *s, Symbol *parent);
  int32_t calcUnionSize(Struct *s, Symbol *parent);

  bool refErr(Symbol *symbol, const char *format, ...);
  bool defErr(Symbol *symbol, const char *format, ...);
};
