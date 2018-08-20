/**
 * @copyright 2018 Sean Kasun
 * Handles parsing and relocating an OMF (s16, tool, etc)
 */

#include "handle.h"
#include "parser.h"
#include <stdlib.h>
#include <string.h>
#include <argp.h>

const char *argp_program_version = "omf 0.5";
const char *argp_program_bug_address = "sean@seancode.com";
static char doc[] = "Relocate and extract OMF segments"
  "\vThis should be run twice.  The first time to generate the map."
  "The second time, to use that map to relocate and extract the segments";
static char args_doc[] = "FILE";
static struct argp_option options[] = {
  {"org", 'o', "ADDRESS", OPTION_ARG_OPTIONAL,
    "Start mapping the segments at this address, default 20000"},
  {"map", 'm', "FILE", OPTION_ARG_OPTIONAL,
    "Use this map to extract the segments"},
  {"prefix", 'p', "PREFIX", OPTION_ARG_OPTIONAL,
    "Prefix segment files with this.  Default \"seg\""},
  { 0 }
};

struct arguments {
  char *filename;
  char *map;
  char *prefix;
  uint32_t org;
};

static inline uint32_t parseNum(const char *s) {
  uint32_t res = 0;
  while (isspace(*s)) {
    s++;
  }
  while (isxdigit(*s)) {
    res <<= 4;
    if (*s >= '0' && *s <= '9') {
      res |= *s - '0';
    } else if (*s >= 'a' && *s <= 'f') {
      res |= *s - 'a' + 10;
    } else if (*s >= 'A' && *s <= 'F') {
      res |= *s - 'A' + 10;
    }
    s++;
  }
  return res;
}

static error_t parse_opt(int key, char *arg, struct argp_state *state) {
  struct arguments *arguments = state->input;
  switch (key) {
    case 'm':
      arguments->map = arg;
      break;
    case 'p':
      arguments->prefix = arg;
      break;
    case 'o':
      if (arg) {
        arguments->org = parseNum(arg);
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


typedef struct Segment {
  uint32_t bytecnt;
  uint32_t resspc;
  uint32_t length;
  uint8_t lablen;
  uint8_t numlen;
  uint32_t banksize;
  uint16_t kind;
  uint32_t org;
  uint32_t align;
  uint16_t segnum;
  uint32_t entry;
  char name[256];
  uint8_t *offset;
  uint8_t *data;
  uint32_t mapped;
  struct Segment *next;
} Segment;

static Segment *loadOMF(uint8_t *data, size_t len);
static void mapSegments(Segment *segments, uint32_t min);
static void relocSegments(Segment *segments, char *prefix);

int main(int argc, char **argv) {
  struct arguments arguments;
  arguments.filename = "";
  arguments.map = NULL;
  arguments.prefix = "seg";
  arguments.org = 0x20000;
  argp_parse(&argp, argc, argv, 0, 0, &arguments);

  // open omf
  FILE *f = fopen(arguments.filename, "rb");
  if (!f) {
    fprintf(stderr, "Failed to open '%s'\n", arguments.filename);
    return -1;
  }
  fseek(f, 0, SEEK_END);
  size_t len = ftell(f);
  fseek(f, 0, SEEK_SET);
  uint8_t *data = malloc(len);
  fread(data, len, 1, f);
  fclose(f);

  Segment *segments = loadOMF(data, len);
  if (arguments.map != NULL) {
    // load the map!
    f = fopen(arguments.map, "rb");
    if (!f) {
      fprintf(stderr, "Failed to open '%s'\n", arguments.map);
      return -1;
    }
    ConfigFile c;
    fseek(f, 0, SEEK_END);
    len = ftell(f);
    fseek(f, 0, SEEK_SET);
    c.start = malloc(len);
    fread(c.start, len, 1, f);
    fclose(f);
    c.p = c.start;
    c.end = c.start + len;

    while (c.p < c.end) {
      uint32_t segnum = hex(&c);
      if (!token(&c, ':')) {
        fprintf(stderr, "Error: expected ':' in map.\n");
        exit(-1);
      }
      uint32_t mapped = hex(&c);

      for (Segment *seg = segments; seg != NULL; seg = seg->next) {
        if (seg->segnum == segnum) {
          seg->mapped = mapped;
        }
      }
      eatSpaces(&c);
    }
    free(c.start);
  }

  // map any unmapped segments
  mapSegments(segments, arguments.org);

  if (arguments.map != NULL) {
    relocSegments(segments, arguments.prefix);
  } else {
    int mlen = strlen(arguments.filename);
    char *mapname = malloc(mlen + 5);
    memcpy(mapname, arguments.filename, mlen);
    memcpy(mapname + mlen, ".map\0", 5);
    f = fopen(mapname, "wb");
    if (!f) {
      fprintf(stderr, "Failed to create '%s'\n", mapname);
      return -1;
    }
    for (Segment *seg = segments; seg != NULL; seg = seg->next) {
      fprintf(f, "%x:%x\n", seg->segnum, seg->mapped);
    }
    fclose(f);
    fprintf(stdout, "Created '%s'. Edit it, and extract with: \n"
        " %s --map=%s %s\n", mapname, argv[0], mapname, arguments.filename);
  }

  free(data);
}

static Segment *loadOMF(uint8_t *data, size_t len) {
  Segment *last = NULL;
  Segment *segments = NULL;

  size_t ofs = 0;
  while (ofs < len) {
    Segment *seg = malloc(sizeof(Segment));
    seg->next = NULL;

    uint8_t *p = data + ofs;
    seg->bytecnt = r32(p); p += 4;
    seg->resspc = r32(p); p += 4;
    seg->length = r32(p); p += 4;
    uint8_t kind = *p++;
    seg->lablen = *p++;
    seg->numlen = *p++;
    uint8_t version = *p++;
    seg->banksize = r32(p); p += 4;
    seg->kind = r16(p); p += 2;
    p += 2;  // undefined
    seg->org = r32(p); p += 4;
    seg->align = r32(p); p += 4;
    p += 2;  // byte order
    seg->segnum = r16(p); p += 2;
    seg->entry = r32(p); p += 4;
    uint16_t dispname = r16(p); p += 2;
    uint16_t dispdata = r16(p); p += 2;
    p = data + ofs + dispname + 0xa;
    uint8_t strlen = seg->lablen;
    if (strlen == 0) {
      strlen = *p++;
    }
    memcpy(seg->name, p, strlen);
    seg->name[strlen] = 0;
    seg->offset = data + ofs + dispdata;
    if (version == 1) {  // convert to v2
      seg->bytecnt *= 512;
      seg->kind = (kind & 0x1f) | ((kind & 0xe0) << 8);
    }
    seg->mapped = 0;
    seg->data = NULL;

    ofs += seg->bytecnt;
    if (last == NULL) {
      segments = seg;
    } else {
      last->next = seg;
    }
    last = seg;
  }
  return segments;
}

static int cmpmemory(const void *p1, const void *p2) {
  const uint32_t *a = p1, *b = p2;
  return *a - *b;
}

static void mapSegments(Segment *segments, uint32_t min) {
  // we use a memory map that denotes runes of available memory.
  // Each segment has a start and end, so we need an array of twice the
  // number of segments (+2 for the absolute start and end of memory)

  // count segments
  uint32_t numSegs = 0;
  for (Segment *seg = segments; seg != NULL; seg = seg->next) {
    numSegs++;
  }

  uint32_t *memory = malloc(sizeof(uint32_t) * (numSegs * 2 + 2));
  int numNodes = 0;
  memory[numNodes++] = min;  // minimum
  memory[numNodes++] = 0x1000000;  // maximum possible memory for the IIgs.

  // step one, map hardcoded or overridden targets
  for (Segment *seg = segments; seg != NULL; seg = seg->next) {
    if (seg->org != 0 || seg->mapped != 0) {
      if (seg->mapped == 0) {
        if ((seg->kind & 0x1f) == 0x11) {  // absolute bank
          seg->mapped = seg->org << 16;
        } else {
          seg->mapped = seg->org;
        }
      }
      bool collision = false;
      // verify we aren't overlapping.. that would be tremendously bad.
      for (int node = 0; node < numNodes; node += 2) {
        if (seg->mapped < memory[node] &&
            seg->mapped + seg->length > memory[node]) {  // crosses!
          collision = true;
        }
        if (seg->mapped < memory[node + 1] &&
            seg->mapped + seg->length > memory[node + 1]) {  // crosses!
          collision = true;
        }
      }
      if (collision) {
        fprintf(stderr, "Segment #$%x collides with another segment!\n",
            seg->segnum);
        exit(-1);
      }
      memory[numNodes++] = seg->mapped;
      memory[numNodes++] = seg->mapped + seg->length;
      if (seg->mapped < memory[0]) {  // below the minimum!
        memory[0] = seg->mapped;  // recalibrate the minimum
      }
      // resort memory map
      qsort(memory, numNodes, sizeof(uint32_t), cmpmemory);
    }
  }

  // finally, map everything else by first fit.
  for (Segment *seg = segments; seg != NULL; seg = seg->next) {
    if (seg->mapped == 0) {
      for (int node = 0; node < numNodes; node += 2) {
        uint32_t base = memory[node];
        if (seg->align && (base & (seg->align - 1))) {  // snap to alignment
          base += seg->align;
          base &= ~(seg->align - 1);
        }
        if (seg->banksize &&(((base & (seg->banksize - 1)) + seg->length) &
              ~(seg->banksize - 1))) {  // crosses bank
          base += seg->banksize;
          base &= ~(seg->banksize - 1);
        }
        // does it fit?
        if (base < memory[node + 1] && memory[node + 1] - base >= seg->length) {
          seg->mapped = base;
          memory[numNodes++] = seg->mapped;
          memory[numNodes++] = seg->mapped + seg->length;
          qsort(memory, numNodes, sizeof(uint32_t), cmpmemory);
          break;
        }
      }
      if (seg->mapped == 0) {
        fprintf(stderr, "Failed to map Segment #$%x, not enough free memory\n",
            seg->segnum);
        exit(-1);
      }
    }
  }
  free(memory);
}

typedef enum {
  DONE = 0x00,
  RELOC = 0xe2,
  INTERSEG = 0xe3,
  DS = 0xf1,
  LCONST = 0xf2,
  cRELOC = 0xf5,
  cINTERSEG = 0xf6,
  SUPER = 0xf7
} SegOp;

static void patch(uint8_t *data, uint8_t numBytes, uint32_t value) {
  for (int i = 0; i < numBytes; i++, value >>= 8) {
    data[i] = value & 0xff;
  }
}

static void hexout(char *p, uint32_t val, int len) {
  p += len;
  while (len-- > 0) {
    char ch = val & 0xf;
    val >>= 4;
    if (ch < 10) {
      *--p = '0' + ch;
    } else {
      *--p = 'a' + (ch - 10);
    }
  }
}

static void relocSegments(Segment *segments, char *prefix) {
  int prefixLen = strlen(prefix);
  char *filename = malloc(prefixLen + 4);
  char *mapname = malloc(prefixLen + 9);

  for (Segment *seg = segments; seg != NULL; seg = seg->next) {
    bool done = false;
    uint32_t pc = seg->mapped;
    uint8_t *p = seg->offset;
    seg->data = calloc(seg->length, 1);

    while (!done) {
      uint8_t opcode = *p++;
      switch (opcode) {
        case DONE:
          done = true;
          break;
        case RELOC:
          {
            uint8_t numBytes = *p++;
            int8_t bitShift = *p++;
            uint32_t offset = r32(p); p += 4;
            uint32_t subOffset = r32(p) + seg->mapped; p += 4;

            if (bitShift < 0) {
              subOffset >>= -bitShift;
            } else {
              subOffset <<= bitShift;
            }
            patch(seg->data + offset, numBytes, subOffset);
          }
          break;
        case INTERSEG:
          {
            uint8_t numBytes = *p++;
            int8_t bitShift = *p++;
            uint32_t offset = r32(p); p += 4;
            p += 2;  // filenum
            uint16_t segnum = r16(p); p += 2;
            uint32_t subOffset = r32(p); p += 4;
            for (Segment *sub = segments; sub != NULL; sub = sub->next) {
              if (sub->segnum == segnum) {
                subOffset += sub->mapped;
                break;
              }
            }
            if (bitShift < 0) {
              subOffset >>= -bitShift;
            } else {
              subOffset <<= bitShift;
            }
            patch(seg->data + offset, numBytes, subOffset);
          }
          break;
        case DS:
          pc += r32(p); p += 4;  // filled with zeros
          break;
        case LCONST:
          {
            uint32_t count = r32(p); p += 4;
            memcpy(seg->data + pc - seg->mapped, p, count); p += count;
            pc += count;
          }
          break;
        case cRELOC:
          {
            uint8_t numBytes = *p++;
            int8_t bitShift = *p++;
            uint16_t offset = r16(p); p += 2;
            uint32_t subOffset = r16(p) + seg->mapped; p += 2;
            if (bitShift < 0) {
              subOffset >>= -bitShift;
            } else {
              subOffset <<= bitShift;
            }
            patch(seg->data + offset, numBytes, subOffset);
          }
          break;
        case cINTERSEG:
          {
            uint8_t numBytes = *p++;
            int8_t bitShift = *p++;
            uint16_t offset = r16(p); p += 2;
            uint8_t segnum = *p++;
            uint32_t subOffset = r16(p); p += 2;
            for (Segment *sub = segments; sub != NULL; sub = sub->next) {
              if (sub->segnum == segnum) {
                subOffset += sub->mapped;
                break;
              }
            }
            if (bitShift < 0) {
              subOffset >>= -bitShift;
            } else {
              subOffset <<= bitShift;
            }
            patch(seg->data + offset, numBytes, subOffset);
          }
          break;
        case SUPER:
          {
            uint32_t superLen = r32(p); p += 4;
            uint8_t *superEnd = p + superLen;
            uint8_t superType = *p++;
            uint32_t superPage = 0;
            while (p < superEnd) {
              uint8_t numOfs = *p++;
              if (numOfs & 0x80) {
                superPage += 256 * (numOfs & 0x7f);
                continue;
              }
              for (int o = 0; o <= numOfs; o++) {
                uint32_t offset = superPage | *p++;
                uint8_t numBytes = 0;
                uint32_t subOffset = r16(seg->data + offset);
                if (superType == 0 || superType == 1) {  // RELOC2 | RELOC3
                  subOffset += seg->mapped;
                  numBytes = 2 + superType;
                } else if (superType < 14) {  // INTERSEG1--12
                  uint8_t segnum = seg->data[offset + 2];
                  for (Segment *sub = segments; sub != NULL; sub = sub->next) {
                    if (sub->segnum == segnum) {
                      subOffset += sub->mapped;
                      break;
                    }
                  }
                  numBytes = 3;
                } else if (superType < 26) {  // INTERSEG13--24
                  uint8_t segnum = superType - 13;
                  for (Segment *sub = segments; sub != NULL; sub = sub->next) {
                    if (sub->segnum == segnum) {
                      subOffset += sub->mapped;
                      break;
                    }
                  }
                  numBytes = 2;
                } else {  // INTERSEG25--36
                  uint8_t segnum = superType - 25;
                  for (Segment *sub = segments; sub != NULL; sub = sub->next) {
                    if (sub->segnum == segnum) {
                      subOffset += sub->mapped;
                      break;
                    }
                  }
                  subOffset >>= 16;
                  numBytes = 2;
                }
                patch(seg->data + offset, numBytes, subOffset);
              }
              superPage += 256;
            }
          }
          break;
        default:
          if (opcode < 0xe0) {
            memcpy(seg->data + pc - seg->mapped, p, opcode); p += opcode;
            pc += opcode;
          } else {
            fprintf(stderr, "Unknown segment code: %x\n", opcode);
            exit(-1);
          }
          break;
      }
    }

    memcpy(filename, prefix, prefixLen);
    int numLen = 3;
    if (seg->segnum < 0x10) {
      numLen = 1;
    } else if (seg->segnum < 0x100) {
      numLen = 2;
    }
    hexout(filename + prefixLen, seg->segnum, numLen);
    filename[prefixLen + numLen] = 0;
    memcpy(mapname, filename, prefixLen + numLen);
    memcpy(mapname + prefixLen + numLen, ".map\0", 5);

    FILE *f = fopen(filename, "wb");
    if (!f) {
      fprintf(stderr, "Failed to create '%s'\n", filename);
      exit(-1);
    }
    fwrite(seg->data, 1, seg->length, f);
    fclose(f);
    f = fopen(mapname, "wb");
    if (!f) {
      fprintf(stderr, "Failed to create '%s'\n", mapname);
      exit(-1);
    }
    fprintf(f, "gMAP \"%s\"\n", filename);
    fprintf(f, "sORG $%x\n", seg->mapped);
    if ((seg->kind & 0x1f) == 0) {  // code
      fprintf(f, "$%x:\n", seg->mapped + seg->entry);
    }
    fclose(f);
    fprintf(stdout, "Extracted Segment #$%x %s into %s\n", seg->segnum,
        seg->name, filename);
    fprintf(stdout, "Created map %s\n", mapname);
  }
  free(filename);
}
