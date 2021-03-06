/** @copyright 2020 Sean Kasun */
#include "omf.h"
#include <algorithm>

enum SegOp {
  DONE = 0x00,
  RELOC = 0xe2,
  INTERSEG = 0xe3,
  DS = 0xf1,
  LCONST = 0xf2,
  cRELOC = 0xf5,
  cINTERSEG = 0xf6,
  SUPER = 0xf7,
};

OMF::OMF() {
}

static bool compareSegments(const Segment &a, const Segment &b) {
  return a.mapped < b.mapped;
}

bool OMF::load(const char *filename, uint32_t org) {
  handle = TheHandle::createFromFile(filename);
  if (!handle->isOpen()) {
    return false;
  }

  if (!isOMF()) {
    Segment seg;
    seg.bytecnt = handle->length;
    seg.kind = 0;  // code
    seg.entry = 0;
    seg.mapped = org;
    seg.data = handle;
    seg.length = seg.bytecnt;
    seg.segnum = 1;
    segments.push_back(seg);
  } else {
    if (!loadSegments()) {
      return false;
    }
    if (!mapSegments()) {
      return false;
    }
    if (!relocSegments()) {
      return false;
    }
  }
  std::sort(segments.begin(), segments.end(), compareSegments);
  return true;
}

bool OMF::isOMF() {
  if (handle->length < 32) {
    return false;
  }
  uint64_t ofs = 0;
  for (ofs = 0; ofs < handle->length - 16;) {
    handle->seek(ofs);
    uint32_t bytecnt = handle->r32();
    handle->skip(11);
    uint8_t version = handle->r8();
    if (version == 1) {
      ofs += bytecnt * 512;
    } else if (version == 2) {
      ofs += bytecnt;
    } else {
      return false;
    }
  }
  return ofs == handle->length;
}

bool OMF::loadSegments() {
  handle->seek(0);
  for (uint64_t ofs = 0; ofs < handle->length;) {
    Segment seg;
    handle->seek(ofs);
    seg.bytecnt = handle->r32();
    seg.resspc = handle->r32();
    seg.length = handle->r32();
    auto kind = handle->r8();
    seg.lablen = handle->r8();
    seg.numlen = handle->r8();
    auto version = handle->r8();
    seg.banksize = handle->r32();
    seg.kind = handle->r16();
    handle->skip(2);  // undefined
    seg.org = handle->r32();
    seg.align = handle->r32();
    handle->skip(2);  // byte ordering
    seg.segnum = handle->r16();
    seg.entry = handle->r32();
    auto dispname = handle->r16();
    auto dispdata = handle->r16();
    if (seg.lablen == 0) {
      handle->seek(ofs + dispname + 0xa);
      seg.lablen = handle->r8();
      if (seg.lablen == 0) {
        seg.lablen = 0xa;
      }
    }
    // check if load name is valid
    handle->seek(ofs + dispname);
    seg.name = handle->read(seg.lablen);
    if (seg.name[0] == 0 || seg.name[0] == ' ') {  // invalid name use segname
      seg.name = handle->read(seg.lablen);
    }
    seg.offset = ofs + dispdata;
    if (version == 1) {  // convert to v2
      seg.bytecnt *= 512;
      seg.kind = (kind & 0xf1f) | ((kind & 0xe0) << 8);
    }
    seg.mapped = 0;
    ofs += seg.bytecnt;
    segments.push_back(seg);
  }
  return true;
}

bool OMF::mapSegments() {
  // for ease of disassembly, first attempt to map each segment to a bank.
  auto canDirectMap = true;
  for (auto &seg : segments) {
    if (seg.org) {  // segment wants to be somewhere specific, no direct map
      canDirectMap = false;
    } else if (seg.length > 0xfffff) {  // segment too long for a single bank
      canDirectMap = false;
    }
  }
  if (canDirectMap) {
    for (auto &seg : segments) {
      seg.mapped = seg.segnum << 20;
    }
    return true;
  }
  // use a memory map that denotes runs of available ram
  std::vector<uint32_t> memory;
  memory.push_back(0x10000);  // min
  memory.push_back(0x7f0000);  // max
  // first map any segments that know where they belong
  for (auto &seg : segments) {
    if (seg.org) {
      if ((seg.kind & 0x1f) == 0x11) {  // absolute bank
        seg.mapped = seg.org << 16;
      } else {
        seg.mapped = seg.org;
      }
      bool collision = false;
      // verify we aren't overlapping anything
      for (auto it = memory.begin(); it != memory.end(); it++) {
        if (seg.mapped < *it && seg.mapped + seg.length > *it) {
          collision = true;
        }
      }
      if (collision) {
        fprintf(stderr, "Segment $%x (%s) collides with another segment\n",
                seg.segnum, seg.name.c_str());
        return false;
      }
      memory.push_back(seg.mapped);
      memory.push_back(seg.mapped + seg.length);
      if (seg.mapped < memory[0]) {  // below the minimum
        memory[0] = seg.mapped;  // new min
      }
      std::sort(memory.begin(), memory.end());
    }
  }

  // now map everything else by first fit
  for (auto &seg : segments) {
    if (seg.mapped == 0) {
      for (auto it = memory.begin(); it != memory.end(); it++) {
        auto base = *it;
        if (seg.align && (base & (seg.align - 1))) {
          base += seg.align;
          base &= ~(seg.align - 1);
        }
        if (seg.banksize && (((base & (seg.banksize - 1)) + seg.length) &
                             ~(seg.banksize - 1))) {  // crosses bank
          base += seg.banksize;
          base &= ~(seg.banksize - 1);
        }
        // does it fit?
        it++;
        if (base < *it && *it - base >= seg.length) {
          seg.mapped = base;
          memory.push_back(seg.mapped);
          memory.push_back(seg.mapped + seg.length);
          std::sort(memory.begin(), memory.end());
          break;
        }
      }
      if (seg.mapped == 0) {
        fprintf(stderr, "Failed to map Segment #$%x (%s), no room\n",
                seg.segnum, seg.name.c_str());
        return false;
      }
    }
  }
  return true;
}

bool OMF::relocSegments() {
  for (auto &seg : segments) {
    auto done = false;
    auto pc = seg.mapped;
    auto data = std::vector<uint8_t>(seg.length);
    handle->seek(seg.offset);
    while (!done) {
      auto opcode = handle->r8();
      switch (opcode) {
        case DONE:
          done = true;
          break;
        case RELOC:
          {
            auto numBytes = handle->r8();
            auto bitShift = static_cast<int8_t>(handle->r8());
            auto offset = handle->r32();
            auto subOffset = handle->r32() + seg.mapped;
            if (bitShift < 0) {
              subOffset >>= -bitShift;
            } else {
              subOffset <<= bitShift;
            }
            patch(data, offset, numBytes, subOffset);
          }
          break;
        case INTERSEG:
          {
            auto numBytes = handle->r8();
            auto bitShift = static_cast<int8_t>(handle->r8());
            auto offset = handle->r32();
            handle->skip(2);  // filenum
            auto segnum = handle->r16();
            auto subOffset = handle->r32();
            for (auto &sub : segments) {
              if (sub.segnum == segnum) {
                subOffset += sub.mapped;
                break;
              }
            }
            if (bitShift < 0) {
              subOffset >>= -bitShift;
            } else {
              subOffset <<= bitShift;
            }
            patch(data, offset, numBytes, subOffset);
          }
          break;
        case DS:
          pc += handle->r32();  // filled with zeros
          break;
        case LCONST:
          {
            auto count = handle->r32();
            auto v = handle->readBytes(count);
            std::copy(v.begin(), v.end(), data.begin() + (pc - seg.mapped));
            pc += count;
          }
          break;
        case cRELOC:
          {
            auto numBytes = handle->r8();
            auto bitShift = static_cast<int8_t>(handle->r8());
            auto offset = handle->r16();
            auto subOffset = handle->r16() + seg.mapped;
            if (bitShift < 0) {
              subOffset >>= -bitShift;
            } else {
              subOffset <<= bitShift;
            }
            patch(data, offset, numBytes, subOffset);
          }
          break;
        case cINTERSEG:
          {
            auto numBytes = handle->r8();
            auto bitShift = static_cast<int8_t>(handle->r8());
            auto offset = handle->r16();
            auto segnum = handle->r8();
            int32_t subOffset = handle->r16();
            for (auto &sub : segments) {
              if (sub.segnum == segnum) {
                subOffset += sub.mapped;
                break;
              }
            }
            if (bitShift < 0) {
              subOffset >>= -bitShift;
            } else {
              subOffset <<= bitShift;
            }
            patch(data, offset, numBytes, subOffset);
          }
          break;
        case SUPER:
          {
            auto superLen = handle->r32();
            superLen += handle->tell();
            auto superType = handle->r8();
            int32_t superPage = 0;
            while (handle->tell() < superLen) {
              auto numOfs = handle->r8();
              if (numOfs & 0x80) {
                superPage += 256 * (numOfs & 0x7f);
                continue;
              }
              auto subHandle = TheHandle::createFromArray(data);
              for (auto o = 0; o <= numOfs; o++) {
                auto offset = superPage | handle->r8();
                uint8_t numBytes = 0;
                subHandle->seek(offset);
                int32_t subOffset = subHandle->r16();
                if (superType == 0 || superType == 1) {
                  subOffset += seg.mapped;
                  numBytes = superType + 2;
                } else if (superType < 14) {  // INTERSEG1-12
                  auto segnum = subHandle->r8();
                  for (auto &sub : segments) {
                    if (sub.segnum == segnum) {
                      subOffset += sub.mapped;
                      break;
                    }
                  }
                  numBytes = 3;
                } else if (superType < 26) {  // INTERSEG13-14
                  auto segnum = superType - 13;
                  for (auto &sub : segments) {
                    if (sub.segnum == segnum) {
                      subOffset += sub.mapped;
                      break;
                    }
                  }
                  numBytes = 2;
                } else {  // INTERSEG25-36
                  auto segnum = superType - 25;
                  for (auto &sub : segments) {
                    if (sub.segnum == segnum) {
                      subOffset += sub.mapped;
                      break;
                    }
                  }
                  subOffset >>= 16;
                  numBytes = 2;
                }
                patch(data, offset, numBytes, subOffset);
              }
              superPage += 256;
            }
          }
          break;
        default:
          if (opcode < 0xe0) {
            auto v = handle->readBytes(opcode);
            std::copy(v.begin(), v.end(), data.begin() + (pc - seg.mapped));
            pc += opcode;
          } else {
            fprintf(stderr, "Unknown segment opcode: $%02x\n", opcode);
            return false;
          }
          break;
      }
    }
    seg.data = TheHandle::createFromArray(data);
  }
  return true;
}

void OMF::patch(std::vector<uint8_t> &array, uint32_t offset, uint8_t numBytes,
                uint32_t value) {
  for (int i = 0; i < numBytes; i++, value >>= 8) {
    array[offset + i] = value & 0xff;
  }
}

std::vector<Segment> OMF::get() const {
  return segments;
}
