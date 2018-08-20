/**
 *  @copyright 2018 Sean Kasun
 *  Extracts 2mg and other prodos disk images into a directory structure
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <argp.h>
#include <stdbool.h>
#include "handle.h"

static void doDirectory(uint16_t key, uint8_t *disk, uint32_t disklen,
    int depth);
static void doEntry(uint8_t *entry, uint8_t *disk, uint32_t disklen,
    int depth);
static void doFile(uint16_t key, uint32_t len, char *name, uint8_t *disk,
    uint32_t disklen, int type);
static void doGSOS(uint16_t key, char *name, uint8_t *disk, uint32_t disklen,
    int depth);

const char *argp_program_version = "2mg 0.2";
const char *argp_program_bug_address = "sean@seancode.com";
static char doc[] = "Extract ProDOS disk images";
static char args_doc[] = "DISKIMAGE";
static struct argp_option options[] = {
  {"list", 'l', 0, 0, "List files"},
  { 0 }
};

struct arguments {
  char *diskimage;
  bool list;
};

static error_t parse_opt(int key, char *arg, struct argp_state *state) {
  struct arguments *arguments = state->input;
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

int main(int argc, char **argv) {
  struct arguments arguments;
  arguments.list = false;

  argp_parse(&argp, argc, argv, 0, 0, &arguments);

  FILE *f = fopen(arguments.diskimage, "rb");
  if (!f) {
    fprintf(stderr, "Failed to open '%s'\n", arguments.diskimage);
    return -1;
  }
  fseek(f, 0, SEEK_END);
  size_t len = ftell(f);
  fseek(f, 0, SEEK_SET);
  if (len < 64) {
    fprintf(stderr, "%s is not a valid disk image\n", argv[1]);
    fclose(f);
    return -1;
  }

  uint8_t *header = malloc(64);
  fread(header, 64, 1, f);

  uint32_t disklen = len;
  uint32_t diskofs = 0;

  if (r4(header) == fourcc("2IMG")) {
    if (r32(header + 0xc) != 1) {
      fprintf(stderr, "Not a ProDOS disk image\n");
      fclose(f);
      return -1;
    }
    disklen = r32(header + 0x14) * 512;
    diskofs = r32(header + 0x18);
  }
  free(header);

  fseek(f, diskofs, SEEK_SET);
  uint8_t *disk = malloc(disklen);
  fread(disk, disklen, 1, f);
  fclose(f);

  doDirectory(2, disk, disklen, arguments.list ? 0 : -1);
  free(disk);
  return 0;
}

static void readFilename(uint8_t *filename, uint8_t length, char *outname) {
  for (int i = 0; i < length; i++) {
    char ch = filename[i];
    if (isalnum(ch) || ch == '_' || ch == '.' || ch == ' ') {
      *outname++ = ch;
    } else {
      *outname++ = 'x';
      char hi = ch >> 4;
      char lo = ch & 0xf;
      if (hi > 9) {
        *outname++ = 'a' + (hi - 10);
      } else {
        *outname++ = '0' + hi;
      }
      if (lo > 9) {
        *outname++ = '0' + (lo - 10);
      } else {
        *outname++ = '0' + lo;
      }
    }
  }
  *outname = 0;
}

static void indent(int depth) {
  for (int i = 0; i < depth; i++) {
    printf("  ");
  }
}

static void doDirectory(uint16_t key, uint8_t *disk, uint32_t disklen,
    int depth) {
  uint8_t *block = disk + key * 512;
  if ((block[4] & 0xf0) != 0xf0 && (block[4] & 0xf0) != 0xe0) {
    fprintf(stderr, "Invalid ProDOS disk\n");
    return;
  }

  char dirname[50];
  readFilename(block + 5, block[4] & 0xf, dirname);

  if (depth < 0) {
    mkdir(dirname, 0777);
    chdir(dirname);
  } else {
    indent(depth);
    printf("%s <dir>\n", dirname);
  }

  uint8_t entryLength = block[0x23];
  uint8_t entriesPerBlock = block[0x24];
  uint16_t fileCount = r16(block + 0x25);
  uint8_t *entry = block + entryLength + 4;
  uint8_t curEntry = 1;
  uint16_t curFile = 0;

  while (curFile < fileCount) {
    if (entry[0] != 0) {
      doEntry(entry, disk, disklen, depth < 0 ? -1 : depth + 1);
      curFile++;
    }
    curEntry++;
    entry += entryLength;
    if (curEntry == entriesPerBlock) {
      curEntry = 0;
      block = disk + r16(block + 2) * 512;
      entry = block + 4;
    }
  }

  if (depth < 0) {
    chdir("..");
  }
}

static void doEntry(uint8_t *entry, uint8_t *disk, uint32_t disklen,
    int depth) {
  uint16_t key = r16(entry + 0x11);
  uint32_t eof = r24(entry + 0x15);

  char filename[50];
  readFilename(entry + 1, entry[0] & 0xf, filename);

  switch (entry[0] & 0xf0) {
    case 0x10:  // seedling
    case 0x20:  // sapling
    case 0x30:  // tree
      if (depth < 0) {
        doFile(key, eof, filename, disk, disklen, entry[0] >> 4);
      } else {
        indent(depth);
        printf("%s   %d bytes\n", filename, eof);
      }
      break;
    case 0x50:
      doGSOS(key, filename, disk, disklen, depth);
      break;
    case 0xd0:
      doDirectory(key, disk, disklen, depth < 0 ? -1 : depth + 1);
      break;
    default:
      fprintf(stderr, "Unknown file type: %x\n", entry[0] & 0xf0);
      return;
  }
}

static void dumpSeedling(uint8_t *block, uint32_t len, FILE *f) {
  if (block == NULL) {
    fseek(f, len, SEEK_CUR);
  } else {
    fwrite(block, len, 1, f);
  }
}

static void dumpSapling(uint8_t *index, uint32_t len, FILE *f, uint8_t *disk,
    uint32_t disklen) {
  if (index == NULL) {
    fseek(f, len, SEEK_CUR);
    return;
  }

  while (len > 0) {
    uint16_t blockid = index[0] | (index[256] << 8);
    uint8_t *block = NULL;
    if (blockid && (blockid + 1) * 512 <= disklen) {
      block = disk + blockid * 512;
    }
    uint32_t blen = len > 512 ? 512 : len;
    dumpSeedling(block, blen, f);
    len -= blen;
    index++;
  }
}

static void dumpTree(uint8_t *index, uint32_t len, FILE *f, uint8_t *disk,
    uint32_t disklen) {
  if (index == NULL) {
    fseek(f, len, SEEK_CUR);
    return;
  }

  while (len > 0) {
    uint16_t blockid = index[0] | (index[256] << 8);
    uint8_t *block = NULL;
    if (blockid && (blockid + 1) * 512 <= disklen) {
      block = disk + blockid * 512;
    }
    uint32_t blen = len > 256 * 512 ? 256 * 512 : len;
    dumpSapling(block, blen, f, disk, disklen);
    len -= blen;
    index++;
  }
}

static void doGSOS(uint16_t key, char *name, uint8_t *disk,
    uint32_t disklen, int depth) {
  uint8_t *block = disk + key * 512;
  int type = *block;
  uint16_t subkey = r16(block + 1);
  uint32_t eof = r24(block + 5);
  if (depth < 0) {
    doFile(subkey, eof, name, disk, disklen, type);
  }

  char resname[50];
  strncpy(resname, name, 50);
  strncat(resname, ".res", 50);
  block = disk + key * 512 + 0x100;
  type = *block;
  subkey = r16(block + 1);
  uint32_t reof = r24(block + 5);
  if (depth < 0) {
    doFile(subkey, reof, resname, disk, disklen, type);
  } else {
    indent(depth);
    printf("%s   %d bytes   resource: %d bytes\n", name, eof, reof);
  }
}

static void doFile(uint16_t key, uint32_t len, char *name, uint8_t *disk,
    uint32_t disklen, int type) {
  uint8_t *block = disk + key * 512;
  FILE *f = fopen(name, "wb");
  if (!f) {
    fprintf(stderr, "Failed to create '%s'\n", name);
    return;
  }

  switch (type) {
    case 1:
      dumpSeedling(block, len, f);
      break;
    case 2:
      dumpSapling(block, len, f, disk, disklen);
      break;
    case 3:
      dumpTree(block, len, f, disk, disklen);
      break;
  }
  fclose(f);
}
