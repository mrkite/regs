/** @copyright 2020 Sean Kasun */
#include "map.h"
#include <string>
#include <fstream>

Map::Map(const char *filename, uint32_t org, uint32_t flags) {
  std::string mapname = filename;
  mapname += ".regs";
  std::ifstream f(mapname, std::ios::in | std::ios::binary | std::ios::ate);
  if (!f.is_open()) {
    Symbol symbol;
    symbol.org = org;
    symbol.flags = flags;
    symbols.push_back(symbol);
    return;
  }
  std::streamoff len = f.tellg();
  char *data = new char[len + 1];
  f.seekg(0, std::ios::beg);
  f.read(data, len);
  f.close();
  data[len] = 0;
  ConfigFile c(data, len);

}
