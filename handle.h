#pragma once

/**
 * @copyright 2018 Sean Kasun
 * Routines for reading multi-byte numbers from a stream
 */

#include <stdint.h>

static inline uint32_t fourcc(const char *p) {
  return (p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3];
}

static inline uint16_t r16(uint8_t *p) {
  uint16_t r = *p++;
  r |= *p << 8;
  return r;
}

static inline uint32_t r24(uint8_t *p) {
  uint32_t r = *p++;
  r |= *p++ << 8;
  r |= *p << 16;
  return r;
}

static inline uint32_t r32(uint8_t *p) {
  uint32_t r = *p++;
  r |= *p++ << 8;
  r |= *p++ << 16;
  r |= *p << 24;
  return r;
}

static inline uint32_t r4(uint8_t *p) {
  uint32_t r = *p++ << 24;
  r |= *p++ << 16;
  r |= *p++ << 8;
  r |= *p;
  return r;
}
