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

enum class Opr {
  None = 0, Imm8, Imm16, Abs, AbsB, AbsD, AbsX, AbsXB, AbsXD,
  AbsY, AbsYB, AbsYD, AbsS, Ind, IndB, IndD, IndX, IndXB, IndXD,
  IndY, IndL, IndLY, IndS, Bank,
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
               std::map<uint32_t, std::string> symbols, uint8_t b);
  bool disassemble(std::vector<struct Segment> segments,
                   std::vector<struct Entry> entries);

 private:
  std::string printInst(std::shared_ptr<Inst> inst);
  std::shared_ptr<Inst> decodeInst(Handle f, Entry *entry);
  bool valid(uint32_t address);
  std::string hex(uint32_t value, int width);
  std::string lookup(uint16_t value);

  std::map<uint32_t, std::string> symbols;
  std::shared_ptr<Fingerprints> fingerprints;
  uint8_t b;
};
