/**
 * @copyright 2018 Sean Kasun
 * The main disassembler.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "disasm.h"
#include "65816.h"
#include "handle.h"
#include "addresses.h"
#include "prodos8.h"
#include "prodos16.h"
#include "smartport.h"
#include "tools.h"

static void dumphex(uint8_t *ptr, uint32_t addr, uint32_t len) {
  uint8_t *eof = ptr + len;
  for (int line = 0; ptr < eof; line++) {
    printf("%02x/%04x: ", addr >> 16, addr & 0xffff);
    uint8_t *p = ptr;
    int skip = addr & 0xf;
    int i = 0;
    for (; i < skip; i++) {
      if (i == 8) {
        printf(" ");
      }
      printf("   ");
    }
    for (; i < 16 && p < eof; i++) {
      if (i == 8) {
        printf(" ");
      }
      printf("%02x ", *p++);
    }
    for (; i < 16; i++) {
      if (i == 8) {
        printf(" ");
      }
      printf("   ");
    }
    printf("| ");
    i = 0;
    for (; i < skip; i++) {
      if (i == 8) {
        printf(" ");
      }
      printf(" ");
    }
    for (; i < 16 && ptr < eof; i++) {
      if (i == 8) {
        printf(" ");
      }
      uint8_t c = *ptr++;
      addr++;
      printf("%c", (c >= ' ' && c <= '~') ? c : '.');
    }
    printf("\n");
  }
}

void disassemble(uint8_t *data, size_t len, Map *map) {
  uint8_t *ptr = data;
  uint8_t *end = data + len;

  uint16_t x = 0;
  uint32_t val;
  int8_t delta;
  int16_t delta16;
  uint32_t d6;
  bool smart = false, dos8 = false, dos16 = false;

  uint32_t addr = map->minMemory;

  while (ptr < end) {
    MapFlags flags = map->mem[addr - map->minMemory];
    if ((flags & IsOpcode) || smart || dos8 || dos16) {
      printf("%02x/%04x:", addr >> 16, addr & 0xffff);
      uint8_t *start = ptr;
      uint8_t opcode = *ptr++;

      const char *inst = opcodes[opcode].inst;
      Address mode = opcodes[opcode].address;
      OpType type = opcodes[opcode].type;

      if (smart || dos8) {
        mode = DB;
        inst = "db";
      }
      if (dos16) {
        mode = DW;
        inst = "dw";
      }

      uint16_t width = addressSizes[mode];
      if (mode == IMMM && (flags & (IsEmu | IsM8))) {
        width--;
      }
      if (mode == IMMX && (flags & (IsEmu | IsX8))) {
        width--;
      }
      addr += width;
      flags &= IsFlags;   // clear changed flags
      MapFlags oldFlags = flags;

      for (int i = 0; i < width; i++) {
        printf(" %02x", start[i]);
      }
      for (int i = 0; i < 4 - width; i++) {
        printf("   ");
      }
      printf(" %s", inst);
      for (int i = strlen(inst); i < 8; i++) {
        printf(" ");
      }

      const char *comments = NULL;
      uint8_t oprlen = 0;
      uint8_t oper = 0;

      switch (mode) {
        case IMP:
          break;
        case IMM:
          oper = *ptr++;
          printf("#$%02x", oper);
          oprlen = 4;
          if (opcode == 0xe2) {
            flags |= oper & IsFlags;
          } else if (opcode == 0xc2) {
            flags &= ~oper;
          }
          if ((flags ^ oldFlags) & IsX8) {
            flags |= IsX8Changed;
          }
          if ((flags ^ oldFlags) & IsM8) {
            flags |= IsM8Changed;
          }
          break;
        case IMMM:
          if (flags & (IsEmu | IsM8)) {
            printf("#$%02x", *ptr++);
            oprlen = 4;
          } else {
            val = r16(ptr); ptr += 2;
            printf("#$%04x", val);
            oprlen = 6;
            comments = addressLookup(val, map);
          }
          break;
        case IMMX:
          if (flags & (IsEmu | IsX8)) {
            x = *ptr++;
            printf("#$%02x", x);
            oprlen = 4;
          } else {
            x = r16(ptr); ptr += 2;
            printf("#$%04x", x);
            oprlen = 6;
            comments = addressLookup(x, map);
          }
          break;
        case IMMS:
          val = r16(ptr); ptr += 2;
          printf("#$%04x", val);
          oprlen = 6;
          comments = addressLookup(x, map);
          break;
        case ABS:
          val = r16(ptr); ptr += 2;
          if (type == JUMP || type == CALL) {
            val |= addr & 0xff0000;  // K
          } else {
            val |= flags & 0xff0000;  // B
          }
          printf("$%02x/%04x", val >> 16, val & 0xffff);
          oprlen = 8;
          comments = addressLookup(val, map);
          break;
        case ABL:
          val = r24(ptr); ptr += 3;
          printf("$%02x/%04x", val >> 16, val & 0xffff);
          oprlen = 8;
          comments = addressLookup(val, map);
          break;
        case ABX:
          val = r16(ptr); ptr += 2;
          if (type == JUMP || type == CALL) {
            val |= addr & 0xff0000;  // K
          } else {
            val |= flags & 0xff0000;  // B
          }
          printf("$%02x/%04x, x", val >> 16, val & 0xffff);
          oprlen = 11;
          comments = addressLookup(val, map);
          break;
        case ABY:
          val = r16(ptr); ptr += 2;
          if (type == JUMP || type == CALL) {
            val |= addr & 0xff0000;  // K
          } else {
            val |= flags & 0xff0000;  // B
          }
          printf("$%02x/%04x, y", val >> 16, val & 0xffff);
          oprlen = 11;
          comments = addressLookup(val, map);
          break;
        case ABLX:
          val = r24(ptr); ptr += 3;
          printf("$%02x/%04x, x", val >> 16, val & 0xffff);
          oprlen = 11;
          comments = addressLookup(val, map);
          break;
        case AIX:
          val = r16(ptr); ptr += 2;
          if (type == JUMP || type == CALL) {
            val |= addr & 0xff0000;  // K
          } else {
            val |= flags & 0xff0000;  // B
          }
          printf("($%02x/%04x, x)", val >> 16, val & 0xffff);
          oprlen = 13;
          comments = addressLookup(val, map);
          break;
        case ZP:
          printf("$%02x", *ptr++);
          oprlen = 3;
          break;
        case ZPX:
          printf("$%02x, x", *ptr++);
          oprlen = 6;
          break;
        case ZPY:
          printf("$%02x, y", *ptr++);
          oprlen = 6;
          break;
        case ZPS:
          printf("$%02x, s", *ptr++);
          oprlen = 6;
          break;
        case IND:
          val = r16(ptr); ptr += 2;
          if (type == JUMP || type == CALL) {
            val |= addr & 0xff0000;  // K
          } else {
            val |= flags & 0xff0000;  // B
          }
          printf("($%02x/%04x)", val >> 16, val & 0xffff);
          oprlen = 10;
          comments = addressLookup(val, map);
          break;
        case INZ:
          printf("($%02x)", *ptr++);
          oprlen = 5;
          break;
        case INL:
          printf("[$%02x]", *ptr++);
          oprlen = 5;
          break;
        case INX:
          printf("($%02x, x)", *ptr++);
          oprlen = 8;
          break;
        case INY:
          printf("($%02x), y", *ptr++);
          oprlen = 8;
          break;
        case INLY:
          printf("[$%02x], y", *ptr++);
          oprlen = 8;
          break;
        case INS:
          printf("($%02x, s), y", *ptr++);
          oprlen = 11;
          break;
        case REL:
          delta = *ptr++;
          d6 = delta + addr;
          printf("$%02x/%04x", d6 >> 16, d6 & 0xffff);
          oprlen = 8;
          comments = addressLookup(d6, map);
          break;
        case RELL:
          delta16 = r16(ptr); ptr += 2;
          d6 = delta16 + addr;
          printf("$%02x/%04x", d6 >> 16, d6 & 0xffff);
          oprlen = 8;
          comments = addressLookup(d6, map);
          break;
        case BANK:
          val = *ptr++;
          printf("$%02x, $%02x", *ptr++, val);
          oprlen = 8;
          break;
        case DB:
          printf("$%02x", opcode);
          oprlen = 3;
          break;
        case DW:
          val = opcode | (*ptr++ << 8);
          printf("$%04x", val);
          oprlen = 5;
          break;
        case DD:
          printf("$%08x", opcode | r24(ptr) << 8); ptr += 3;
          oprlen = 9;
          break;
      }


      if (smart) {
        comments = smartportLookup(opcode);
        smart = false;
      }
      if (dos8) {
        comments = prodos8Lookup(opcode);
        dos8 = false;
      }
      if (dos16) {
        comments = prodos16Lookup(val);
        dos16 = false;
      }

      // track plb
      if (opcode == 0xab) {  // plb, was it previously a9 xx 48?
        bool bset = false;
        ptr -= 4;
        uint8_t lda = *ptr++;
        uint8_t b = *ptr++;
        uint8_t pha = *ptr++;
        ptr++;
        if (lda == 0xa9 && pha == 0x48) {
          flags &= 0xffff;
          flags |= b << 16;  // set B
          bset = true;
        }
        if (!bset) {
          ptr -= 2;
          uint8_t phk = *ptr++;
          ptr++;
          if (phk == 0x4b) {
            flags &= 0xffff;
            flags |= addr & 0xff0000;  // B = K
            bset = true;
          }
        }
        if (!bset) {
          ptr -= 7;
          uint8_t lda = *ptr++;
          uint8_t b = r16(ptr); ptr += 2;
          ptr += 2;  // sep #20
          uint8_t pha = *ptr++;
          ptr++;
          if (lda == 0xa9 && pha == 0x48) {
            flags &= 0xffff;
            flags |= b << 16;  // set B
            bset = true;
          }
        }
      }

      if (opcode == 0x18) {
        if (*ptr == 0xfb) {  // clc xce = 16 bit mode
          flags &= 0xffffff ^ IsEmu;
        }
      }
      if (opcode == 0x38) {
        if (*ptr == 0xfb) {  // sec xce = 8 bit mode
          flags |= IsEmu;
        }
      }
      if ((flags ^ oldFlags) & IsEmu) {
        flags |= IsEmuChanged;
      }

      if (opcode == 0xa2) {  // ldx
        if (*ptr == 0x22) {  // jsl
          if (r24(ptr + 1) == 0xe10000) {  // jsl el/0000
            comments = toolLookup(x);
          }
        }
      }
      if (opcode == 0x20) {  // jsr
        if (val == 0xc50d || val == 0xc70d) {
          smart = true;
        }
        if (val == 0xbf00) {
          dos8 = true;
        }
      }
      if (opcode == 0x22) {  // jsl
        if (val == 0xe100a8) {
          dos16 = true;
        }
      }

      if (flags & (IsEmuChanged | IsM8Changed | IsX8Changed)) {
        for (int i = oprlen; i < 16; i++) {
          printf(" ");
        }
        printf("; ");
      }

      if (flags & IsEmuChanged) {
        if (flags & IsEmu) {
          printf(" 8-bit mode");
        } else {
          printf(" 16-bit mode");
        }
      }
      if (flags & IsM8Changed) {
        if (flags & IsM8) {
          printf(" a.b");
        } else {
          printf(" a.w");
        }
      }
      if (flags & IsX8Changed) {
        if (flags & IsX8) {
          printf(" x.b");
        } else {
          printf(" x.w");
        }
      }

      if (comments != NULL) {
        for (int i = oprlen; i < 16; i++) {
          printf(" ");
        }
        printf("; %s", comments);
      }
      printf("\n");
    } else {
      uint32_t dlen = 0;
      uint8_t *p = ptr;
      while (p < end && !(map->mem[addr + dlen - map->minMemory] & IsOpcode)) {
        p++;
        dlen++;
      }
      uint32_t val;
      switch (dlen) {
        case 4:
          printf("%02x/%04x:", addr >> 16, addr & 0xffff);
          val = r32(ptr);
          printf(" %02x %02x %02x %02x dd      $%08x\n", val & 0xff,
              (val >> 8) & 0xff, (val >> 16) & 0xff, val >> 24, val);
          break;
        case 2:
          printf("%02x/%04x:", addr >> 16, addr & 0xffff);
          val = r16(ptr);
          printf(" %02x %02x       dw      $%04x\n", val & 0xff, val >> 8, val);
          break;
        case 1:
          printf("%02x/%04x:", addr >> 16, addr & 0xffff);
          printf(" %02x          db      $%04x\n", *ptr, *ptr);
          break;
        default:
          dumphex(ptr, addr, dlen);
          break;
      }
      ptr += dlen;
      addr += dlen;
    }
  }
}
