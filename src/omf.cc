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

void Segment::initDPS() {
  kind = 0x12;
  length = 1024;
  resspc = 1024;
  bytecnt = 0;
  name = "Direct";
}

bool Segment::isDPS() {
  return (kind & 0x1f) == 0x12;
}

bool Segment::isJump() {
  return (kind & 0x1f) == 0x02;
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
    auto skip = 0;
    if (seg.lablen == 0) {
      skip = 1;
      handle->seek(ofs + dispname + 0xa);
      seg.lablen = handle->r8();
      if (seg.lablen == 0) {
        seg.lablen = 0xa;
      }
    }
    // there are 2 names, one is always 10 bytes at dispname,
    // this is the "loadname" and it specifies the name by the linker
    // it is followed by the segname, which is the actual segment name.

    // check if load name is valid
    handle->seek(ofs + dispname + 0xa + skip);
    seg.name = handle->read(seg.lablen);
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
  // use a memory map that denotes runs of available ram
  std::vector<uint32_t> memory;
  memory.push_back(0x300);  // min
  memory.push_back(0x7f0000);  // max
  // first map any segments that know where they belong
  for (auto &seg : segments) {
    seg.map(memory, false);
    std::sort(memory.begin(), memory.end());
  }

  // now map everything else by first fit
  for (auto &seg : segments) {  // map.true
    seg.map(memory, true);
    std::sort(memory.begin(), memory.end());
  }
  // create direct-page if it doesn't exist
  bool found = false;
  for (auto &seg : segments) {
    if (seg.isDPS()) {
      found = true;
    }
  }
  if (!found) {
    Segment seg;
    seg.initDPS();
    seg.map(memory, true);
    segments.push_back(seg);
  }
  return true;
}

bool Segment::map(std::vector<uint32_t> &memory, bool force) {
  if (mapped) {
    return false;
  }
  if (org && ((org & 0xffff) != 0 || (kind & 0x800) == 0)) {
    mapped = org;
    // verif we're not overlapping
    for (auto m : memory) {
      if (mapped < m && mapped + length > m) {
        fprintf(stderr, "Segment %d (%s) collides with another segment!\n", segnum, name.c_str());
        return false;
      }
    }
    memory.push_back(mapped);
    memory.push_back(mapped + length);
    if (mapped < memory[0]) {  // below the min?
      memory[0] = mapped;
    }
    return true;
  }
  if (force) {
    for (auto it = memory.begin(); it != memory.end(); it++) {
      auto base = *it;
      // skip special?
      if ((kind & 0x1f) != 0x12 && (base & 0xff0000) == 0) {
        base += 0x10000;  // not in bank 0
      }
      // are we aligned?
      if (align != 0 && (base & (align - 1)) != 0) {
        base += align;
        base &= ~(align - 1);
      }
      // does it cross bank boundaries?
      if (banksize != 0 &&
          (((base & (banksize - 1)) + length) & ~(banksize - 1)) != 0) {
        base += banksize;
        base &= ~(banksize - 1);
      }
      // does it fit?!
      it++;
      uint32_t end = *it;
      if (base < end && end - base >= length) {
        mapped = base;
        memory.push_back(mapped);
        memory.push_back(mapped + length);
        return true;
      }
    }
    fprintf(stderr, "Segment %d (%s) doesn't fit in memory\n", segnum, name.c_str());
  }
  return false;
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
    if (seg.isJump()) {  // patch jumptable
      for (int i = 8; i < seg.length; i += 14) {
        uint16_t segnum = data[i + 4] | (data[i + 5] << 8);
        int32_t subOffset = data[i + 6] | (data[i + 7] << 8) |
            (data[i + 8] << 16) | (data[i + 9] << 24);
        for (auto &sub : segments) {
          if (sub.segnum == segnum) {
            subOffset += sub.mapped;
            break;
          }
        }
        patch(data, i + 11, 3, subOffset);
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
