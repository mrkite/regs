/** @copyright 2020 Sean Kasun */
#include "file.h"

void File::skipWhitespace() {
  while (p < end && isspace(*p)) {
    if (*p == '\n') {
      curLine++;
    }
    p++;
  }
}

Token File::token() {
  skipWhitespace();
  prev = p;

  Token t;
  t.filename = name;
  t.curLine = curLine;

  if (p == end) {
    t.type = END;
    return t;
  }
  char ch = *p++;
  if (isalpha(ch) || ch == '_') {
    t.asStr += ch;
    while (p < end && (isalnum(*p) || *p == '_')) {
      t.asStr += *p++;
    }
    t.type = checkKeywords(t.asStr);
    return t;
  }
  if (isdigit(ch) || ch == '-') {
    bool isNeg = ch == '-';
    if (isdigit(ch)) {
      t.asNum = ch - '0';
    }
    while (p < end && isdigit(*p)) {
      t.asNum *= 10;
      t.asNum += *p++ - '0';
    }
    if (isNeg) {
      t.asNum = -t.asNum;
    }
    t.type = NUMBER;
    return t;
  }
  if (ch == '$') {
    while (p < end && isxdigit(*p)) {
      t.asNum <<= 4;
      if (isdigit(*p)) {
        t.asNum |= *p++ - '0';
      } else if (*p >= 'a' && *p <= 'f') {
        t.asNum |= *p++ - 'a' + 10;
      } else {
        t.asNum |= *p++ - 'A' + 10;
      }
    }
    t.type = NUMBER;
    return t;
  }
  t.type = SYMBOL;
  t.asSym = ch;
  return t;
}

void File::reset() {
  p = prev;
}

TokenType File::checkKeywords(std::string keyword) {
  if (keyword == "enum") {
    return ENUM;
  } else if (keyword == "struct") {
    return STRUCT;
  } else if (keyword == "union") {
    return UNION;
  }
  return VAR;
}

bool Token::expect(char ch) {
  if (type != SYMBOL) {
    fprintf(stderr, "Error: %s:%d: ", filename.c_str(), curLine);
    fprintf(stderr, "'%c' expected\n", ch);
    return false;
  }
  if (asSym != ch) {
    fprintf(stderr, "Error: %s:%d: ", filename.c_str(), curLine);
    fprintf(stderr, "'%c' expected, found '%c' instead.\n", ch, asSym);
    return false;
  }
  return true;
}

bool Token::expect(const char *str) {
  if (type == SYMBOL) {
    for (const char *s = str; *s; s++) {
      if (*s == asSym) {
        return true;
      }
    }
  }
  fprintf(stderr, "Error: %s:%d: ", filename.c_str(), curLine);
  bool comma = false;
  for (const char *s = str; *s; s++) {
    fprintf(stderr, "%s'%c'", comma ? " or " : "", *s);
    comma = true;
  }
  if (type == SYMBOL) {
    fprintf(stderr, " expected, found '%c' instead\n", asSym);
  } else {
    fprintf(stderr, " expected\n");
  }
  return false;
}
