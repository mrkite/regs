/**
 * @copyright 2018 Sean Kasun
 * Routines for parsing a simple config file
 */

#include "parser.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

void fail(ConfigFile *f, char *format, ...) {
  // calculate line and column
  int line = 1;
  int col = 1;
  bool done = false;
  while (f->p > f->start) {
    if (*f->p == '\n') {
      done = true;
      line++;
    }
    if (!done) {
      col++;
    }
    f->p--;
  }
  va_list args;
  va_start(args, format);
  fprintf(stderr, "%s[%d,%d] Error: ", f->filename, line, col);
  vfprintf(stderr, format, args);
  fprintf(stderr, "\n");
  va_end(args);
  exit(-1);
}

void eatSpaces(ConfigFile *f) {
  while (f->p < f->end && isspace(*f->p)) {
    f->p++;
  }
}

bool token(ConfigFile *f, char ch) {
  eatSpaces(f);
  if (f->p < f->end && *f->p == ch) {  // found it, consume
    f->p++;
    return true;
  }
  // not found, don't consume anything
  return false;
}

uint32_t hex(ConfigFile *f) {
  eatSpaces(f);
  uint32_t res = 0;
  while (f->p < f->end && isxdigit(*f->p)) {
    res <<= 4;
    if (*f->p >= '0' && *f->p <= '9') {
      res |= *f->p - '0';
    } else if (*f->p >= 'a' && *f->p <= 'f') {
      res |= *f->p - 'a' + 10;
    } else if (*f->p >= 'A' && *f->p <= 'F') {
      res |= *f->p - 'A' + 10;
    }
    f->p++;
  }
  return res;
}
