/** @copyright 2020 Sean Kasun */
#pragma once

#include "handle.h"
#include "map.h"
#include <vector>
#include <string>

struct Segment {
  int32_t bytecnt;
  int32_t resspc;
  int32_t length;
  int8_t lablen;
  int8_t numlen;
  int16_t banksize;
  int16_t kind;
  int32_t org;
  int32_t align;
  int16_t segnum;
  int32_t entry;
  std::string name;
  int64_t offset;
  Handle data;
  int32_t mapped;
};

class OMF {
 public:
  explicit OMF();
  bool load(const char *filename, uint32_t org);
  std::vector<Segment> get() const;

 private:
  bool isOMF();
  bool loadSegments();
  bool mapSegments();
  bool relocSegments();
  void patch(std::vector<uint8_t> &array, uint32_t offset, uint8_t numBytes,
             uint32_t value);

  Handle handle;
  std::vector<Segment> segments;
};
