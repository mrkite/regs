/** @copyright 2020 Sean Kasun */
#pragma once

#include <cstdint>
#include <map>
#include "handle.h"

struct Fingerprint {
  std::map<uint8_t, std::shared_ptr<Fingerprint>> map;
  uint8_t numDB;
  std::string name;
};

class Fingerprints {
 public:
  Fingerprints();
  void add(const std::vector<uint8_t> &keys, std::string name,
           uint8_t numDB = 0);
  std::shared_ptr<Fingerprint> root;
};

namespace symbol {

enum Kind {
  isIntrinsic = 0, isEnum, isAlias, isStruct, isUnion, isRef, isFunction,
};

struct Symbol {
  std::string name;
  uint32_t size;
  Kind kind;
};

struct Ref : public Symbol {
  std::shared_ptr<Symbol> symbol;
  uint32_t pointer;
  int32_t array;
  std::string reg;
};

struct Argument {
  std::string key;
  std::shared_ptr<Ref> ref;
};

struct Function : public Symbol {
  std::vector<Argument> arguments;
  std::shared_ptr<Ref> returnType;
  std::vector<int32_t> signature;
};

struct Field {
  std::string key;
  std::shared_ptr<Symbol> value;
};

struct Struct : public Symbol {
  std::vector<Field> fields;
};

struct Intrinsic : public Symbol {
  enum uint8_t { U8, U16, U32, S8, S16, S32 } type;
};

struct Enum : public Symbol {
  std::shared_ptr<Symbol> type;
  std::map<std::string, uint32_t> entries;
};

}

class API {
 public:
  API(unsigned char *dat, unsigned int len);
  std::map<std::string, std::shared_ptr<symbol::Symbol>> symbols;

 private:
  std::shared_ptr<symbol::Symbol> lookup(uint32_t id);
  void setIntrinsic(Handle h, std::shared_ptr<symbol::Symbol> s);
  void setEnum(Handle h, std::shared_ptr<symbol::Symbol> s);
  void setRef(Handle h, std::shared_ptr<symbol::Symbol> s);
  void setStruct(Handle h, std::shared_ptr<symbol::Symbol> s);
  void setFunction(Handle h, std::shared_ptr<symbol::Symbol> s);

  std::map<uint32_t, std::string> ids;
};
