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
                           std::map<uint32_t, std::string> symbols, uint8_t b)
  : symbols(symbols), fingerprints(prints), b(b) {
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
    f << "Segment " << hex(segment.segnum, 2) << " "
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
  if (mode == IMMM && (entry->flags & IsM8)) {
    inst->length--;
  }
  if (mode == IMMX && (entry->flags & IsX8)) {
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
      inst->operType = Opr::Imm8;
      if (opcode == 0xe2) {
        entry->flags |= inst->oper & IsFlags;
      } else if (opcode == 0xc2) {
        entry->flags &= ~inst->oper;
      }
      break;
    case IMMM:
      if (entry->flags & IsM8) {
        inst->oper = f->r8();
        inst->operType = Opr::Imm8;
      } else {
        inst->oper = f->r16();
        inst->operType = Opr::Imm16;
      }
      break;
    case IMMX:
      if (entry->flags & IsX8) {
        inst->oper = f->r8();
        inst->operType = Opr::Imm8;
      } else {
        inst->oper = f->r16();
        inst->operType = Opr::Imm16;
      }
      break;
    case IMMS:
      inst->oper = f->r16();
      inst->operType = Opr::Imm16;
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
      inst->operType = Opr::IndXD;
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
      entry->flags &= ~IsEmu;
    }
    f->skip(-1);
  }
  if (opcode == 0x38) {
    if (f->r8() == 0xfb) {  // sec xce
      entry->flags |= IsEmu | IsM8 | IsX8;
    }
    f->skip(-1);
  }
  if ((entry->flags ^ oldFlags) & IsEmu) {
    entry->flags |= IsEmuChanged;
  }
  if ((entry->flags ^ oldFlags) & IsX8) {
    entry->flags |= IsX8Changed;
  }
  if ((entry->flags ^ oldFlags) & IsM8) {
    entry->flags |= IsM8Changed;
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
    case Opr::Imm8:
      args = "#" + hex(inst->oper, 2);
      break;
    case Opr::Imm16:
      args = "#" + hex(inst->oper, 4);
      break;
    case Opr::Abs:
      args = hex(inst->oper, 6);
      break;
    case Opr::AbsB:
      args = "B:" + hex(inst->oper, 4);
      comment += lookup(inst->oper);
      break;
    case Opr::AbsD:
      args = "D:" + hex(inst->oper, 2);
      break;
    case Opr::AbsX:
      args = hex(inst->oper, 6) + ", x";
      break;
    case Opr::AbsXB:
      args = "B:" + hex(inst->oper, 4) + ", x";
      comment += lookup(inst->oper);
      break;
    case Opr::AbsXD:
      args = "D:" + hex(inst->oper, 2) + ", x";
      break;
    case Opr::AbsY:
      args = hex(inst->oper, 6) + ", y";
      break;
    case Opr::AbsYB:
      args = "B:" + hex(inst->oper, 4) + ", y";
      comment += lookup(inst->oper);
      break;
    case Opr::AbsYD:
      args = "D:" + hex(inst->oper, 2) + ", y";
      break;
    case Opr::AbsS:
      args = hex(inst->oper, 2) + ", s";
      break;
    case Opr::Ind:
      args = "(" + hex(inst->oper, 6) + ")";
      break;
    case Opr::IndB:
      args = "(B:" + hex(inst->oper, 4) + ")";
      comment += lookup(inst->oper);
      break;
    case Opr::IndD:
      args = "(D:" + hex(inst->oper, 2) + ")";
      break;
    case Opr::IndX:
      args = "(" + hex(inst->oper, 6) + ", x)";
      break;
    case Opr::IndXB:
      args = "(B:" + hex(inst->oper, 4) + ", x)";
      comment += lookup(inst->oper);
      break;
    case Opr::IndXD:
      args = "(D:" + hex(inst->oper, 2) + ")";
      break;
    case Opr::IndY:
      args = "(D:" + hex(inst->oper, 2) + "), y";
      break;
    case Opr::IndL:
      args = "[D:" + hex(inst->oper, 2) + "]";
      break;
    case Opr::IndLY:
      args = "[D:" + hex(inst->oper, 2) + "], y";
      break;
    case Opr::IndS:
      args = "(" + hex(inst->oper, 2) + ", s), y";
      break;
    case Opr::Bank:
      args = hex(inst->oper >> 8, 2) + ", " + hex(inst->oper & 0xff, 2);
      break;
  }
  if (inst->flags & IsEmuChanged) {
    if (inst->flags & IsEmu) {
      comment += " 8-bit mode";
    } else {
      comment += " 16-bit mode";
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
  std::string r = inst->name;
  while (r.length() < 8) {
    r += " ";
  }
  r += args;
  if (!comment.empty()) {
    while (r.length() < 20) {
      r += " ";
    }
    r += "; " + comment;
  }
  return r;
}

std::string Disassembler::lookup(uint16_t val) {
  uint32_t addr = (b << 16) + val;
  return symbols[addr];
}

std::string Disassembler::hex(uint32_t val, int width) {
  static const char *digits = "0123456789abcdef";
  std::string ret;
  if (width == 6) {
    ret = symbols[val];
    if (!ret.empty()) {
      return ret;
    }
    ret = "$00/0000";
    for (size_t i = 0, j = 5 << 2; i < 6; i++, j -= 4) {
      ret[i < 2 ? i + 1 : i + 2] = digits[(val >> j) & 0xf];
    }
    return ret;
  }
  ret = "$";
  std::string h(width, '0');
  for (int i = 0, j = (width - 1) << 2; i < width; i++, j -= 4) {
    h[i] = digits[(val >> j) & 0xf];
  }
  return ret + h;
}
