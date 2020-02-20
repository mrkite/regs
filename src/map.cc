/** @copyright 2020 Sean Kasun */
#include "map.h"
#include <string>
#include <fstream>

Map::Map(const char *filename) {
  std::string mapname = filename;
  mapname += ".regs";
  File file(mapname);
  if (!file.is_open()) {
    return;
  }

  while (!file.eof()) {
    uint32_t ofs = file.hex();
    if (!ofs) {
      return;
    }
    if (file.check(':')) {
      Entry entry;
      entry.org = ofs;
      entry.flags = 0;
      uint8_t ch;
      while ((ch = file.oneOf("oemx")) != 0) {
        switch (ch) {
          case 'o':
            if (this->org) {
              file.error("Duplicate org address");
              return;
            }
            this->org = ofs;
            break;
          case 'e':
            entry.flags |= IsEmu;
            break;
          case 'm':
            entry.flags |= IsM8;
            break;
          case 'x':
            entry.flags |= IsX8;
            break;
        }
      }
      entryPoints.push_back(entry);
    }
    if (file.check('<')) {
      symbols[ofs] = file.until('>');
    }
  }
}

bool Map::needsEntry() {
  return entryPoints.size() == 0;
}

std::vector<Entry> Map::getEntries() {
  return entryPoints;
}

std::map<uint32_t, std::string> Map::getSymbols() {
  return symbols;
}

void Map::addEntry(uint32_t entry, uint32_t flags) {
  Entry e;
  e.org = entry;
  e.flags = flags;
  entryPoints.push_back(e);
}

File::File(const std::string &filename) {
  data = p = nullptr;
  std::ifstream f(filename, std::ios::in | std::ios::binary | std::ios::ate);
  if (!f.is_open()) {
    return;
  }
  auto length = f.tellg();
  data = new uint8_t[length];
  f.seekg(0, std::ios::beg);
  f.read(reinterpret_cast<char*>(data), length);
  f.close();
  p = data;
  end = data + length;
  curLine = 1;
}

bool File::is_open() const {
  return data != nullptr;
}

void File::ws() {
  while (p < end && isspace(*p)) {
    if (*p == '\n') {
      curLine++;
    }
    p++;
  }
}

bool File::eof() {
  ws();
  return p < end;
}

uint32_t File::hex() {
  uint32_t bank = 0;
  uint32_t res = 0;
  if (*p == '$') {
    p++;
  }
  while (p < end && (isxdigit(*p) || *p == '/')) {
    if (*p == '/') {
      bank = res;
      res = 0;
    } else if (isdigit(*p)) {
      res <<= 4;
      res |= *p - '0';
    } else if (*p >= 'a' && *p <= 'f') {
      res <<= 4;
      res |= *p - 'a' + 10;
    } else {
      res <<= 4;
      res |= *p - 'A' + 10;
    }
    p++;
  }
  return res | (bank << 16);
}

bool File::check(uint8_t ch) {
  ws();
  if (p < end && ch == *p) {
    return true;
  }
  return false;
}

char File::oneOf(const std::string &str) {
  ws();
  if (p < end && str.find(*p) != std::string::npos) {
    return *p++;
  }
  return 0;
}

void File::error(const char *msg) {
  fprintf(stderr, "%s Line %d: %s\n", filename.c_str(), curLine, msg);
}

std::string File::until(uint8_t ch) {
  std::string r;
  while (*p != ch) {
    r += *p++;
  }
  p++;  // skip ending character
  return r;
}
