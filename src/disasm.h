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

struct Inst {
  std::string name;
  InsType type;
  uint16_t length;
};

class Disassembler {
 public:
  Disassembler(std::shared_ptr<Fingerprints> prints);
  bool disassemble(std::vector<Segment> segments, std::vector<Entry> entries);

 private:
  bool trace(const Entry &start);
  Handle getAddress(uint32_t address);

  std::map<uint32_t, uint32_t> labels;
  std::map<uint32_t, uint32_t> branches;
  std::vector<Segment> segments;
  std::shared_ptr<Fingerprints> fingerprints;
};
