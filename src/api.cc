/** @copyright 2020 Sean Kasun */

#include <iostream>
#include <algorithm>
#include "api.h"

Fingerprints::Fingerprints() {
  root = std::make_shared<Fingerprint>();
}

void Fingerprints::add(const std::vector<uint8_t> &keys, std::string name,
                       uint8_t numDB) {
  auto node = root;
  for (auto key : keys) {
    if (node->map.find(key) == node->map.end()) {
      node->map.insert(std::pair<uint8_t, std::shared_ptr<Fingerprint>>
                       (key, std::make_shared<Fingerprint>()));
    }
    node = node->map[key];
  }
  node->name = name;
  node->numDB = numDB;
}

API::API(unsigned char *dat, unsigned int len) {
  auto h = TheHandle::createFromArray(std::vector<uint8_t>(dat, dat + len));
  auto numSymbols = h->r32();
  for (uint32_t i = 0; i < numSymbols; i++) {
    auto id = h->r32();
    auto kind = h->r8();
    auto name = h->rs();
    ids.insert(std::pair<uint32_t, std::string>(id, name));
    std::shared_ptr<symbol::Symbol> s = nullptr;
    switch (kind) {
      case symbol::isIntrinsic:
        s = std::make_shared<symbol::Intrinsic>();
        s->kind = symbol::isIntrinsic;
        break;
      case symbol::isEnum:
        s = std::make_shared<symbol::Enum>();
        s->kind = symbol::isEnum;
        break;
      case symbol::isAlias:
        s = std::make_shared<symbol::Ref>();
        s->kind = symbol::isAlias;
        break;
      case symbol::isStruct:
        s = std::make_shared<symbol::Struct>();
        s->kind = symbol::isStruct;
        break;
      case symbol::isUnion:
        s = std::make_shared<symbol::Struct>();
        s->kind = symbol::isUnion;
        break;
      case symbol::isRef:
        std::cerr << "isRef on root!" << std::endl;
        break;
      case symbol::isFunction:
        s = std::make_shared<symbol::Function>();
        s->kind = symbol::isFunction;
        break;
      default:
        std::cerr << "Unknown type" << std::endl;
        break;
    }
    s->name = name;
    symbols[name] = s;
  }

  for (uint32_t i = 0; i < numSymbols; i++) {
    auto id = h->r32();
    auto s = symbols[ids[id]];
    s->size = h->r32();
    switch (s->kind) {
      case symbol::isIntrinsic:
        setIntrinsic(h, s);
        break;
      case symbol::isEnum:
        setEnum(h, s);
        break;
      case symbol::isAlias:
        setRef(h, s);
        break;
      case symbol::isStruct:
        setStruct(h, s);
        break;
      case symbol::isUnion:
        setStruct(h, s);
        break;
      case symbol::isRef:
        std::cerr << "base level ref" << std::endl;
        break;
      case symbol::isFunction:
        setFunction(h, s);
        break;
    }
  }
}

std::shared_ptr<symbol::Symbol> API::lookup(uint32_t id) {
  return symbols[ids[id]];
}

void API::setIntrinsic(Handle h, std::shared_ptr<symbol::Symbol> s) {
  auto i = std::static_pointer_cast<symbol::Intrinsic>(s);
  auto type = h->r8();
  switch (type) {
    case symbol::Intrinsic::U8:
      i->type = symbol::Intrinsic::U8;
      break;
    case symbol::Intrinsic::U16:
      i->type = symbol::Intrinsic::U16;
      break;
    case symbol::Intrinsic::U32:
      i->type = symbol::Intrinsic::U32;
      break;
    case symbol::Intrinsic::S8:
      i->type = symbol::Intrinsic::S8;
      break;
    case symbol::Intrinsic::S16:
      i->type = symbol::Intrinsic::S16;
      break;
    case symbol::Intrinsic::S32:
      i->type = symbol::Intrinsic::S32;
      break;
  }
}

void API::setEnum(Handle h, std::shared_ptr<symbol::Symbol> s) {
  auto e = std::static_pointer_cast<symbol::Enum>(s);
  e->type = lookup(h->r32());
  auto num = h->r32();
  for (uint32_t i = 0; i < num; i++) {
    auto value = h->r32();
    e->entries[h->rs()] = value;
  }
}

void API::setRef(Handle h, std::shared_ptr<symbol::Symbol> s) {
  auto r = std::static_pointer_cast<symbol::Ref>(s);
  auto id = h->r32();
  if (id == 0) {
    r->symbol = nullptr;
  } else {
    r->symbol = lookup(id);
    r->pointer = h->r32();
    r->array = static_cast<int32_t>(h->r32());
    r->reg = h->rs();
  }
}

void API::setStruct(Handle h, std::shared_ptr<symbol::Symbol> s) {
  auto str = std::static_pointer_cast<symbol::Struct>(s);
  auto numFields = h->r32();
  for (uint32_t i = 0; i < numFields; i++) {
    auto key = h->rs();
    auto kind = h->r8();
    auto size = h->r32();
    std::shared_ptr<symbol::Symbol> sym = nullptr;
    switch (kind) {
      case symbol::isRef:
        sym = std::make_shared<symbol::Ref>();
        sym->kind = symbol::isRef;
        sym->size = size;
        setRef(h, sym);
        break;
      case symbol::isStruct:
        sym = std::make_shared<symbol::Struct>();
        sym->kind = symbol::isStruct;
        sym->size = size;
        setStruct(h, sym);
        break;
      case symbol::isUnion:
        sym = std::make_shared<symbol::Struct>();
        sym->kind = symbol::isUnion;
        sym->size = size;
        setStruct(h, sym);
        break;
      default:
        std::cerr << "Unknown field type" << std::endl;
        break;
    }
    str->fields.push_back({key, sym});
  }
}

void API::setFunction(Handle h, std::shared_ptr<symbol::Symbol> s) {
  auto f = std::static_pointer_cast<symbol::Function>(s);
  auto numArgs = h->r32();
  for (uint32_t i = 0; i < numArgs; i++) {
    auto key = h->rs();
    auto ref = std::make_shared<symbol::Ref>();
    setRef(h, ref);
    f->arguments.push_back({key, ref});
  }
  f->returnType = std::make_shared<symbol::Ref>();
  setRef(h, f->returnType);
  auto numSig = h->r32();
  for (uint32_t i = 0; i < numSig; i++) {
    f->signature.push_back(static_cast<int32_t>(h->r32()));
  }
}

void API::search(std::string keyword, uint32_t org) {
  for (auto &s : symbols) {
    auto it = std::search(s.first.begin(), s.first.end(),
                          keyword.begin(), keyword.end(),
                          [](char a, char b) {
                            return std::toupper(a) == std::toupper(b);
                          });
    if (it != s.first.end()) {
      dumpSymbol(s.second, org);
      printf("\n");
    }
  }
}

void API::dumpRef(std::shared_ptr<symbol::Ref> ref) {
  for (int i = 0; i < ref->pointer; i++) {
    printf("^");
  }
  printf("%s", ref->symbol->name.c_str());
  if (ref->array > 0) {
    printf("[%d]", ref->array);
  } else if (ref->array == 0) {
    printf("[]");
  }
}

static void indent(int depth) {
  for (int i = 0; i < depth; i++) {
    printf("  ");
  }
}

void API::dumpSymbol(std::shared_ptr<symbol::Symbol> sym, uint32_t org, int depth) {
  indent(depth);
  printf("%s: ", sym->name.c_str());
  switch (sym->kind) {
    case symbol::Kind::isIntrinsic:
      switch (std::static_pointer_cast<symbol::Intrinsic>(sym)->type) {
        case symbol::Intrinsic::U8:
          printf("uint8");
          break;
        case symbol::Intrinsic::U16:
          printf("uint16");
          break;
        case symbol::Intrinsic::U32:
          printf("uint32");
          break;
        case symbol::Intrinsic::S8:
          printf("int8");
          break;
        case symbol::Intrinsic::S16:
          printf("int16");
          break;
        case symbol::Intrinsic::S32:
          printf("int32");
          break;
      }
      break;
    case symbol::Kind::isEnum:
      {
        auto e = std::static_pointer_cast<symbol::Enum>(sym);
        printf("enum : %s {\n", e->type->name.c_str());
        for (auto entry : e->entries) {
          printf("  %s = $%x,\n", entry.first.c_str(), entry.second);
        }
        printf("}");
      }
      break;
    case symbol::Kind::isAlias:
    case symbol::Kind::isRef:
      dumpRef(std::static_pointer_cast<symbol::Ref>(sym));
      break;
    case symbol::Kind::isStruct:
      {
        auto s = std::static_pointer_cast<symbol::Struct>(sym);
        printf("struct { // $%x bytes\n", sym->size);
        for (auto &f : s->fields) {
          indent(depth);
          printf("  %s: ", f.key.c_str());
          switch (f.value->kind) {
            case symbol::Kind::isRef:
              dumpRef(std::static_pointer_cast<symbol::Ref>(f.value));
              break;
            case symbol::Kind::isStruct:
              dumpSymbol(f.value, org, depth + 1);
              break;
            case symbol::Kind::isUnion:
              dumpSymbol(f.value, org, depth + 1);
              break;
            default:
              printf("%s", f.value->name.c_str());
              break;
          }
          printf(" // $");
          if (org > 0xffff) {
            printf("%02x/%04x\n", org >> 16, org & 0xffff);
          } else {
            printf("%04x\n", org);
          }
          org += f.value->size;
        }
        indent(depth);
        printf("}");
      }
      break;
    case symbol::Kind::isUnion:
      {
        auto s = std::static_pointer_cast<symbol::Struct>(sym);
        printf("union { // $%x bytes\n", sym->size);
        for (auto &f : s->fields) {
          printf("  %s: ", f.key.c_str());
          switch (f.value->kind) {
            case symbol::Kind::isRef:
              dumpRef(std::static_pointer_cast<symbol::Ref>(f.value));
              break;
            case symbol::Kind::isUnion:
              dumpSymbol(f.value, org, depth + 1);
              break;
            case symbol::Kind::isStruct:
              dumpSymbol(f.value, org, depth + 1);
              break;
            default:
              printf("%s", f.value->name.c_str());
              break;
          }
          printf(" // $");
          if (org > 0xffff) {
            printf("%02x/%04x\n", org >> 16, org & 0xffff);
          } else {
            printf("%04x\n", org);
          }
        }
        indent(depth);
        printf("}");
      }
      break;
    case symbol::Kind::isFunction:
      {
        auto f = std::static_pointer_cast<symbol::Function>(sym);
        printf("(\n");
        for (auto &a : f->arguments) {
          printf("  %s: ", a.key.c_str());
          dumpRef(a.ref);
          printf(",\n");
        }
        if (f->returnType->symbol != nullptr) {
          printf("): ");
          dumpRef(f->returnType);
        } else {
          printf(")");
        }
        if (f->signature[0] >= 0) {  // tool
          printf(" = TOOL $%02x:%02x\n", f->signature[0],
                 f->signature[1]);
        } else if (f->signature[0] == -1) {  // p16/gsos
          printf(" = GSOS $%04x\n", f->signature[2]);
        } else if (f->signature[0] == -2) {  // p8
          printf(" = P8 $%02x\n", f->signature[2]);
        } else if (f->signature[0] == -3) {  // smartport
          printf(" = Smartport $%02x\n", f->signature[2]);
        } else if (f->signature[0] == -4) {  // symbol
          printf(" = $%02x/%04x\n", f->signature[1] >> 16,
                 f->signature[1] & 0xffff);
        }
      }
      break;
  }
}
