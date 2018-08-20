#pragma once

/**
 * @copyright 2018 Sean Kasun
 * The memory map for the tracing disassembler
 */

#include <stdint.h>

typedef enum {
  IsData = 0x01,
  IsOpcode = 0x02,
  IsOperand = 0x04,
  IsX8 = 0x10,
  IsM8 = 0x20,
  IsEmu = 0x100
} MapFlags;

typedef struct Rule {
  uint32_t address;
  uint16_t flags;
  struct Rule *next;
} Rule;

typedef struct {
  Rule *rules;
  uint32_t minMemory;
  uint32_t maxMemory;
  MapFlags *mem;
  const char *filename;
} Map;

extern Map *loadMap(const char *filename, uint32_t org, MapFlags flags);
