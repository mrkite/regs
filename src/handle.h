/** @copyright 2020 Sean Kasun */
#pragma once

#include <memory>

typedef std::shared_ptr<class TheHandle> Handle;

class TheHandle {
 public:
  static Handle createFromFile(const char *filename);
  ~TheHandle();
  bool isOpen() const;
  bool eof() const;
  int64_t tell() const;

  uint32_t r32();
  uint32_t r24();
  uint16_t r16();
  uint8_t r8();
  void seek(int64_t pos);
  void skip(int64_t length);

  int64_t length;

 private:
  explicit TheHandle(const char *filename);
  uint8_t *data, *pos;
};
