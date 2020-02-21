/** @copyright 2020 Sean Kasun */
#pragma once

#include <cstdint>
#include <map>
#include <vector>
#include <string>
#include "disasm.h"

class File {
 public:
  File(const std::string &filename);
  bool is_open() const;
  bool eof();
  uint32_t hex();
  bool check(uint8_t ch);
  char oneOf(const std::string &str);
  std::string until(uint8_t ch);
  void error(const char *msg);
 private:
  uint8_t *data, *p, *end;
  int curLine;
  std::string filename;
  void ws();
};

struct Entry {
  uint32_t org;
  uint32_t flags;
};

class Map {
 public:
  Map(const char *filename, uint32_t org);
  void save();
  bool needsEntry();
  std::vector<Entry> getEntries();
  std::map<uint32_t, std::string> getSymbols();
  void addEntry(uint32_t entry, uint32_t flags);
  void addSymbol(uint32_t org, std::string name);
  uint32_t org;

 private:
  std::string mapname;
  std::vector<Entry> entryPoints;
  std::map<uint32_t, std::string> symbols;
  std::string toAddress(uint32_t val);
};
