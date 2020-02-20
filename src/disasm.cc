/** @copyright 2020 Sean Kasun */

#include "disasm.h"
#include "65816.h"
#include "scanner.h"
#include <fstream>
#include <iostream>
#include <stack>

namespace ph = std::placeholders;

static std::map<Addressing, int> sizes;

Disassembler::Disassembler(std::shared_ptr<Fingerprints> prints,
                           std::map<uint32_t, std::string> symbols)
  : symbols(symbols), fingerprints(prints) {
    for (int i = 0; i < numAddressSizes; i++) {
      sizes[addressSizes[i].mode] = addressSizes[i].length;
    }
  }

bool Disassembler::disassemble(std::vector<Segment> segments,
                          std::vector<Entry> entries) {
  Scanner scanner(segments, symbols, fingerprints);
  // trace all entry points
  for (auto &entry : entries) {
    if (!scanner.trace(entry, std::bind(&Disassembler::decodeInst, this,
                                        ph::_1, ph::_2))) {
      std::cerr << "Failed to trace execution flow" << std::endl;
      return false;
    }
  }
  // build the basic blocks
  if (!scanner.basicBlocks()) {
    std::cerr << "Failed to calculate basic blocks" << std::endl;
    return false;
  }
  // disassemble each segment
  for (auto &segment : segments) {
    std::string fname = "seg" + std::to_string(segment.segnum);
    std::ofstream f(fname, std::ios::out | std::ios::binary | std::ios::trunc);
    if (!f.is_open()) {
      std::cerr << "Failed to open '" << fname << "' for writing" << std::endl;
      return false;
    }
    f << "Section $" << hex(segment.segnum, Value) << " "
      << segment.name << std::endl;
    if (!scanner.disassemble(f, segment.mapped,
                             segment.mapped + segment.length,
                             std::bind(&Disassembler::printInst, this,
                                       ph::_1))) {
      std::cerr << "Disassembly failed" << std::endl;
      return false;
    }
    f.close();
  }
  return true;
}

std::shared_ptr<Inst> Disassembler::decodeInst(Handle f, Entry *entry) {
  auto inst = std::make_shared<Inst>();
  auto opcode = f->r8();
  inst->name = opcodes[opcode].inst;
  inst->type = opcodes[opcode].type;
  auto mode = opcodes[opcode].addressing;
  inst->length = sizes[mode];
  if (mode == IMMM && (entry->flags & (IsEmu | IsM8))) {
    inst->length--;
  }
  if (mode == IMMX && (entry->flags & (IsEmu | IsX8))) {
    inst->length--;
  }
  entry->org += inst->length;
  uint32_t addr = entry->org;
  entry->flags &= IsFlags;  // clear changed flags
  uint32_t oldFlags = entry->flags;
  switch (mode) {
    case IMP:
      inst->operType = Opr::None;
      break;
    case IMM:
      inst->oper = f->r8();
      inst->operType = Opr::Imm;
      if (opcode == 0xe2) {
        entry->flags |= inst->oper & IsFlags;
      } else if (opcode == 0xc2) {
        entry->flags &= ~inst->oper;
      }
      if ((entry->flags ^ oldFlags) & IsX8) {
        entry->flags |= IsX8Changed;
      }
      if ((entry->flags ^ oldFlags) & IsM8) {
        entry->flags |= IsM8Changed;
      }
      break;
    case IMMM:
      if (entry->flags & (IsEmu | IsM8)) {
        inst->oper = f->r8();
      } else {
        inst->oper = f->r16();
      }
      inst->operType = Opr::Imm;
      break;
    case IMMX:
      if (entry->flags & (IsEmu | IsX8)) {
        inst->oper = f->r8();
      } else {
        inst->oper = f->r16();
      }
      inst->operType = Opr::Imm;
      break;
    case IMMS:
      inst->oper = f->r16();
      inst->operType = Opr::Imm;
      break;
    case ABS:
      inst->oper = f->r16();
      if (inst->type == InsType::Jump || inst->type == InsType::Call) {
        inst->oper |= entry->org & 0xff0000;  // K
        inst->operType = Opr::Abs;
      } else {
        inst->operType = Opr::AbsB;
      }
      break;
    case ABL:
      inst->oper = f->r24();
      inst->operType = Opr::Abs;
      break;
    case ABX:
      inst->oper = f->r16();
      if (inst->type == InsType::Jump || inst->type == InsType::Call) {
        inst->oper |= entry->org & 0xff0000;  // K
        inst->operType = Opr::AbsX;
      } else {
        inst->operType = Opr::AbsXB;
      }
      break;
    case ABY:
      inst->oper = f->r16();
      if (inst->type == InsType::Jump || inst->type == InsType::Call) {
        inst->oper |= entry->org & 0xff0000;  // K
        inst->operType = Opr::AbsY;
      } else {
        inst->operType = Opr::AbsYB;
      }
      break;
    case ABLX:
      inst->oper = f->r24();
      inst->operType = Opr::AbsX;
      break;
    case AIX:
      inst->oper = f->r16();
      if (inst->type == InsType::Jump || inst->type == InsType::Call) {
        inst->oper |= entry->org & 0xff0000;  // K
        inst->operType = Opr::IndX;
      } else {
        inst->operType = Opr::IndXB;
      }
      break;
    case ZP:
      inst->oper = f->r8();
      inst->operType = Opr::AbsD;
      break;
    case ZPX:
      inst->oper = f->r8();
      inst->operType = Opr::AbsXD;
      break;
    case ZPY:
      inst->oper = f->r8();
      inst->operType = Opr::AbsYD;
      break;
    case ZPS:
      inst->oper = f->r8();
      inst->operType = Opr::AbsS;
      break;
    case IND:
      inst->oper = f->r16();
      if (inst->type == InsType::Jump || inst->type == InsType::Call) {
        inst->oper |= entry->org & 0xff0000;  // K
        inst->operType = Opr::Ind;
      } else {
        inst->operType = Opr::IndB;
      }
      break;
    case INZ:
      inst->oper = f->r8();
      inst->operType = Opr::IndD;
      break;
    case INL:
      inst->oper = f->r8();
      inst->operType = Opr::IndL;
      break;
    case INX:
      inst->oper = f->r8();
      inst->operType = Opr::IndX;
      break;
    case INY:
      inst->oper = f->r8();
      inst->operType = Opr::IndY;
      break;
    case INLY:
      inst->oper = f->r8();
      inst->operType = Opr::IndLY;
      break;
    case INS:
      inst->oper = f->r8();
      inst->operType = Opr::IndS;
      break;
    case REL:
      inst->oper = addr + static_cast<int8_t>(f->r8());
      inst->operType = Opr::Abs;
      break;
    case RELL:
      inst->oper = addr + static_cast<int16_t>(f->r16());
      inst->operType = Opr::Abs;
      break;
    case BANK:
      inst->oper = f->r16();
      inst->operType = Opr::Bank;
      break;
    case DB:
      inst->oper = opcode;
      inst->operType = Opr::Abs;
      break;
    case DW:
      inst->oper = opcode | (f->r8() << 8);
      inst->operType = Opr::Abs;
      break;
    case DD:
      inst->oper = opcode | (f->r24() << 8);
      inst->operType = Opr::Abs;
      break;
  }
  if (opcode == 0x18) {
    if (f->r8() == 0xfb) {  // clc xce
      entry->flags &= 0xffffff ^ IsEmu;
    }
    f->skip(-1);
  }
  if (opcode == 0x38) {
    if (f->r8() == 0xfb) {  // sec xce
      entry->flags |= IsEmu;
    }
    f->skip(-1);
  }
  if ((entry->flags ^ oldFlags) & IsEmu) {
    entry->flags |= IsEmuChanged;
  }
  inst->flags = entry->flags;
  return inst;
}

std::string Disassembler::printInst(std::shared_ptr<Inst> inst) {
  std::string args;
  std::string comment;

  if (inst->type == Special) {
    return inst->name;
  }
  switch (inst->operType) {
    case Opr::None:
      break;
    case Opr::Imm:
      args = "#" + hex(inst->oper, Value);
      break;
    case Opr::Abs:
      args = hex(inst->oper, Address);
      break;
    case Opr::AbsB:
      args = "B:" + hex(inst->oper, Value);
      break;
    case Opr::AbsD:
      args = "D:" + hex(inst->oper, Value);
      break;
    case Opr::AbsX:
      args = hex(inst->oper, Address) + ", x";
      break;
    case Opr::AbsXB:
      args = "B:" + hex(inst->oper, Value) + ", x";
      break;
    case Opr::AbsXD:
      args = "D:" + hex(inst->oper, Value) + ", x";
      break;
    case Opr::AbsY:
      args = hex(inst->oper, Address) + ", y";
      break;
    case Opr::AbsYB:
      args = "B:" + hex(inst->oper, Value) + ", y";
      break;
    case Opr::AbsYD:
      args = "D:" + hex(inst->oper, Value) + ", y";
      break;
    case Opr::AbsS:
      args = hex(inst->oper, Value) + ", s";
      break;
    case Opr::Ind:
      args = "(" + hex(inst->oper, Address) + ")";
      break;
    case Opr::IndB:
      args = "(B:" + hex(inst->oper, Value) + ")";
      break;
    case Opr::IndD:
      args = "(D:" + hex(inst->oper, Value) + ")";
      break;
    case Opr::IndX:
      args = "(" + hex(inst->oper, Address) + ", x)";
      break;
    case Opr::IndXB:
      args = "(B:" + hex(inst->oper, Value) + ", x)";
      break;
    case Opr::IndY:
      args = "(" + hex(inst->oper, Address) + "), y";
      break;
    case Opr::IndL:
      args = "[" + hex(inst->oper, Address) + "]";
      break;
    case Opr::IndLY:
      args = "[" + hex(inst->oper, Address) + "], y";
      break;
    case Opr::IndS:
      args = "(" + hex(inst->oper, Value) + ", s), y";
      break;
    case Opr::Bank:
      args = hex(inst->oper >> 8, Value) + ", " + hex(inst->oper & 0xff, Value);
      break;
  }
  if (inst->flags & IsEmuChanged) {
    if (inst->flags & IsEmu) {
      comment = " 8-bit mode";
    } else {
      comment = " 16-bit mode";
    }
  }
  if (inst->flags & IsM8Changed) {
    if (inst->flags & IsM8) {
      comment += " a.b";
    } else {
      comment += " a.w";
    }
  }
  if (inst->flags & IsX8Changed) {
    if (inst->flags & IsX8) {
      comment += " x.b";
    } else {
      comment += " x.w";
    }
  }
  std::string r = args;
  if (!comment.empty()) {
    while (r.length() < 20) {
      r += " ";
    }
    r += "; " + comment;
  }
  return r;
}

std::string Disassembler::hex(uint32_t val, HexType type) {
  std::string ret;
  int width = 0;
  if (type == HexType::Address) {
    ret = symbols[val];
  }
  if (ret.empty()) {
    if ((val & ~0xff) == ~0xff) {
      ret += "$-";
      val = ~val + 1;
      width = 2;
    } else if ((val & ~0xff) == 0) {
      ret += "$";
      width = 2;
    } else if ((val & ~0xffff) == ~0xffff) {
      ret += "$-";
      val = ~val + 1;
      width = 4;
    } else if ((val & ~0xffff) == 0) {
      ret += "$";
      width = 4;
    } else if (val & 0x80000000) {
      ret += "$-";
      width = 8;
    } else {
      ret += "$";
      width = 8;
    }
    for (int i = 0; i < width; i++) {
      uint8_t ch = val >> (width - (i + 1)) * 4;
      if (ch < 10) {
        ret += static_cast<char>(ch + '0');
      } else {
        ret += static_cast<char>(ch - 10 + 'a');
      }
    }
  }
  return ret;
}
