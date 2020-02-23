/** @copyright 2020 Sean Kasun */

#include <argp.h>
#include <iostream>
#include <iomanip>
#include <locale>
#include <fstream>
#include <sys/stat.h>
#include <unistd.h>
#include "handle.h"
#include "prodos_types.h"

const char *argp_program_version = "2mg 0.2";
const char *argp_program_bug_address = "sean@seancode.com";
static char doc[] = "Extract ProDOS disk images";
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

static void indent(int depth) {
  for (int i = 0; i < depth; i++) {
    std::cout << "  ";
  }
}

static void doEntry(uint32_t entry, Handle h, int depth);

static void doDirectory(uint16_t key, Handle h, int depth) {
  uint32_t block = key * 512 + 4;
  h->seek(block);
  auto type = h->r8();
  if ((type & 0xf0) != 0xf0 && (type & 0xf0) != 0xe0) {
    std::cerr << "Invalid ProDOS disk" << std::endl;
    return;
  }
  std::string dirname = readFilename(h, type & 0xf);
  if (depth < 0) {
    mkdir(dirname.c_str(), 0777);
    chdir(dirname.c_str());
  } else {
    indent(depth);
    std::cout << dirname << " <dir>" << std::endl;
  }
  h->seek(block + 0x1f);
  auto entryLength = h->r8();
  auto entriesPerBlock = h->r8();
  auto fileCount = h->r16();
  uint8_t curEntry = 1;
  uint16_t curFile = 0;

  while (curFile < fileCount) {
    auto entry = block + curEntry * entryLength;
    h->seek(entry);
    auto type = h->r8();
    if (type) {
      doEntry(entry, h, depth < 0 ? -1 : depth + 1);
      curFile++;
    }
    curEntry++;
    if (curEntry == entriesPerBlock) {
      curEntry = 0;
      h->seek(block - 2);
      block = h->r16() * 512 + 4;
    }
  }
  if (depth < 0) {
    chdir("..");
  }
}

static void printDateTime(uint16_t date, uint16_t time) {
  std::cout << std::setfill('0')
            << std::setw(2) << ((date >> 9) & 0x7f) << "-"
            << std::setw(2) << ((date >> 5) & 0xf) << "-"
            << std::setw(2) << (date & 0x1f) << " "
            << std::setw(2) << ((time >> 8) & 0x1f) << ":"
            << std::setw(2) << (time & 0x3f);
}

static void dumpSeedling(Handle h, uint32_t len, std::ostream &f) {
  h->dump(len, f);
}

static void dumpSapling(Handle h, uint32_t len, std::ostream &f) {
  auto index = h->tell();
  while (len > 0) {
    h->seek(index);
    uint16_t blockid = h->r8();
    h->skip(255);
    blockid |= h->r8() << 8;
    uint32_t blen = std::min<uint32_t>(512, len);
    if (blockid && (blockid + 1) * 512 <= h->length) {
      h->seek(blockid * 512);
      dumpSeedling(h, blen, f);
    } else {
      f.seekp(blen, std::ios::cur);
    }
    len -= blen;
    index++;
  }
}

static void dumpTree(Handle h, uint32_t len, std::ostream &f) {
  auto index = h->tell();
  while (len > 0) {
    h->seek(index);
    uint16_t blockid = h->r8();
    h->skip(255);
    blockid |= h->r8() << 8;
    uint32_t blen = std::min<uint32_t>(256 * 512, len);
    if (blockid && (blockid + 1) * 512 <= h->length) {
      h->seek(blockid * 512);
      dumpSapling(h, blen, f);
    } else {
      f.seekp(blen, std::ios::cur);
    }
    len -= blen;
    index++;
  }
}

static void doFile(uint16_t key, uint32_t len, std::string name,
                   Handle h, int type) {
  h->seek(key * 512);
  std::ofstream f(name, std::ios::out | std::ios::binary | std::ios::trunc);
  if (!f.is_open()) {
    std::cerr << "Failed to create " << name << std::endl;
    return;
  }
  switch (type) {
    case 1:
      dumpSeedling(h, len, f);
      break;
    case 2:
      dumpSapling(h, len, f);
      break;
    case 3:
      dumpTree(h, len, f);
      break;
  }
  f.close();
}

static void doGSOS(uint16_t key, std::string filename, uint8_t type,
                   Handle h, int depth) {
  h->seek(key * 512);
  auto filetype = h->r8();
  auto subkey = h->r16();
  h->skip(2);
  auto eof = h->r24();
  if (depth < 0) {
    doFile(subkey, eof, filename, h, filetype);
  }
  std::string resname = filename;
  resname += ".res";
  h->seek(key * 512 + 0x100);
  filetype = h->r8();
  subkey = h->r16();
  h->skip(2);
  auto reof = h->r24();
  if (depth < 0) {
    doFile(subkey, reof, resname, h, filetype);
  } else {
    indent(depth);
    std::cout << filename << "  " << eof << " bytes  resource: "
              << reof << " bytes" << std::endl;
  }
}

static void doEntry(uint32_t entry, Handle h, int depth) {
  h->seek(entry);
  auto type = h->r8();
  std::string filename = readFilename(h, type & 0xf);

  h->seek(entry + 0x10);
  auto filetype = h->r8();
  auto key = h->r16();
  h->skip(2);
  auto eof = h->r24();

  switch (type & 0xf0) {
    case 0x10:  // seedling
    case 0x20:  // sapling
    case 0x30:  // tree
      if (depth < 0) {
        doFile(key, eof, filename, h, type >> 4);
      } else {
        auto createDate = h->r16();
        auto createTime = h->r16();
        h->skip(3);
        auto aux = h->r16();
        auto modDate = h->r16();
        auto modTime = h->r16();
        indent(depth);
        std::cout << filename << std::endl;
        indent(depth);
        std::cout << "  Size: " << eof;
        std::cout << " Created: ";
        printDateTime(createDate, createTime);
        std::cout << " Modified: ";
        printDateTime(modDate, modTime);
        std::cout << std::endl;
        indent(depth);
        std::cout << "  Type: $" << std::hex << std::setw(2)
                  << std::setfill('0') << static_cast<int>(filetype)
                  << " Aux: $" << std::setw(4) << aux << std::dec << " ";
        uint32_t typeaux = filetype | (aux << 8);
        for (int i = 0; i < numTypes; i++) {
          if ((typeaux & fileTypes[i].mask) == fileTypes[i].id) {
            std::cout << fileTypes[i].ext << "/" << fileTypes[i].desc;
            break;
          }
        }
        std::cout << std::endl;
      }
      break;
    case 0x50:
      doGSOS(key, filename, filetype, h, depth);
      break;
    case 0xd0:
      doDirectory(key, h, depth < 0 ? -1 : depth + 1);
      break;
    default:
      std::cerr << "Unknown file storage: " << static_cast<int>(type)
                << std::endl;
      return;
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
  if (h->length < 64) {
    std::cerr << arguments.diskimage << " is not a valid prodos disk image"
              << std::endl;
    return -1;
  }
  if (h->read(4) == "2IMG") {
    h->seek(0xc);
    if (h->r32() != 1) {
      std::cerr << "Not a ProDOS disk image" << std::endl;
      return -1;
    }
    h->seek(0x14);
    auto disklen = h->r32() * 512;
    auto diskofs = h->r32();
    h->seek(diskofs);
    h = TheHandle::createFromArray(h->readBytes(disklen));
  }
  doDirectory(2, h, arguments.list ? 0 : -1);
}
