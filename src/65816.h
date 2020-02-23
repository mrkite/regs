/** @copyright 2020 Sean Kasun */
#pragma once

#include "disasm.h"

enum Addressing {
  IMP, IMM, IMMM, IMMX, IMMS, ABS, ABL, ABX, ABY, ABLX, AIX,
  ZP, ZPX, ZPY, ZPS, IND, INZ, INL, INX, INY, INLY, INS, REL, RELL,
  BANK, DB, DW, DD,
};

struct Opcode {
  const char *inst;
  Addressing addressing;
  InsType type;
};

#define op(a, b, c) {#a, b, InsType::c}

static const Opcode opcodes[] = {
  op(brk, IMP, Return),  // 00
  op(ora, INX, Normal),  // 01
  op(cop, IMP, Normal),  // 02
  op(ora, ZPS, Normal),  // 03
  op(tsb, ZP, Normal),  // 04
  op(ora, ZP, Normal),  // 05
  op(asl, ZP, Normal),  // 06
  op(ora, INL, Normal),  // 07
  op(php, IMP, Normal),  // 08
  op(ora, IMMM, Normal),  // 09
  op(asl, IMP, Normal),  // 0a
  op(phd, IMP, Normal),  // 0b
  op(tsb, ABS, Normal),  // 0c
  op(ora, ABS, Normal),  // 0d
  op(asl, ABS, Normal),  // 0e
  op(ora, ABL, Normal),  // 0f
  op(bpl, REL, Branch),  // 10
  op(ora, INY, Normal),  // 11
  op(ora, INZ, Normal),  // 12
  op(ora, INS, Normal),  // 13
  op(trb, ZP, Normal),  // 14
  op(ora, ZPX, Normal),  // 15
  op(asl, ZPX, Normal),  // 16
  op(ora, INLY, Normal),  // 17
  op(clc, IMP, Normal),  // 18
  op(ora, ABY, Normal),  // 19
  op(inc, IMP, Normal),  // 1a
  op(tcs, IMP, Normal),  // 1b
  op(trb, ABS, Normal),  // 1c
  op(ora, ABX, Normal),  // 1d
  op(asl, ABX, Normal),  // 1e
  op(ora, ABLX, Normal),  // 1f
  op(jsr, ABS, Call),  // 20
  op(and, INX, Normal),  // 21
  op(jsl, ABL, Call),  // 22
  op(and, ZPS, Normal),  // 23
  op(bit, ZP, Normal),  // 24
  op(and, ZP, Normal),  // 25
  op(rol, ZP, Normal),  // 26
  op(and, INL, Normal),  // 27
  op(plp, IMP, Normal),  // 28
  op(and, IMMM, Normal),  // 29
  op(rol, IMP, Normal),  // 2a
  op(pld, IMP, Normal),  // 2b
  op(bit, ABS, Normal),  // 2c
  op(and, ABS, Normal),  // 2d
  op(rol, ABS, Normal),  // 2e
  op(and, ABL, Normal),  // 2f
  op(bmi, REL, Branch),  // 30
  op(and, INY, Normal),  // 31
  op(and, INZ, Normal),  // 32
  op(and, INS, Normal),  // 33
  op(bit, ZPX, Normal),  // 34
  op(and, ZPX, Normal),  // 35
  op(rol, ZPX, Normal),  // 36
  op(and, INLY, Normal),  // 37
  op(sec, IMP, Normal),  // 38
  op(and, ABY, Normal),  // 39
  op(dec, IMP, Normal),  // 3a
  op(tsc, IMP, Normal),  // 3b
  op(bit, ABX, Normal),  // 3c
  op(and, ABX, Normal),  // 3d
  op(rol, ABX, Normal),  // 3e
  op(and, ABLX, Normal),  // 3f
  op(rti, IMP, Return),  // 40
  op(eor, INX, Normal),  // 41
  op(db, DB, Invalid),  // 42
  op(eor, ZPS, Normal),  // 43
  op(mvp, BANK, Normal),  // 44
  op(eor, ZP, Normal),  // 45
  op(lsr, ZP, Normal),  // 46
  op(eor, INL, Normal),  // 47
  op(pha, IMP, Normal),  // 48
  op(eor, IMMM, Normal),  // 49
  op(lsr, IMP, Normal),  // 4a
  op(phk, IMP, Normal),  // 4b
  op(jmp, ABS, Jump),  // 4c
  op(eor, ABS, Normal),  // 4d
  op(lsr, ABS, Normal),  // 4e
  op(eor, ABL, Normal),  // 4f
  op(bvc, REL, Branch),  // 50
  op(eor, INY, Normal),  // 51
  op(eor, INZ, Normal),  // 52
  op(eor, INS, Normal),  // 53
  op(mvn, BANK, Normal),  // 54
  op(eor, ZPX, Normal),  // 55
  op(lsr, ZPX, Normal),  // 56
  op(eor, INLY, Normal),  // 57
  op(cli, IMP, Normal),  // 58
  op(eor, ABY, Normal),  // 59
  op(phy, IMP, Normal),  // 5a
  op(tcd, IMP, Normal),  // 5b
  op(jmp, ABL, Jump),  // 5c
  op(eor, ABX, Normal),  // 5d
  op(lsr, ABX, Normal),  // 5e
  op(eor, ABLX, Normal),  // 5f
  op(rts, IMP, Return),  // 60
  op(adc, INX, Normal),  // 61
  op(per, REL, Normal),  // 62
  op(adc, ZPS, Normal),  // 63
  op(stz, ZP, Normal),  // 64
  op(adc, ZP, Normal),  // 65
  op(ror, ZP, Normal),  // 66
  op(adc, INL, Normal),  // 67
  op(pla, IMP, Normal),  // 68
  op(adc, IMMM, Normal),  // 69
  op(ror, IMP, Normal),  // 6a
  op(rtl, IMP, Return),  // 6b
  op(jmp, IND, Jump),  // 6c
  op(adc, ABS, Normal),  // 6d
  op(ror, ABS, Normal),  // 6e
  op(adc, ABL, Normal),  // 6f
  op(bvs, REL, Branch),  // 70
  op(adc, INY, Normal),  // 71
  op(adc, INZ, Normal),  // 72
  op(adc, INS, Normal),  // 73
  op(stz, ZPX, Normal),  // 74
  op(adc, ZPX, Normal),  // 75
  op(ror, ZPX, Normal),  // 76
  op(adc, INLY, Normal),  // 77
  op(sei, IMP, Normal),  // 78
  op(adc, ABY, Normal),  // 79
  op(ply, IMP, Normal),  // 7a
  op(tdc, IMP, Normal),  // 7b
  op(jmp, AIX, Jump),  // 7c
  op(adc, ABX, Normal),  // 7d
  op(ror, ABX, Normal),  // 7e
  op(adc, ABLX, Normal),  // 7f
  op(bra, REL, Jump),  // 80
  op(sta, INX, Normal),  // 81
  op(brl, RELL, Jump),  // 82
  op(sta, ZPS, Normal),  // 83
  op(sty, ZP, Normal),  // 84
  op(sta, ZP, Normal),  // 85
  op(stx, ZP, Normal),  // 86
  op(sta, INL, Normal),  // 87
  op(dey, IMP, Normal),  // 88
  op(bit, IMMM, Normal),  // 89
  op(txa, IMP, Normal),  // 8a
  op(phb, IMP, Normal),  // 8b
  op(sty, ABS, Normal),  // 8c
  op(sta, ABS, Normal),  // 8d
  op(stx, ABS, Normal),  // 8e
  op(sta, ABL, Normal),  // 8f
  op(bcc, REL, Branch),  // 90
  op(sta, INY, Normal),  // 91
  op(sta, INZ, Normal),  // 92
  op(sta, INS, Normal),  // 93
  op(sty, ZPX, Normal),  // 94
  op(sta, ZPX, Normal),  // 95
  op(stx, ZPY, Normal),  // 96
  op(sta, INLY, Normal),  // 97
  op(tya, IMP, Normal),  // 98
  op(sta, ABY, Normal),  // 99
  op(txs, IMP, Normal),  // 9a
  op(txy, IMP, Normal),  // 9b
  op(stz, ABS, Normal),  // 9c
  op(sta, ABX, Normal),  // 9d
  op(stz, ABX, Normal),  // 9e
  op(sta, ABLX, Normal),  // 9f
  op(ldy, IMMX, Normal),  // a0
  op(lda, INX, Normal),  // a1
  op(ldx, IMMX, Normal),  // a2
  op(lda, ZPS, Normal),  // a3
  op(ldy, ZP, Normal),  // a4
  op(lda, ZP, Normal),  // a5
  op(ldx, ZP, Normal),  // a6
  op(lda, INL, Normal),  // a7
  op(tay, IMP, Normal),  // a8
  op(lda, IMMM, Normal),  // a9
  op(tax, IMP, Normal),  // aa
  op(plb, IMP, Normal),  // ab
  op(ldy, ABS, Normal),  // ac
  op(lda, ABS, Normal),  // ad
  op(ldx, ABS, Normal),  // ae
  op(lda, ABL, Normal),  // af
  op(bcs, REL, Branch),  // b0
  op(lda, INY, Normal),  // b1
  op(lda, INZ, Normal),  // b2
  op(lda, INS, Normal),  // b3
  op(ldy, ZPX, Normal),  // b4
  op(lda, ZPX, Normal),  // b5
  op(ldx, ZPY, Normal),  // b6
  op(lda, INLY, Normal),  // b7
  op(clv, IMP, Normal),  // b8
  op(lda, ABY, Normal),  // b9
  op(tsx, IMP, Normal),  // ba
  op(tyx, IMP, Normal),  // bb
  op(ldy, ABX, Normal),  // bc
  op(lda, ABX, Normal),  // bd
  op(ldx, ABY, Normal),  // be
  op(lda, ABLX, Normal),  // bf
  op(cpy, IMMX, Normal),  // c0
  op(cmp, INX, Normal),  // c1
  op(rep, IMM, Normal),  // c2
  op(cmp, ZPS, Normal),  // c3
  op(cpy, ZP, Normal),  // c4
  op(cmp, ZP, Normal),  // c5
  op(dec, ZP, Normal),  // c6
  op(cmp, INL, Normal),  // c7
  op(iny, IMP, Normal),  // c8
  op(cmp, IMMM, Normal),  // c9
  op(dex, IMP, Normal),  // ca
  op(wai, IMP, Normal),  // cb
  op(cpy, ABS, Normal),  // cc
  op(cmp, ABS, Normal),  // cd
  op(dec, ABS, Normal),  // ce
  op(cmp, ABL, Normal),  // cf
  op(bne, REL, Branch),  // d0
  op(cmp, INY, Normal),  // d1
  op(cmp, INZ, Normal),  // d2
  op(cmp, INS, Normal),  // d3
  op(pei, ZP, Normal),  // d4
  op(cmp, ZPX, Normal),  // d5
  op(DEC, ZPX, Normal),  // d6
  op(cmp, INLY, Normal),  // d7
  op(cld, IMP, Normal),  // d8
  op(cmp, ABY, Normal),  // d9
  op(phx, IMP, Normal),  // da
  op(stp, IMP, Return),  // db
  op(jmp, IND, Jump),  // dc
  op(cmp, ABX, Normal),  // dd
  op(dec, ABX, Normal),  // de
  op(cmp, ABLX, Normal),  // df
  op(cpx, IMMX, Normal),  // e0
  op(sbc, INX, Normal),  // e1
  op(sep, IMM, Normal),  // e2
  op(sbc, ZPS, Normal),  // e3
  op(cpx, ZP, Normal),  // e4
  op(sbc, ZP, Normal),  // e5
  op(inc, ZP, Normal),  // e6
  op(sbc, INL, Normal),  // e7
  op(inx, IMP, Normal),  // e8
  op(sbc, IMMM, Normal),  // e9
  op(nop, IMP, Normal),  // ea
  op(xba, IMP, Normal),  // eb
  op(cpx, ABS, Normal),  // ec
  op(sbc, ABS, Normal),  // ed
  op(inc, ABS, Normal),  // ee
  op(sbc, ABL, Normal),  // ef
  op(beq, REL, Branch),  // f0
  op(sbc, INY, Normal),  // f1
  op(sbc, INZ, Normal),  // f2
  op(sbc, INS, Normal),  // f3
  op(pea, IMMS, Normal),  // f4
  op(sbc, ZPX, Normal),  // f5
  op(inc, ZPX, Normal),  // f6
  op(sbc, INLY, Normal),  // f7
  op(sed, IMP, Normal),  // f8
  op(sbc, ABY, Normal),  // f9
  op(plx, IMP, Normal),  // fa
  op(xce, IMP, Normal),  // fb
  op(jsr, AIX, Call),  // fc
  op(sbc, ABX, Normal), // fd
  op(inc, ABX, Normal),  // fe
  op(sbc, ABLX, Normal),  // ff
};

#undef op

struct AddressSize {
  Addressing mode;
  int length;
};

static const AddressSize addressSizes[] = {
  {IMP, 1},
  {IMM, 2},
  {IMMM, 3},
  {IMMX, 3},
  {IMMS, 3},
  {ABS, 3},
  {ABL, 4},
  {ABX, 3},
  {ABY, 3},
  {ABLX, 4},
  {AIX, 3},
  {ZP, 2},
  {ZPX, 2},
  {ZPY, 2},
  {ZPS, 2},
  {IND, 3},
  {INZ, 2},
  {INL, 2},
  {INX, 2},
  {INY, 2},
  {INLY, 2},
  {INS, 2},
  {REL, 2},
  {RELL, 3},
  {BANK, 3},
  {DB, 1},
  {DW, 2},
  {DD, 4},
};

#define numAddressSizes (sizeof(addressSizes) / sizeof(addressSizes[0]))
