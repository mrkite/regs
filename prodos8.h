#pragma once

/**
 * @copyright 2018 Sean Kasun
 * Defines the ProDOS 8 tool calls
 */

typedef struct {
  uint16_t call;
  const char *name;
} Prodos8;

static Prodos8 prodos8[] = {
  {0x0040, "ALLOC_INTERRUPT"},
  {0x0041, "DEALLOC_INTERRUPT"},
  {0x0042, "AppleTalk"},
  {0x0043, "SpecialOpenFork"},
  {0x0044, "ByteRangeLock"},
  {0x0065, "QUIT"},
  {0x0080, "READ_BLOCK"},
  {0x0081, "WRITE_BLOCK"},
  {0x0082, "GET_TIME"},
  {0x00c0, "CREATE"},
  {0x00c1, "DESTROY"},
  {0x00c2, "RENAME"},
  {0x00c3, "SetFileInfo"},
  {0x00c4, "GetFileInfo"},
  {0x00c5, "ONLINE"},
  {0x00c6, "SET_PREFIX"},
  {0x00c7, "GET_PREFIX"},
  {0x00c8, "OPEN"},
  {0x00c9, "NEWLINE"},
  {0x00ca, "READ"},
  {0x00cb, "WRITE"},
  {0x00cc, "CLOSE"},
  {0x00cd, "FLUSH"},
  {0x00ce, "SET_MARK"},
  {0x00cf, "GET_MARK"},
  {0x00d0, "SET_EOF"},
  {0x00d1, "GET_EOF"},
  {0x00d2, "SET_BUF"},
  {0x00d3, "GET_BUF"}
};

#define numProdos8 (sizeof(prodos8) / sizeof(prodos8[0]))

static const char *prodos8Lookup(uint16_t call) {
  for (int i = 0; i < numProdos8; i++) {
    if (prodos8[i].call >= call) {
      if (prodos8[i].call == call)
        return prodos8[i].name;
      break;
    }
  }
  return NULL;
}
