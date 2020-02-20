/** @copyright 2020 Sean Kasun */
#pragma once

#include <cstdint>
#include <map>
#include "omf.h"
#include "api.h"

enum {
  IsX8 = 0x10,
  IsM8 = 0x20,
  IsEmu = 0x100,
  IsFlags = 0xff0130,
  IsX8Changed = 0x200,
  IsM8Changed = 0x400,
  IsEmuChanged = 0x2000,
};

enum InsType : uint16_t {
  Normal = 0x00,
  Call = 0x01,
  Jump = 0x02,
  Return = 0x03,
  Branch = 0x04,
  Special = 0x05,  // fingerprint
  Invalid = 0xff,
};

enum HexType {
  Value = 0x01,
  Address = 0x02,
};

enum class Opr {
  None = 0, Imm, Abs, AbsB, AbsD, AbsX, AbsXB, AbsXD, AbsY, AbsYB, AbsYD, AbsS,
  Ind, IndB, IndD, IndX, IndXB, IndY, IndL, IndLY, IndS, Bank,
};

struct Inst {
  std::string name;
  InsType type;
  uint16_t length;
  Opr operType;
  uint32_t oper;
  uint32_t flags;
};

class Disassembler {
 public:
  Disassembler(std::shared_ptr<Fingerprints> prints,
               std::map<uint32_t, std::string> symbols);
  bool disassemble(std::vector<struct Segment> segments,
                   std::vector<struct Entry> entries);

 private:
  bool trace(const struct Entry &start);
  bool basicBlocks();
  std::shared_ptr<Inst> decodeInst(Handle f, Entry *entry);
  Handle getAddress(uint32_t address);
  bool valid(uint32_t address);
  std::string hex(uint32_t value, HexType type);

  std::map<uint32_t, std::string> symbols;
  std::map<uint32_t, uint32_t> labels;
  std::map<uint32_t, uint32_t> branches;
  std::vector<struct Segment> segments;
  std::shared_ptr<Fingerprints> fingerprints;
  std::map<uint32_t, std::shared_ptr<Inst>> map;
};
