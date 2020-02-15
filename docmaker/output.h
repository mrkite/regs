/** @copyright 2020 Sean Kasun */
#pragma once
#include <iostream>
#include <map>
#include "parser.h"

class Output {
 public:
  void save(const std::map<std::string, Symbol> &symbols,
            const std::string &filename);

 private:
  uint32_t lookup(const std::string &name) const;
  void setIntrinsic(std::ostream *f, const Intrinsic i);
  void setEnum(std::ostream *f, const Enum *e);
  void setRef(std::ostream *f, const Ref *r);
  void setStruct(std::ostream *f, const Struct *str);
  void setFunction(std::ostream *f, const Function *func);
  void setField(std::ostream *f, const Field &field);
  void setArgument(std::ostream *f, const Argument &arg);

  void w32(std::ostream *f, uint32_t value);
  void w8(std::ostream *f, uint8_t value);
  void ws(std::ostream *f, const std::string &text);
  std::map<std::string, uint32_t> ids;
};
