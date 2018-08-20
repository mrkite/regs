#pragma once

/**
 * @copyright 2018 Sean Kasun
 * Routines for parsing simple config files
 */

#include <stdint.h>
#include <stdarg.h>
#include <stdbool.h>

typedef struct {
  uint8_t *start;
  uint8_t *p;
  uint8_t *end;
  const char *filename;
} ConfigFile;

extern void fail(ConfigFile *f, char *format, ...);
extern void eatSpaces(ConfigFile *f);
extern bool token(ConfigFile *f, char ch);
extern uint32_t hex(ConfigFile *f);
