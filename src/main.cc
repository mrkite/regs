/** @copyright 2020 Sean Kasun */

#include <argp.h>
#include <iostream>
#include "disasm.h"
#include "omf.h"


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
  Map map(arguments.filename, arguments.org, arguments.flags);
  OMF omf(map);
  if (!omf.load(arguments.filename)) {
    std::cerr << "Failed to load " << arguments.filename << std::endl;
    return -1;
  }
}
