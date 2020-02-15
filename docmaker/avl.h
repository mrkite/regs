/** @copyright 2020 Sean Kasun */
#pragma once

#include <memory>
#include <vector>
#include <cstdint>

struct AVLNode_ {
  uint32_t key;
  std::shared_ptr<AVLNode_> left, right, down;
  int height;
  bool matched;
};

typedef std::shared_ptr<AVLNode_> AVLNode;

class AVL {
 public:
  bool insert(const std::vector<uint32_t> &keys);

 private:
  AVLNode insertOnce(AVLNode parent, uint32_t key);
  AVLNode walk(AVLNode root, uint32_t key) const;
  AVLNode root;
};
