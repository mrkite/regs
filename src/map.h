/** @copyright 2020 Sean Kasun */
#pragma once

#include <cstdint>
#include "disasm.h"

class Map {
 public:
  Map(const char *filename, uint32_t org, uint32_t flags);
};
