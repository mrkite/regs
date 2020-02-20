/** @copyright 2020 Sean Kasun */

#include "disasm.h"
#include "65816.h"
#include <fstream>
#include <iostream>
#include <stack>

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
  this->segments = segments;
  // trace all entry points
  for (auto &entry : entries) {
    if (!trace(entry)) {
      std::cerr << "Failed to trace execution flow" << std::endl;
      return false;
    }
  }
  // build the basic blocks
  if (!basicBlocks()) {
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
    if (!decode(segment.mapped, segment.mapped + segment.length)) {
      std::cerr << "Disassembly failed" << std::endl;
      return false;
    }
    f.close();
  }
  return true;
}

bool Disassembler::trace(const Entry &start) {
  std::stack<Entry> workList;

  workList.push(start);
  labels.insert(std::pair<uint32_t, uint32_t>(start.org, start.org));
  while (!workList.empty()) {
    auto state = workList.top();
    workList.pop();
    std::shared_ptr<Inst> inst = nullptr;
    do {
      auto ptr = getAddress(state.org);
      if (ptr == nullptr) {
        return false;
      }
      auto addr = state.org;
      inst = nullptr;
      int16_t numDB = 0;
      if (fingerprints) {  // scan for fingerprints
        auto node = fingerprints->root;
        int8_t len = 0;
        auto fstart = ptr->tell();
        do {
          node = node->map[ptr->r8()];
          len++;
          if (node != nullptr && !node->name.empty()) {
            if (inst == nullptr) {
              inst = std::make_shared<Inst>();
              inst->type = Special;
            }
            inst->name = node->name;
            inst->length = len;
            numDB = node->numDB;
          }
        } while (node != nullptr && !ptr->eof());
        if (inst) {
          fstart += inst->length;
          state.org += inst->length;
        }
        ptr->seek(fstart);
      }
      if (numDB > 0 && inst) {
        inst->name += " {";
        for (int i = 0; i < numDB; i++) {
          if (i) {
            inst->name += ", ";
          }
          inst->name += hex(ptr->r8(), Value);
        }
        inst->name += "}";
        inst->length += numDB;
        state.org += numDB;
      }
      if (!inst) {
        inst = decodeInst(ptr, &state);
      }
      map[addr] = inst;
      if (inst->type == Jump || inst->type == Branch || inst->type == Call) {
        if (inst->operType == Opr::Imm || inst->operType == Opr::Abs) {
          if (valid(inst->oper) && labels.find(inst->oper) == labels.end()) {
            workList.push({state.flags, inst->oper});
            labels.insert(std::pair<uint32_t, uint32_t>(inst->oper,
                                                        inst->oper));
          }
        }
      }
      if (inst->type == Jump || inst->type == Branch ||
          inst->type == Return) {
        branches.insert(std::pair<uint32_t, uint32_t>(state.org, addr));
      }
      if (inst->type == Invalid) {
        branches.insert(std::pair<uint32_t, uint32_t>(addr, addr));
      }
    } while (inst->type != Return && inst->type != Jump &&
             inst->type != Invalid);
  }
  return true;
}

bool Disassembler::basicBlocks() {
  // always starts at a label
  auto address = labels.lower_bound(0)->first;
  auto block = getBlock(address);
  auto done = false;
  while (!done) {
    auto label = labels.upper_bound(address);
    auto branch = branches.upper_bound(address);
    if (label != labels.end() && (branch == branches.end() ||
                                  label->second < branch->second)) {
      // label was earliest
      address = label->second;
      block->length = address - block->address;
      auto next = getBlock(address);
      next->preds.append(block);
      block->succs.append(next);
      block = next;
    } else if (branch != branches.end() && (label == labels.end() ||
                                            branch->second <= label->second)) {
      // branch was earliest (or equal)
      auto b = map[branch->second];
      block->branchLen = b->length;
      block->length = branch->first - block->address;
      if (b->type != Return && b->type != Invalid) {
        // branch has a destination
        if (b->operType == Opr::Imm || b->operType == Opr::Abs) {
          if (valid(b->oper)) {
            auto next = getBlock(b->oper);
            next->preds.append(block);
            block->succs.append(next);
          }
        }
      }
      if (b->type == Jump || b->type == Return || b->type == Invalid) {
        // branch doesn't continue
        auto next = labels.upper_bound(branch->second);
        if (next == labels.end()) {
          done = true;
        } else {
          address = next->second;
          block = getBlock(address);
        }
      } else {
        // branch continues
        auto next = getBlock(branch->first);
        next->preds.append(block);
        block->succs.append(next);
        block = next;
        address = block->address;
      }
    } else {
      // out of labels and branches, we screwed up
      block->length = map.lastKey() + map.last()->length - block->address;
      done = true;
    }
  }
  std::sort(blocks.begin(), blocks.end(), compareBlocks);
  return true;
}

Handle Disassembler::getAddress(uint32_t address) {
  for (auto &s : segments) {
    if (address >= s.mapped && address < s.mapped + s.length) {
      s.data->seek(address - s.mapped);
      return s.data;
    }
  }
  return nullptr;
}

bool Disassembler::valid(uint32_t address) {
  for (auto &s : segments) {
    if (address >= s.mapped && address < s.mapped + s.length) {
      return true;
    }
  }
  return false;
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
