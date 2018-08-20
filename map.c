/**
 * @copyright 2018 Sean Kasun
 * Handles the memory map, for the tracing disassembler.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include "map.h"
#include "parser.h"
#include "handle.h"

static Rule *parseRule(ConfigFile *f) {
  Rule *rule = malloc(sizeof(Rule));
  rule->next = NULL;
  if (!token(f, '$')) {
    fail(f, "Address must be a hex value above 0 \n"
       "starting with '$', i.e. $c20");
  }
  rule->address = hex(f);
  if (token(f, '/')) {
    rule->address <<= 16;
    rule->address |= hex(f);
  }
  if (rule->address == 0) {
    fail(f, "Address must be a hex value above 0 \n"
       "starting with '$', i.e. $c20");
  }
  if (!token(f, ':')) {
    fail(f, "Expected ':'");
  }
  rule->flags = IsOpcode;
  bool foundFlag = false;
  do {
    foundFlag = false;
    if (token(f, 'e')) {
      rule->flags |= IsEmu;
      foundFlag = true;
    }
    if (token(f, 'm')) {
      rule->flags |= IsM8;
      foundFlag = true;
    }
    if (token(f, 'x')) {
      rule->flags |= IsX8;
      foundFlag = true;
    }
  } while (foundFlag);
  return rule;
}

Map *loadMap(const char *filename, uint32_t org, MapFlags flags) {
  Map *map = malloc(sizeof(Map));
  map->rules = NULL;
  map->minMemory = org;
  map->maxMemory = 0;
  map->mem = NULL;

  FILE *f = fopen(filename, "rb");
  if (!f) {
    fprintf(stderr, "Failed to open '%s'\n", filename);
    exit(-1);
  }
  fseek(f, 0, SEEK_END);
  size_t len = ftell(f);
  fseek(f, 0, SEEK_SET);
  uint8_t *data = malloc(len);
  fread(data, len, 1, f);
  fclose(f);

  if (r4(data) != fourcc("gMAP")) {
    // not a map file, use org as the only entry point
    map->rules = malloc(sizeof(Rule));
    map->rules->address = org;
    map->rules->flags = flags;
    map->rules->next = NULL;
    map->filename = filename;
    free(data);
    return map;
  }
  ConfigFile c;
  c.start = data;
  c.p = c.start;
  c.end = c.start + len;
  c.filename = filename;

  // set filename
  c.p += 4;
  eatSpaces(&c);
  if (!token(&c, '"')) {
    fail(&c, "Expected '\"' around the filename.");
  }
  uint8_t *fnp = c.p;
  while (fnp < c.end && *fnp != '"') {
    fnp++;
  }
  if (fnp == c.end) {
    fail(&c, "Filename has no closing '\"'.");
  }
  int flen = fnp - c.p;
  char *fname = malloc(flen);
  memcpy(fname, c.p, flen);
  fname[flen] = 0;
  map->filename = fname;
  c.p = fnp + 1;

  eatSpaces(&c);
  if (r4(c.p) != fourcc("sORG")) {
    fail(&c, "Expected 'sORG' tag");
  }
  c.p += 4;
  eatSpaces(&c);
  if (!token(&c, '$')) {
    fail(&c, "ORG must be a hex value above 0\n"
       "starting with '$', i.e. $c20");
  }
  map->minMemory = hex(&c);
  if (map->minMemory == 0) {
    fail(&c, "ORG must be a hex value above 0\n"
       "starting with '$', i.e. $c20");
  }
  eatSpaces(&c);

  // load rules
  Rule *lastRule = NULL;
  while (c.p < c.end) {
    Rule *rule = parseRule(&c);
    if (lastRule == NULL) {
      map->rules = rule;
    } else {
      lastRule->next = rule;
    }
    lastRule = rule;
    eatSpaces(&c);
  }
  free(c.start);

  return map;
}
