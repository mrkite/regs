/** @copyright 2020 Sean Kasun */

#include <argp.h>
#include <iostream>
#include "disasm.h"
#include "omf.h"
#include "api.h"
#include "../iigs.c"

const char *argp_program_version = "regs 0.2";
const char *argp_program_bug_address = "sean@seancode.com";
static char doc[] = "Disassemble Apple IIgs software";
static char args_doc[] = "FILE";
static struct argp_option options[] = {
  {"org", 'o', "ADDRESS", 0, "Starting address of the binary file"},
  {"m", 'm', 0, OPTION_ARG_OPTIONAL, "Start with 8-bit accumulator"},
  {"x", 'x', 0, OPTION_ARG_OPTIONAL, "Start with 8-bit indices"},
  {"e", 'e', 0, OPTION_ARG_OPTIONAL, "Start in emulation mode"},
  { 0 },
};

struct arguments {
  const char *filename;
  uint32_t org;
  uint32_t flags;
};

static inline uint32_t parseNum(const char *s) {
  uint32_t res = 0;
  while (isspace(*s)) {
    s++;
  }
  bool ishex = false;
  if (s[0] == '0' && s[1] == 'x') {
    s += 2;
    ishex = true;
  } else if (s[0] == '$') {
    s++;
    ishex = true;
  }
  if (ishex) {
    while (isxdigit(*s)) {
      res <<= 4;
      if (isdigit(*s)) {
        res |= *s - '0';
      } else if (*s >= 'a' && *s <= 'f') {
        res |= *s - 'a' + 10;
      } else {
        res |= *s - 'A' + 10;
      }
      s++;
    }
  } else {
    while (isdigit(*s)) {
      res *= 10;
      res += *s - '0';
      s++;
    }
  }
  return res;
}

static error_t parse_opt(int key, char *arg, struct argp_state *state) {
  struct arguments *arguments = static_cast<struct arguments *>(state->input);
  switch (key) {
    case 'o':
      if (arg) {
        arguments->org = parseNum(arg);
      }
      break;
    case 'm':
      if (arg) {
        arguments->flags |= IsM8;
      }
      break;
    case 'x':
      if (arg) {
        arguments->flags |= IsX8;
      }
      break;
    case 'e':
      if (arg) {
        arguments->flags |= IsEmu;
      }
      break;
    case ARGP_KEY_ARG:
      if (state->arg_num >= 1) {
        argp_usage(state);
      }
      arguments->filename = arg;
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

int main(int argc, char **argv) {
  struct arguments arguments;
  arguments.filename = "";
  arguments.org = 0x300;
  arguments.flags = 0;
  argp_parse(&argp, argc, argv, 0, 0, &arguments);

  // load map if it exists
  Map map(arguments.filename);
  OMF omf;
  if (!omf.load(arguments.filename, arguments.org)) {
    std::cerr << "Failed to load " << arguments.filename << std::endl;
    return -1;
  }
  auto segments = omf.get();
  if (map.needsEntry()) {
    for (auto &s : segments) {
      if ((s.kind & 0x1f) == 0) {  // code
        map.addEntry(s.mapped + s.entry, arguments.flags);
        break;
      }
    }
  }

  API api(iigs_dat, iigs_dat_len);

  auto prints = std::make_shared<Fingerprints>();
  for (auto s : api.symbols) {
    if (s.second->kind == symbol::isFunction) {
      auto f = std::static_pointer_cast<symbol::Function>(s.second);
      if (f->signature.size() >= 2) {
        if (f->signature[0] >= 0) {  // tool
          // ldx tool, jsl e1/0000
          std::vector<uint8_t> sig = { 0xa2, 0x00, 0x00,
            0x22, 0x00, 0x00, 0xe1 };
          sig[1] = f->signature[0];
          sig[2] = f->signature[1];
          prints->add(sig, f->name);
        } else if (f->signature[0] == -1) {  // p16/gsos
          // jsl e1/00a8
          std::vector<uint8_t> sig = { 0x22, 0xa8, 0x00, 0xe1, 0x00, 0x00 };
          sig[4] = f->signature[2] & 0xff;
          sig[5] = f->signature[2] >> 8;
          prints->add(sig, f->name, f->signature[1] & 0xff);
        } else if (f->signature[0] == -2) {  // p8
          // jsr bf00
          std::vector<uint8_t> sig = { 0x20, 0x00, 0xbf, 0x00 };
          sig[3] = f->signature[2];
          prints->add(sig, f->name, f->signature[1] & 0xff);
        } else if (f->signature[0] == -3) {  // smartport
          // jsr c50d
          std::vector<uint8_t> sig5 = { 0x20, 0x0d, 0xc5, 0x00 };
          std::vector<uint8_t> sig7 = { 0x20, 0x0d, 0xc7, 0x00 };
          sig5[3] = f->signature[2];
          sig7[3] = f->signature[2];
          prints->add(sig5, f->name, f->signature[1]);
          prints->add(sig7, f->name, f->signature[1]);
        }
      }
    }
  }

  Disassembler d(prints, map.getSymbols());
  d.disassemble(segments, map.getEntries());
}
