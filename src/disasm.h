/** @copyright 2020 Sean Kasun */
#pragma once

#include <cstdint>

enum {
  IsX8 = 0x10,
  IsM8 = 0x20,
  IsEmu = 0x100,
  IsFlags = 0xff0130,
  IsX8Changed = 0x200,
  IsM8Changed = 0x400,
  IsEmuChanged = 0x2000,
};
