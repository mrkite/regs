/** @copyright 2020 Sean Kasun */

#include "output.h"
#include <fstream>

void Output::save(const std::map<std::string, Symbol> &symbols,
                  const std::string &filename) {
  std::ofstream f(filename, std::ios::out | std::ios::binary | std::ios::trunc);
  if (!f.is_open()) {
    std::cerr << "Failed to create " << filename << std::endl;
    exit(-1);
  }
  w32(&f, symbols.size());
  uint32_t id = 1;
  for (auto it = symbols.begin(); it != symbols.end(); it++) {
    w32(&f, id);
    w8(&f, it->second.kind);
    ws(&f, it->first);
    ids[it->first] = id++;
  }
  for (auto it = symbols.begin(); it != symbols.end(); it++) {
    auto symbol = it->second;
    w32(&f, lookup(it->first));
    w32(&f, symbol.size);
    switch (symbol.kind) {
      case isIntrinsic:
        setIntrinsic(&f, symbol.asIntrinsic);
        break;
      case isEnum:
        setEnum(&f, symbol.asEnum);
        break;
      case isAlias:
        setRef(&f, symbol.asAlias);
        break;
      case isStruct:
        setStruct(&f, symbol.asStruct);
        break;
      case isUnion:
        setStruct(&f, symbol.asStruct);
        break;
      case isFunction:
        setFunction(&f, symbol.asFunction);
        break;
      default:
        std::cerr << "Unknown symbol type" << std::endl;
        exit(-1);
    }
  }
  f.close();
}

uint32_t Output::lookup(const std::string &name) const {
  return ids.at(name);
}

void Output::w32(std::ostream *f, uint32_t val) {
  char buf[4];
  buf[0] = val & 0xff;
  buf[1] = (val >> 8) & 0xff;
  buf[2] = (val >> 16) & 0xff;
  buf[3] = (val >> 24) & 0xff;
  f->write(buf, 4);
}

void Output::w8(std::ostream *f, uint8_t val) {
  char v = val;
  f->write(&v, 1);
}

void Output::ws(std::ostream *f, const std::string &val) {
  uint8_t len = val.length() > 255 ? 255 : val.length();
  char v = len;
  f->write(&v, 1);
  f->write(val.c_str(), len);
}

void Output::setIntrinsic(std::ostream *f, const Intrinsic i) {
  w8(f, i);
}

void Output::setEnum(std::ostream *f, const Enum *e) {
  w32(f, lookup(e->type->name));
  w32(f, e->entries.size());
  for (auto it = e->entries.begin(); it != e->entries.end(); it++) {
    w32(f, it->second);
    ws(f, it->first);
  }
}

void Output::setRef(std::ostream *f, const Ref *r) {
  if (r->symbol == nullptr) {
    w32(f, 0);
  } else {
    w32(f, lookup(r->symbol->name));
    w32(f, r->pointer);
    w32(f, r->array);
    ws(f, r->reg);
  }
}

void Output::setStruct(std::ostream *f, const Struct *s) {
  w32(f, s->fields.size());
  for (auto &field : s->fields) {
    setField(f, field);
  }
}

void Output::setFunction(std::ostream *f, const Function *func) {
  w32(f, func->arguments.size());
  for (auto &arg : func->arguments) {
    setArgument(f, arg);
  }
  setRef(f, &func->retType);
  w32(f, func->signature.size());
  for (auto sig : func->signature) {
    w32(f, sig);
  }
}

void Output::setField(std::ostream *f, const Field &field) {
  ws(f, field.key);
  w8(f, field.kind);
  w32(f, field.size);
  switch (field.kind) {
    case isRef:
      setRef(f, field.ref);
      break;
    case isStruct:
      setStruct(f, field.theStruct);
      break;
    case isUnion:
      setStruct(f, field.theStruct);
      break;
    default:
      std::cerr << "Unknown field type" << std::endl;
      exit(-1);
  }
}

void Output::setArgument(std::ostream *f, const Argument &a) {
  ws(f, a.key);
  setRef(f, &a.ref);
}
