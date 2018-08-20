#pragma once

/**
 * @copyright 2018 Sean Kasun
 * Defines the SmartPort tool calls
 */

typedef struct {
  uint8_t call;
  const char *name;
} SmartPort;

static SmartPort smartport[] = {
  {0x00, "Status"},
  {0x01, "Read"},
  {0x02, "Write"},
  {0x03, "Format"},
  {0x04, "Control"},
  {0x05, "Init"},
  {0x06, "Open"},
  {0x07, "Close"},
  {0x08, "Read"},
  {0x09, "Write"},
  {0x40, "Status"},
  {0x41, "Read"},
  {0x42, "Write"},
  {0x43, "Format"},
  {0x44, "Control"},
  {0x45, "Init"},
  {0x46, "Open"},
  {0x47, "Close"},
  {0x48, "Read"},
  {0x49, "Write"}
};

#define numSmartPort (sizeof(smartport) / sizeof(smartport[0]))

static const char *smartportLookup(uint8_t call) {
  for (int i = 0; i < numSmartPort; i++) {
    if (smartport[i].call >= call) {
      if (smartport[i].call == call)
        return smartport[i].name;
      break;
    }
  }
  return NULL;
}
