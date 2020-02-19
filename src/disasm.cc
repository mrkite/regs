/** @copyright 2020 Sean Kasun */

#include "disasm.h"
#include <fstream>
#include <iostream>

Disassembler::Disassembler(std::shared_ptr<Fingerprints> prints) : fingerprints(prints) { }

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
    f << "Section $" << std::ios::hex << segment.segnum << " "
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
          node = node->map.value(ptr->r8(), nullptr);
          len++;
          if (node != nullptr && !node->name.isEmpty()) {
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
          inst->name += hex2(ptr->r8());
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
        auto target = target(inst, resolver);
        if (target > 0 && !labels.contains(target)) {
          workList.push({state.flags, target});
          labels.insert(target, target);
        }
      }
      if (inst->type == Jump || inst->type == Branch ||
          inst->type == Return) {
        branches.insert(state.org, addr);
      }
      if (inst->type == Invalid) {
        branches.insert(addr, addr);
      }
    } while (inst->type != Return && inst->type != Jump &&
             inst->type != Invalid);
  }
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
