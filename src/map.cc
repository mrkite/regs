/** @copyright 2020 Sean Kasun */
#include "map.h"
#include <string>
#include <fstream>
#include <algorithm>

struct Field {
  uint32_t org;
  std::string flags;
  bool isEntry;
  bool isOrg;
  std::string symbol;
};

Map::Map(const char *filename, uint32_t org) : org(org) {
  mapname = filename;
  mapname += ".regs";
  usedMap = false;
  File file(mapname);
  if (!file.is_open()) {
    return;
  }

  usedMap = true;
  while (!file.eof()) {
    uint32_t ofs = file.hex();
    if (file.check('!')) {
      if (!this->org) {  // commandline overrides
        this->org = ofs;
      }
    }
    if (file.check(':')) {
      Entry entry;
      entry.org = ofs;
      entry.flags = 0;
      uint8_t ch;
      while ((ch = file.oneOf("emx")) != 0) {
        switch (ch) {
          case 'e':
            entry.flags |= IsEmu;
            entry.flags |= IsM8;
            entry.flags |= IsX8;
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

static bool compareFields(const Field &a, const Field &b) {
  return a.org < b.org;
}

void Map::save() {
  std::map<uint32_t, Field> fields;
  fields[this->org].isOrg = true;
  for (auto & entryPoint : entryPoints) {
    auto org = entryPoint.org;
    fields[org].isEntry = true;
    if (entryPoint.flags & IsEmu) {
      fields[org].flags += 'e';
    } else {  // only if not emu, otherwise its redundant
      if (entryPoint.flags & IsM8) {
        fields[org].flags += 'm';
      }
      if (entryPoint.flags & IsX8) {
        fields[org].flags += 'x';
      }
    }
  }
  for (auto sym : symbols) {
    fields[sym.first].symbol = sym.second;
  }
  std::vector<Field> outFields;
  for (auto field : fields) {
    field.second.org = field.first;
    outFields.push_back(field.second);
  }
  std::sort(outFields.begin(), outFields.end(), compareFields);
  std::ofstream f(mapname, std::ios::out | std::ios::binary | std::ios::trunc);
  for (auto field : outFields) {
    f << toAddress(field.org);
    if (field.isOrg) {
      f << "!";
    }
    if (field.isEntry) {
      f << ":";
    }
    if (!field.flags.empty()) {
      f << field.flags;
    }
    if (!field.symbol.empty()) {
      f << "<" << field.symbol << ">";
    }
    f << std::endl;
  }
  f.close();
}

bool Map::needsEntry() {
  return !usedMap;
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

void Map::addSymbol(uint32_t ofs, std::string name) {
  symbols[ofs] = name;
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
  return p >= end;
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
    p++;
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

std::string Map::toAddress(uint32_t value) {
  static const char *digits = "0123456789abcdef";
  std::string ret="$00/0000";
  for (size_t i = 0, j = 5 << 2; i < 6; i++, j -= 4) {
    ret[i < 2 ? i + 1 : i + 2] = digits[(value >> j) & 0xf];
  }
  return ret;
}
