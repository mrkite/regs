/**
 * @copyright 2018 Sean Kasun
 * The tracing scanner.
 */
#include "scan.h"
#include "65816.h"
#include "handle.h"

typedef struct {
  uint32_t address;
  MapFlags flags;
} Scan;

typedef struct {
  uint32_t max;
  uint32_t num;
  Scan *values;
} List;

static void initList(List *list) {
  list->max = 1024;
  list->num = 0;
  list->values = malloc(sizeof(Scan) * list->max);
}

static void freeList(List *list) {
  free(list->values);
}

static void appendList(List *list, uint32_t address, MapFlags flags) {
  list->values[list->num].address = address;
  list->values[list->num].flags = flags;
  list->num++;
  if (list->num == list->max) {
    list->max *= 1.6;
    list->values = realloc(list->values, sizeof(Scan) * list->max);
  }
}

static uint32_t fillMem(uint32_t address, int len, MapFlags flags, Map *map) {
  for (int i = 0; i < len; i++) {
    map->mem[address++ - map->minMemory] = flags;
  }
  return address;
}

void scan(uint8_t *data, size_t len, Map *map) {
  List toScan;
  initList(&toScan);
  map->maxMemory = map->minMemory + len;

  map->mem = calloc(len, sizeof(MapFlags));

  for (Rule *rule = map->rules; rule != NULL; rule = rule->next) {
    appendList(&toScan, rule->address, rule->flags);
  }

  while (toScan.num > 0) {
    toScan.num--;
    MapFlags flags = toScan.values[toScan.num].flags;
    uint32_t address = toScan.values[toScan.num].address;

    while (address < map->maxMemory) {
      uint8_t *ptr = data + address - map->minMemory;

      uint8_t opcode = *ptr++;
      if (map->mem[address - map->minMemory] & IsOperand) {
        // we jumped into the middle of an opcode.. go backward to clear it
        uint32_t offset = (address - map->minMemory) - 1;
        while (offset > 0 && (map->mem[offset] & IsOperand)) {
          map->mem[offset--] = IsData;
        }
        map->mem[offset] = IsData;  // overwrite the opcode too.
      }

      Address mode = opcodes[opcode].address;
      OpType type = opcodes[opcode].type;
      if (address + addressSizes[mode] > map->maxMemory) {
        mode = DB;
      }

      uint16_t width = addressSizes[mode];
      if (mode == IMMM && (flags & (IsEmu | IsM8))) {
        width--;
      }
      if (mode == IMMX && (flags & (IsEmu | IsX8))) {
        width--;
      }

      if (mode == DB) {
        map->mem[address++ - map->minMemory] = IsData;
      } else {
        map->mem[address++ - map->minMemory] = IsOpcode |
          (flags & (IsEmu | IsX8 | IsM8));
        address = fillMem(address, width - 1, IsOperand, map);
      }

      uint32_t val = 0;
      int8_t delta;
      int16_t delta16;

      switch (mode) {
        case IMM:
          val = *ptr++;
          if (opcode == 0xe2) {
            flags |= val;
          } else if (opcode == 0xc2) {
            flags &= ~val;
          }
          break;
        case IMMM:
          if (flags & (IsEmu | IsM8)) {
            val = *ptr++;
          } else {
            val = r16(ptr); ptr += 2;
          }
          break;
        case IMMX:
          if (flags & (IsEmu | IsX8)) {
            val = *ptr++;
          } else {
            val = r16(ptr); ptr += 2;
          }
          break;
        case IMMS:
          val = r16(ptr); ptr += 2;
          break;
        case ABS:
          val = r16(ptr); ptr += 2;
          val |= address & 0xff0000;
          break;
        case ABL:
          val = r24(ptr); ptr += 3;
          break;
        case REL:
          delta = *ptr++;
          val = delta + address;
          break;
        case RELL:
          delta16 = r16(ptr); ptr += 2;
          val = delta16 + address;
          break;
        default:
          break;
      }

      if (opcode == 0x18 && *ptr == 0xfb) {  // clc xce
        flags &= ~IsEmu;  // 16-bit
      }
      if (opcode == 0x38 && *ptr == 0xfb) {  // sec xce
        flags |= IsEmu;  // 8-bit
      }

      if (opcode == 0x20) {  // jsr
        if ((val & 0xffff) == 0xc50d || (val & 0xffff) == 0xc70d) {  // disk
          address = fillMem(address, 3, IsData, map);  // db, dw
          if (*ptr++ >= 0x40) {
            address = fillMem(address, 2, IsData, map);  // dw
          }
        }
        if ((val & 0xffff) == 0xbf00) {  // prodos8
          address = fillMem(address, 3, IsData, map);  // db, dw
        }
      }
      if (opcode == 0x22) {  // jsl
        if (val == 0xe100a8) {
          address = fillMem(address, 6, IsData, map);  // dw, dd
        }
      }

      if (type == BRANCH || (type == CALL && mode != AIX) ||
          (type == JUMP && mode != IND && mode != AIX)) {
        if (val >= map->minMemory && val < map->maxMemory &&
            !(map->mem[val - map->minMemory] & IsOpcode)) {
          appendList(&toScan, val, flags);
        }
      }
      if (type == BREAK || type == RETURN || type == JUMP) {
        break;
      }
    }
  }

  freeList(&toScan);
}
