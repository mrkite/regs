/** @copyright 2020 Sean Kasun */
#include "scanner.h"
#include <stack>
#include <iostream>
#include <algorithm>

Scanner::Scanner(std::vector<Segment> segments,
                 std::map<uint32_t, std::string> symbols,
                 std::shared_ptr<Fingerprints> fingerprints)
  : symbols(symbols), segments(segments), fingerprints(fingerprints) {}


bool Scanner::trace(const Entry &start,
                    std::function<std::shared_ptr<Inst>(Handle, Entry*)>
                    decode) {
  std::stack<Entry> workList;

  workList.push(start);
  labels[start.org] = start.org;
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
      if (fingerprints) {
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
          inst->name += "$" + hex(ptr->r8(), 2);
        }
        inst->name += "}";
        inst->length += numDB;
        state.org += numDB;
      }
      if (!inst) {
        inst = decode(ptr, &state);
      }
      map[addr] = inst;
      if (inst->type == Jump || inst->type == Branch || inst->type == Call) {
        if (inst->operType == Opr::Abs) {
          if (valid(inst->oper) && labels.find(inst->oper) == labels.end()) {
            workList.push({inst->oper, state.flags});
            labels[inst->oper] = inst->oper;
          }
        }
      }
      if (inst->type == Jump || inst->type == Branch || inst->type == Return) {
        // we want branches included in the block
        branches[state.org] = addr;
      }
      if (inst->type == Invalid) {
        branches[addr] = addr;
      }
    } while (inst->type != Return && inst->type != Jump &&
             inst->type != Invalid);
  }
  return true;
}

static bool compareBlocks(std::shared_ptr<Block> a, std::shared_ptr<Block> b) {
  return a->address < b->address;
}

bool Scanner::basicBlocks() {
  if (labels.empty()) {  // no blocks
    return true;
  }
  // always start at a label
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
      next->preds.push_back(block);
      block->succs.push_back(next);
      block = next;
    } else if (branch != branches.end() && (label == labels.end() ||
                                            branch->second <= label->second)) {
      // branch was earliest (or equal)
      auto b = map[branch->second];
      block->branchLen = b->length;
      block->length = branch->first - block->address;
      if (b->type != Return && b->type != Invalid) {
        // branch has a destination
        if (b->operType == Opr::Abs) {
          if (valid(b->oper)) {
            auto next = getBlock(b->oper);
            next->preds.push_back(block);
            block->succs.push_back(next);
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
        next->preds.push_back(block);
        block->succs.push_back(next);
        block = next;
        address = block->address;
      }
    } else {
      // out of labels and branches
      block->length = map.rbegin()->first + map.rbegin()->second->length -
          block->address;
      done = true;
    }
  }
  std::sort(blocks.begin(), blocks.end(), compareBlocks);
  return true;
}

bool Scanner::disassemble(std::ostream &f, uint32_t from, uint32_t to,
                          std::function<std::string(std::shared_ptr<Inst>)>
                          printInst) {
  auto address = from;
  for (auto b : blocks) {
    if (b->address + b->length <= address) {
      continue;
    }
    if (address < b->address) {
      auto last = std::min(to, b->address);
      dumpHex(f, address, last);
      address = last;
    }
    if (address == b->address) {
      auto count = 0;
      std::string preds;
      for (auto pred : b->preds) {
        if (pred->address + pred->length != b->address && count++ < 7) {
          preds += (pred->address < b->address) ? u8"\u2b06 " : u8"\u2b07 ";
          preds += hex(pred->address + pred->length - pred->branchLen, 6);
        }
      }
      if (count > 0) {
        f << hex(address, 6) << ": " << preds << std::endl;
      }
    }
    while (address < to && address < b->address + b->length) {
      auto sym = symbols[address];
      if (!sym.empty()) {
        f << sym << std::endl;
      }
      f << hex(address, 6) << ": ";
      auto ptr = getAddress(address);
      if (map[address]->length > 4) {
        f << ".. .. .. .. ";
      } else {
        for (int i = 0; i < map[address]->length; i++) {
          f << hex(ptr->r8(), 2) << " ";
        }
        for (int i = map[address]->length; i < 4; i++) {
          f << "   ";
        }
      }
      f << printInst(map[address]) << std::endl;
      address += map[address]->length;
    }
    if (address < b->address + b->length) {
      break;
    }
  }
  if (address < to) {
    dumpHex(f, address, to);
  }
  return true;
}

void Scanner::dumpHex(std::ostream &f, uint32_t from, uint32_t to) {
  auto ptr = getAddress(from);
  if (ptr != nullptr) {
    for (int i = 0; !ptr->eof() && from < to; i += 16) {
      f << hex(from, 6) << ": ";
      std::string ascii;
      int skip = from & 0xf;
      int j = 0;
      for (; j < skip; j++) {
        if (j == 8) {
          f << " ";
          ascii += " ";
        }
        f << "   ";
        ascii += " ";
      }
      for (; j < 16 && !ptr->eof() && from < to; j++) {
        if (j == 8) {
          f << " ";
          ascii += " ";
        }
        uint8_t ch = ptr->r8();
        f << hex(ch, 2) << " ";
        ascii += isprint(ch) ? static_cast<char>(ch) : '.';
        from++;
      }
      for (; j < 16; j++) {
        f << "   ";
      }
      f << "| " << ascii << std::endl;
    }
  }
}

Handle Scanner::getAddress(uint32_t address) {
  for (auto &s : segments) {
    if (address >= s.mapped && address < s.mapped + s.length) {
      s.data->seek(address - s.mapped);
      return s.data;
    }
  }
  return nullptr;
}

bool Scanner::valid(uint32_t address) {
  for (auto &s : segments) {
    if (address >= s.mapped && address < s.mapped + s.length) {
      return true;
    }
  }
  return false;
}

std::shared_ptr<Block> Scanner::getBlock(uint32_t address) {
  auto res = std::find_if(blocks.begin(), blocks.end(),
                          [address](const std::shared_ptr<Block> n) {
                            return n->address == address;
                          });
  if (res != blocks.end()) {
    return *res;
  }
  auto block = std::make_shared<Block>(address);
  block->branchLen = 0;
  block->length = 0;
  blocks.push_back(block);
  return block;
}

std::string Scanner::hex(uint32_t value, size_t len) {
  static const char *digits = "0123456789abcdef";
  if (len == 6) {
    std::string ret="00/0000";
    for (size_t i = 0, j = 5 << 2; i < 6; i++, j -= 4) {
      ret[i < 2 ? i : i + 1] = digits[(value >> j) & 0xf];
    }
    return ret;
  }
  std::string ret(len, '0');
  for (size_t i = 0, j = (len - 1) << 2; i < len; i++, j -= 4) {
    ret[i] = digits[(value >> j) & 0xf];
  }
  return ret;
}
