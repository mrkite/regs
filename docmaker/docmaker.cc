/** @copyright 2020 Sean Kasun */
#include <iostream>
#include "parser.h"
#include "compiler.h"
#include "output.h"

int main(int argc, char **argv) {
  if (argc != 2) {
    std::cerr << "Usage: " << argv[0] << " <directory>" << std::endl;
    return -1;
  }

  Parser parser;
  parser.add("uint8", U8);
  parser.add("uint16", U16);
  parser.add("uint32", U32);
  parser.add("int8", S8);
  parser.add("int16", S16);
  parser.add("int32", S32);

  if (!parser.run(argv[1])) {
    return -1;
  }
  Compiler compiler;
  if (!compiler.run(parser.symbols)) {
    return -1;
  }
  std::string outname;
  outname = argv[1];
  outname += ".dat";

  Output output;
  output.save(parser.symbols, outname);
  return 0;
}
