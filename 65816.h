#pragma once

/**
 * @copyright 2018 Sean Kasun
 * Defines the 65816 opcodes, their addressing modes, and sizes
 */

/**
  Addressing modes:
  imp  implied
  imm  #$const   (l)
  immm #$const   (l | h) if m16
  immx #$const   (l | h) if x16
  imms #$const   (l | h)
  abs  $addr     (addrl | addrh)
  abl  $addr     (addrl | addrh | bank)
  abx  $addr,x   (addrl | addrh)
  aby  $addr,y   (addrl | addrh)
  ablx $addr,x   (addrl | addrh | bank)
  aix  ($addr,x) (addrl | addrh)
  zp   $zp       (offset)
  zpx  $zp,x     (offset)
  zpy  $zp,y     (offset)
  zps  $zp,s     (offset)
  ind  ($addr)   (addrl | addrh)
  inz  ($zp)     (offset)
  inl  [$zp]     (offset)
  inx  ($zp,x)   (offset)
  iny  ($zp),y   (offset)
  inly [$zp],y   (offset)
  ins  ($zp,s),y (offset)
  rel  $r        (signed byte + pc)
  rell $r        (offsetl | offseth) + pc
  bank $sb,$db   (dstbnk | srcbnk)
  db   $op
  dw   $op
  dd   $op
 */

typedef enum {
  IMP = 0,
  IMM,
  IMMM,
  IMMX,
  IMMS,
  ABS,
  ABL,
  ABX,
  ABY,
  ABLX,
  AIX,
  ZP,
  ZPX,
  ZPY,
  ZPS,
  IND,
  INZ,
  INL,
  INX,
  INY,
  INLY,
  INS,
  REL,
  RELL,
  BANK,
  DB,
  DW,
  DD
} Address;

typedef enum {
  BREAK = 0,
  NORMAL = 1,
  BRANCH = 2,
  CALL = 3,
  RETURN = 4,
  JUMP = 5
} OpType;

typedef struct {
  const char *inst;
  Address address;
  OpType type;
} Opcode;

static Opcode opcodes[] = {
  {"brk", IMP, BREAK},  // 00
  {"ora", INX, NORMAL},  // 01
  {"cop", IMP, NORMAL},  // 02
  {"ora", ZPS, NORMAL},  // 03
  {"tsb", ZP, NORMAL},  // 04
  {"ora", ZP, NORMAL},  // 05
  {"asl", ZP, NORMAL},  // 06
  {"ora", INL, NORMAL},  // 07
  {"php", IMP, NORMAL},  // 08
  {"ora", IMMM, NORMAL},  // 09
  {"asl", IMP, NORMAL},  // 0a
  {"phd", IMP, NORMAL},  // 0b
  {"tsb", ABS, NORMAL},  // 0c
  {"ora", ABS, NORMAL},  // 0d
  {"asl", ABS, NORMAL},  // 0e
  {"ora", ABL, NORMAL},  // 0f
  {"bpl", REL, BRANCH},  // 10
  {"ora", INY, NORMAL},  // 11
  {"ora", INZ, NORMAL},  // 12
  {"ora", INS, NORMAL},  // 13
  {"trb", ZP, NORMAL},  // 14
  {"ora", ZPX, NORMAL},  // 15
  {"asl", ZPX, NORMAL},  // 16
  {"ora", INLY, NORMAL},  // 17
  {"clc", IMP, NORMAL},  // 18
  {"ora", ABY, NORMAL},  // 19
  {"inc", IMP, NORMAL},  // 1a
  {"tcs", IMP, NORMAL},  // 1b
  {"trb", ABS, NORMAL},  // 1c
  {"ora", ABX, NORMAL},  // 1d
  {"asl", ABX, NORMAL},  // 1e
  {"ora", ABLX, NORMAL},  // 1f
  {"jsr", ABS, CALL},  // 20
  {"and", INX, NORMAL},  // 21
  {"jsl", ABL, CALL},  // 22
  {"and", ZPS, NORMAL},  // 23
  {"bit", ZP, NORMAL},  // 24
  {"and", ZP, NORMAL},  // 25
  {"rol", ZP, NORMAL},  // 26
  {"and", INL, NORMAL},  // 27
  {"plp", IMP, NORMAL},  // 28
  {"and", IMMM, NORMAL},  // 29
  {"rol", IMP, NORMAL},  // 2a
  {"pld", IMP, NORMAL},  // 2b
  {"bit", ABS, NORMAL},  // 2c
  {"and", ABS, NORMAL},  // 2d
  {"rol", ABS, NORMAL},  // 2e
  {"and", ABL, NORMAL},  // 2f
  {"bmi", REL, BRANCH},  // 30
  {"and", INY, NORMAL},  // 31
  {"and", INZ, NORMAL},  // 32
  {"and", INS, NORMAL},  // 33
  {"bit", ZPX, NORMAL},  // 34
  {"and", ZPX, NORMAL},  // 35
  {"rol", ZPX, NORMAL},  // 36
  {"and", INLY, NORMAL},  // 37
  {"sec", IMP, NORMAL},  // 38
  {"and", ABY, NORMAL},  // 39
  {"dec", IMP, NORMAL},  // 3a
  {"tsc", IMP, NORMAL},  // 3b
  {"bit", ABX, NORMAL},  // 3c
  {"and", ABX, NORMAL},  // 3d
  {"rol", ABX, NORMAL},  // 3e
  {"and", ABLX, NORMAL},  // 3f
  {"rti", IMP, RETURN},  // 40
  {"eor", INX, NORMAL},  // 41
  {"db", DB, BREAK},  // 42
  {"eor", ZPS, NORMAL},  // 43
  {"mvp", BANK, NORMAL},  // 44
  {"eor", ZP, NORMAL},  // 45
  {"lsr", ZP, NORMAL},  // 46
  {"eor", INL, NORMAL},  // 47
  {"pha", IMP, NORMAL},  // 48
  {"eor", IMMM, NORMAL},  // 49
  {"lsr", IMP, NORMAL},  // 4a
  {"phk", IMP, NORMAL},  // 4b
  {"jmp", ABS, JUMP},  // 4c
  {"eor", ABS, NORMAL},  // 4d
  {"lsr", ABS, NORMAL},  // 4e
  {"eor", ABL, NORMAL},  // 4f
  {"bvc", REL, BRANCH},  // 50
  {"eor", INY, NORMAL},  // 51
  {"eor", INZ, NORMAL},  // 52
  {"eor", INS, NORMAL},  // 53
  {"mvn", BANK, NORMAL},  // 54
  {"eor", ZPX, NORMAL},  // 55
  {"lsr", ZPX, NORMAL},  // 56
  {"eor", INLY, NORMAL},  // 57
  {"cli", IMP, NORMAL},  // 58
  {"eor", ABY, NORMAL},  // 59
  {"phy", IMP, NORMAL},  // 5a
  {"tcd", IMP, NORMAL},  // 5b
  {"jmp", ABL, JUMP},  // 5c
  {"eor", ABX, NORMAL},  // 5d
  {"lsr", ABX, NORMAL},  // 5e
  {"eor", ABLX, NORMAL},  // 5f
  {"rts", IMP, RETURN},  // 60
  {"adc", INX, NORMAL},  // 61
  {"per", IMP, NORMAL},  // 62
  {"adc", ZPS, NORMAL},  // 63
  {"stz", ZP, NORMAL},  // 64
  {"adc", ZP, NORMAL},  // 65
  {"ror", ZP, NORMAL},  // 66
  {"adc", INL, NORMAL},  // 67
  {"pla", IMP, NORMAL},  // 68
  {"adc", IMMM, NORMAL},  // 69
  {"ror", IMP, NORMAL},  // 6a
  {"rtl", IMP, RETURN},  // 6b
  {"jmp", IND, JUMP},  // 6c
  {"adc", ABS, NORMAL},  // 6d
  {"ror", ABS, NORMAL},  // 6e
  {"adc", ABL, NORMAL},  // 6f
  {"bvs", REL, BRANCH},  // 70
  {"adc", INY, NORMAL},  // 71
  {"adc", INZ, NORMAL},  // 72
  {"adc", INS, NORMAL},  // 73
  {"stz", ZPX, NORMAL},  // 74
  {"adc", ZPX, NORMAL},  // 75
  {"ror", ZPX, NORMAL},  // 76
  {"adc", INLY, NORMAL},  // 77
  {"sei", IMP, NORMAL},  // 78
  {"adc", ABY, NORMAL},  // 79
  {"ply", IMP, NORMAL},  // 7a
  {"tdc", IMP, NORMAL},  // 7b
  {"jmp", AIX, JUMP},  // 7c
  {"adc", ABX, NORMAL},  // 7d
  {"ror", ABX, NORMAL},  // 7e
  {"adc", ABLX, NORMAL},  // 7f
  {"bra", REL, JUMP},  // 80
  {"sta", INX, NORMAL},  // 81
  {"brl", RELL, JUMP},  // 82
  {"sta", ZPS, NORMAL},  // 83
  {"sty", ZP, NORMAL},  // 84
  {"sta", ZP, NORMAL},  // 85
  {"stx", ZP, NORMAL},  // 86
  {"sta", INL, NORMAL},  // 87
  {"dey", IMP, NORMAL},  // 88
  {"bit", IMMM, NORMAL},  // 89
  {"txa", IMP, NORMAL},  // 8a
  {"phb", IMP, NORMAL},  // 8b
  {"sty", ABS, NORMAL},  // 8c
  {"sta", ABS, NORMAL},  // 8d
  {"stx", ABS, NORMAL},  // 8e
  {"sta", ABL, NORMAL},  // 8f
  {"bcc", REL, BRANCH},  // 90
  {"sta", INY, NORMAL},  // 91
  {"sta", INZ, NORMAL},  // 92
  {"sta", INS, NORMAL},  // 93
  {"sty", ZPX, NORMAL},  // 94
  {"sta", ZPX, NORMAL},  // 95
  {"stx", ZPY, NORMAL},  // 96
  {"sta", INLY, NORMAL},  // 97
  {"tya", IMP, NORMAL},  // 98
  {"sta", ABY, NORMAL},  // 99
  {"txs", IMP, NORMAL},  // 9a
  {"txy", IMP, NORMAL},  // 9b
  {"stz", ABS, NORMAL},  // 9c
  {"sta", ABX, NORMAL},  // 9d
  {"stz", ABX, NORMAL},  // 9e
  {"sta", ABLX, NORMAL},  // 9f
  {"ldy", IMMX, NORMAL},  // a0
  {"lda", INX, NORMAL},  // a1
  {"ldx", IMMX, NORMAL},  // a2
  {"lda", ZPS, NORMAL},  // a3
  {"ldy", ZP, NORMAL},  // a4
  {"lda", ZP, NORMAL},  // a5
  {"ldx", ZP, NORMAL},  // a6
  {"lda", INL, NORMAL},  // a7
  {"tay", IMP, NORMAL},  // a8
  {"lda", IMMM, NORMAL},  // a9
  {"tax", IMP, NORMAL},  // aa
  {"plb", IMP, NORMAL},  // ab
  {"ldy", ABS, NORMAL},  // ac
  {"lda", ABS, NORMAL},  // ad
  {"ldx", ABS, NORMAL},  // ae
  {"lda", ABL, NORMAL},  // af
  {"bcs", REL, BRANCH},  // b0
  {"lda", INY, NORMAL},  // b1
  {"lda", INZ, NORMAL},  // b2
  {"lda", INS, NORMAL},  // b3
  {"ldy", ZPX, NORMAL},  // b4
  {"lda", ZPX, NORMAL},  // b5
  {"ldx", ZPY, NORMAL},  // b6
  {"lda", INLY, NORMAL},  // b7
  {"clv", IMP, NORMAL},  // b8
  {"lda", ABY, NORMAL},  // b9
  {"tsx", IMP, NORMAL},  // ba
  {"tyx", IMP, NORMAL},  // bb
  {"ldy", ABX, NORMAL},  // bc
  {"lda", ABX, NORMAL},  // bd
  {"ldx", ABY, NORMAL},  // be
  {"lda", ABLX, NORMAL},  // bf
  {"cpy", IMMX, NORMAL},  // c0
  {"cmp", INX, NORMAL},  // c1
  {"rep", IMM, NORMAL},  // c2
  {"cmp", ZPS, NORMAL},  // c3
  {"cpy", ZP, NORMAL},  // c4
  {"cmp", ZP, NORMAL},  // c5
  {"dec", ZP, NORMAL},  // c6
  {"cmp", INL, NORMAL},  // c7
  {"iny", IMP, NORMAL},  // c8
  {"cmp", IMMM, NORMAL},  // c9
  {"dex", IMP, NORMAL},  // ca
  {"wai", IMP, NORMAL},  // cb
  {"cpy", ABS, NORMAL},  // cc
  {"cmp", ABS, NORMAL},  // cd
  {"dec", ABS, NORMAL},  // ce
  {"cmp", ABL, NORMAL},  // cf
  {"bne", REL, BRANCH},  // d0
  {"cmp", INY, NORMAL},  // d1
  {"cmp", INZ, NORMAL},  // d2
  {"cmp", INS, NORMAL},  // d3
  {"pei", ZP, NORMAL},  // d4
  {"cmp", ZPX, NORMAL},  // d5
  {"dec", ZPX, NORMAL},  // d6
  {"cmp", INLY, NORMAL},  // d7
  {"cld", IMP, NORMAL},  // d8
  {"cmp", ABY, NORMAL},  // d9
  {"phx", IMP, NORMAL},  // da
  {"stp", IMP, BREAK},  // db
  {"jmp", IND, JUMP},  // dc
  {"cmp", ABX, NORMAL},  // dd
  {"dec", ABX, NORMAL},  // de
  {"cmp", ABLX, NORMAL},  // df
  {"cpx", IMMX, NORMAL},  // e0
  {"sbc", INX, NORMAL},  // e1
  {"sep", IMM, NORMAL},  // e2
  {"sbc", ZPS, NORMAL},  // e3
  {"cpx", ZP, NORMAL},  // e4
  {"sbc", ZP, NORMAL},  // e5
  {"inc", ZP, NORMAL},  // e6
  {"sbc", INL, NORMAL},  // e7
  {"inx", IMP, NORMAL},  // e8
  {"sbc", IMMM, NORMAL},  // e9
  {"nop", IMP, NORMAL},  // ea
  {"xba", IMP, NORMAL},  // eb
  {"cpx", ABS, NORMAL},  // ec
  {"sbc", ABS, NORMAL},  // ed
  {"inc", ABS, NORMAL},  // ee
  {"sbc", ABL, NORMAL},  // ef
  {"beq", REL, BRANCH},  // f0
  {"sbc", INY, NORMAL},  // f1
  {"sbc", INZ, NORMAL},  // f2
  {"sbc", INS, NORMAL},  // f3
  {"pea", IMMS, NORMAL},  // f4
  {"sbc", ZPX, NORMAL},  // f5
  {"inc", ZPX, NORMAL},  // f6
  {"sbc", INLY, NORMAL},  // f7
  {"sed", IMP, NORMAL},  // f8
  {"sbc", ABY, NORMAL},  // f9
  {"plx", IMP, NORMAL},  // fa
  {"xce", IMP, NORMAL},  // fb
  {"jsr", AIX, CALL},  // fc
  {"sbc", ABX, NORMAL},  // fd
  {"inc", ABX, NORMAL},  // fe
  {"sbc", ABLX, NORMAL}  // ff
};

static uint8_t addressSizes[] = {
  1,  // IMP
  2,  // IMM
  3,  // IMMM
  3,  // IMMX
  3,  // IMMS
  3,  // ABS
  4,  // ABL
  3,  // ABX
  3,  // ABY
  4,  // ABLX
  3,  // AIX
  2,  // ZP
  2,  // ZPX
  2,  // ZPY
  2,  // ZPS
  3,  // IND
  2,  // INZ
  2,  // INL
  2,  // INX
  2,  // INY
  2,  // INLY
  2,  // INS
  2,  // REL
  3,  // RELL
  3,  // BANK
  1,  // DB
  2,  // DW
  4  // DD
};
