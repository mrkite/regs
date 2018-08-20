#pragma once

/**
 * @copyright 2018 Sean Kasun
 * The main disassembler.
 */

#include "map.h"

extern void disassemble(uint8_t *data, size_t len, Map *map);
