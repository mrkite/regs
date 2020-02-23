/** @copyright 2020 Sean Kasun */
#pragma once

#include <string>

enum TokenType {
  END, ENUM, NUMBER, SYMBOL, STRING, STRUCT, UNION, VAR,
};

struct Token {
  TokenType type;
  std::string asStr;
  char asSym = 0;
  int32_t asNum = 0;
  std::string filename;
  int curLine;
  bool expect(char ch);
  bool expect(const char *chs);
};

struct File {
  char *p;
  char *prev;
  char *end;
  std::string name;
  int curLine;

  Token token();
  void reset();

 private:
  void skipWhitespace();
  TokenType checkKeywords(std::string keyword);
};
