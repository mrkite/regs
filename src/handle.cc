/** @copyright 2020 Sean Kasun */

#include <fstream>
#include "handle.h"

Handle TheHandle::createFromFile(const char *filename) {
  return std::shared_ptr<TheHandle>(new TheHandle(filename));
}

Handle TheHandle::createFromArray(const std::vector<uint8_t> &data) {
  return std::shared_ptr<TheHandle>(new TheHandle(data));
}

TheHandle::TheHandle(const char *filename) {
  data = pos = nullptr;
  std::ifstream f(filename, std::ios::in | std::ios::binary | std::ios::ate);
  if (!f.is_open()) {
    return;
  }
  length = f.tellg();
  data = new uint8_t[length];
  f.seekg(0, std::ios::beg);
  f.read(reinterpret_cast<char*>(data), length);
  f.close();
  pos = data;
}

TheHandle::TheHandle(const std::vector<uint8_t> &data) {
  length = data.size();
  this->data = new uint8_t[length];
  std::copy(data.begin(), data.end(), this->data);
  pos = this->data;
}

TheHandle::~TheHandle() {
  if (data != nullptr) {
    delete [] data;
  }
}

bool TheHandle::isOpen() const {
  return data != nullptr;
}

bool TheHandle::eof() const {
  return pos - data >= length;
}

int64_t TheHandle::tell() const {
  return pos - data;
}

uint32_t TheHandle::r32() {
  uint32_t r = *pos++;
  r |= *pos++ << 8;
  r |= *pos++ << 16;
  r |= *pos++ << 24;
  return r;
}

uint32_t TheHandle::r24() {
  uint32_t r = *pos++;
  r |= *pos++ << 8;
  r |= *pos++ << 16;
  return r;
}

uint16_t TheHandle::r16() {
  uint16_t r = *pos++;
  r |= *pos++ << 8;
  return r;
}

uint8_t TheHandle::r8() {
  return *pos++;
}

std::string TheHandle::rs() {
  std::string r;
  uint8_t len = *pos++;
  for (auto i = 0; i < len; i++) {
    r += static_cast<char>(*pos++);
  }
  return r;
}

std::string TheHandle::read(int32_t len) {
  std::string r;
  for (auto i = 0; i < len; i++) {
    r += static_cast<char>(*pos++);
  }
  return r;
}

std::vector<uint8_t> TheHandle::readBytes(int32_t len) {
  std::vector<uint8_t> r(pos, pos + len);
  pos += len;
  return r;
}

void TheHandle::seek(int64_t pos) {
  this->pos = data + pos;
}

void TheHandle::skip(int64_t ofs) {
  pos += ofs;
}
