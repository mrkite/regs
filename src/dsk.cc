/** @copyright 2020 Sean Kasun */

#include <argp.h>
#include <iostream>
#include <iomanip>
#include <locale>
#include <fstream>
#include <sys/stat.h>
#include <unistd.h>
#include "handle.h"

const char *argp_program_version = "dsk 0.1";
const char *argp_program_bug_address = "sean@seancode.com";
static char doc[] = "Extract DOS3.3 disk images";
static char args_doc[] = "DISKIMAGE";
static struct argp_option options[] = {
  {"list", 'l', 0, 0, "List files"},
  { 0 }
};

struct arguments {
  const char *diskimage;
  bool list;
};

static error_t parse_opt(int key, char *arg, struct argp_state *state) {
  struct arguments *arguments = static_cast<struct arguments *>(state->input);
  switch (key) {
    case 'l':
      arguments->list = true;
      break;
    case ARGP_KEY_ARG:
      if (state->arg_num >= 1) {
        argp_usage(state);
      }
      arguments->diskimage = arg;
      break;
    case ARGP_KEY_END:
      if (state->arg_num < 1) {
        argp_usage(state);
      }
      break;
    default:
      return ARGP_ERR_UNKNOWN;
  }
  return 0;
}

static struct argp argp = { options, parse_opt, args_doc, doc };

static std::string readFilename(Handle h, int len) {
  static const char *digits = "0123456789abcdef";
  std::string r;
  for (int i = 0; i < len; i++) {
    uint8_t ch = h->r8();
    if (isalnum(ch) || ch == '_' || ch == '.' || ch == ' ') {
      r += static_cast<char>(ch);
    } else {
      r += 'x';
      uint8_t hi = ch >> 4;
      uint8_t lo = ch & 0xf;
      r += digits[hi];
      r += digits[lo];
    }
  }
  return r;
}

static const char *types[] = {
  "TXT",  // 00
  "INT",  // 01
  "BAS",  // 02
  nullptr,  // 03
  "BIN",  // 04
  nullptr,  // 05
  nullptr,  // 06
  nullptr,  // 07
  "S",  // 08
  nullptr,  // 09
  nullptr,  // 0a
  nullptr,  // 0b
  nullptr,  // 0c
  nullptr,  // 0d
  nullptr,  // 0e
  nullptr,  // 0f
  "REL",  // 10
};

#define numTypes (sizeof(types) / sizeof(types[0]))

static uint16_t doFile(uint8_t track, uint8_t sector, uint8_t type,
                       std::string name, uint16_t length, Handle h) {
  auto data = std::vector<uint8_t>((length + 1) * 256);
  auto listTrack = track;
  auto listSector = sector;
  while (listTrack) {
    h->seek(listTrack * 16 * 256 + listSector * 256 + 1);
    listTrack = h->r8();
    listSector = h->r8();
    h->skip(2);
    auto offset = h->r16();
    h->skip(5);
    std::vector<uint8_t> pairs;
    for (auto i = 0; i < 0x7a * 2; i++) {
      pairs.push_back(h->r8());
    }
    for (auto i = 0; i < pairs.size(); i += 2) {
      if (pairs[i] == 0) {
        continue;
      }
      h->seek(pairs[i] * 256 * 16 + pairs[i + 1] * 256);
      auto v = h->readBytes(256);
      std::copy(v.begin(), v.end(), data.begin() + offset);
      offset += 256;
    }
  }

  switch (type) {
    case 0x00:  // text, run until null
      for (auto i = 0; i < data.size(); i++) {
        if (data[i] == '\0') {
          data.resize(i);
          break;
        }
      }
      break;
    case 0x01:  // int basic
    case 0x02:  // applesoft basic
      {
        auto wrap = TheHandle::createFromArray(data);
        auto len = wrap->r16();
        data = wrap->readBytes(len);
      }
      break;
    case 0x04:  // binary
      {
        auto wrap = TheHandle::createFromArray(data);
        auto meta = wrap->r16();
        if (name.empty()) {  // we just want the meta data
          return meta;
        }
        auto len = wrap->r16();
        data = wrap->readBytes(len);
      }
      break;
  }
  std::ofstream f(name, std::ios::out | std::ios::binary | std::ios::trunc);
  if (!f.is_open()) {
    std::cerr << "Failed to create " << name << std::endl;
    return -1;
  }
  f.write((const char *)&data[0], data.size());
  f.close();
  return 0;
}

static void catalog(uint8_t track, uint8_t sector, Handle h, int depth) {
  h->seek(track * 16 * 256 + sector * 256 + 1);
  auto nextTrack = h->r8();
  auto nextSector = h->r8();
  h->skip(8);
  auto ofs = h->tell();
  for (auto i = 0; i < 7; i++) {
    h->seek(ofs + i * 35);
    auto ftrack = h->r8();
    auto fsector = h->r8();
    auto type = h->r8() & 0x7f;
    auto name = readFilename(h, 30);
    auto length = h->r16();
    if (ftrack != 0xff && ftrack != 0x00) {
      if (depth < 0) {
        doFile(ftrack, fsector, type, name, length, h);
      } else {
        std::cout << name << std::endl << "Type: ";
        if (type < numTypes && types[type] != nullptr) {
          std::cout << types[type] << std::endl;
        } else {
          std::cout << static_cast<int>(type);
          if (type == 0x04) {  // binary
            std::cout << std::hex << "("
                      << doFile(ftrack, fsector, type, "", length, h)
                      << ")" << std::dec << std::endl;
          }
        }
        std::cout << "Blocks: " << length << std::endl;
      }
    }
  }
  if (nextTrack != 0) {
    catalog(nextTrack, nextSector, h, depth);
  }
}

class MyPunct : public std::numpunct<char> {
 protected:
  virtual char do_thousands_sep() const { return ','; }
  virtual std::string do_grouping() const { return "\03"; }
};

int main(int argc, char **argv) {
  struct arguments arguments;
  arguments.list = false;

  argp_parse(&argp, argc, argv, 0, 0, &arguments);

  std::cout.imbue(std::locale(std::locale::classic(), new MyPunct));

  auto h = TheHandle::createFromFile(arguments.diskimage);
  if (!h->isOpen()) {
    std::cerr << "Failed to open " << arguments.diskimage << std::endl;
    return -1;
  }
  if (h->length != 143360) {
    std::cerr << arguments.diskimage << " is not a valid DOS 3.3 disk image"
              << std::endl;
    return -1;
  }
  h->seek(17 * 16 * 256 + 1);
  auto catTrack = h->r8();
  auto catSector = h->r8();
  h->skip(0x24);
  auto pairs = h->r8();
  h->skip(0xc);
  auto numTracks = h->r8();
  auto numSectors = h->r8();
  if (pairs != 0x7a || numTracks != 35 || numSectors != 16 ||
      catTrack >= numTracks || catSector >= numSectors) {
    std::cerr << arguments.diskimage << " is not a valid DOS 3.3 disk image"
              << std::endl;
    return -1;
  }
  catalog(catTrack, catSector, h, arguments.list ? 0 : -1);
}
