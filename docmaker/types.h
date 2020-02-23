/** @copyright 2020 Sean Kasun */
#pragma once

#include <map>
#include <vector>
#include <string>

enum Intrinsic {
  U8, U16, U32, S8, S16, S32
};

enum Kind {
  isIntrinsic, isEnum, isAlias, isStruct, isUnion, isRef, isFunction
};

struct Ref {
  struct Symbol *symbol = nullptr;
  int32_t pointer = 0;
  int32_t array = -1;
  std::string reg;
};

struct Field {
  std::string key;
  Kind kind;
  int32_t size = 0;
  union {
    Ref *ref;
    struct Struct *theStruct;
  };
};

struct Argument {
  std::string key;
  Ref ref;
};

struct Enum {
  Symbol *type;
  std::map<std::string, int32_t> entries;
};

struct Function {
  std::vector<Argument> arguments;
  Ref retType;
  std::vector<uint32_t> signature;
};

struct Struct {
  std::vector<Field> fields;
};

struct Symbol {
  std::string name;
  bool isSizing = false;
  bool isSized = false;
  int32_t size = 0;
  bool isKnown = false;
  int referencedLine = 0;
  std::string referencedFile;
  int definedLine = 0;
  std::string definedFile;

  Kind kind;

  union {
    Function *asFunction;
    Struct *asStruct;
    Intrinsic asIntrinsic;
    Ref *asAlias;
    Enum *asEnum;
  };
};
