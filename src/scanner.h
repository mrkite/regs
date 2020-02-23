/** @copyright 2020 Sean Kasun */
#pragma once

#include "map.h"
#include <functional>

struct Block {
  explicit Block(uint32_t address) : address(address) {}
  uint32_t address;
  uint32_t length;
  uint32_t branchLen;
  std::vector<std::shared_ptr<Block>> preds;
  std::vector<std::shared_ptr<Block>> succs;
};

class Scanner {
  public:
   Scanner(std::vector<Segment> segments,
           std::map<uint32_t, std::string> symbols,
           std::shared_ptr<Fingerprints> fingerprints);
   bool trace(const Entry &start,
              std::function<std::shared_ptr<Inst>(Handle, Entry*)> decode);
   bool basicBlocks();
   bool disassemble(std::ostream &f, uint32_t from, uint32_t to,
                    std::function<std::string(std::shared_ptr<Inst>)> printInst);

  private:
   std::string hex(uint32_t value, size_t len);
   std::shared_ptr<Block> getBlock(uint32_t address);
   Handle getAddress(uint32_t address);
   bool valid(uint32_t address);
   void dumpHex(std::ostream &f, uint32_t from, uint32_t to);

   std::map<uint32_t, std::string> symbols;
   std::vector<Segment> segments;
   std::shared_ptr<Fingerprints> fingerprints;
   std::map<uint32_t, uint32_t> labels;
   std::map<uint32_t, uint32_t> branches;
   std::vector<std::shared_ptr<Block>> blocks;
   std::map<uint32_t, std::shared_ptr<Inst>> map;
};
