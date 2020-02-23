/** @copyright 2020 Sean Kasun */

#include "avl.h"

/**
  This works like a combiantion self-balancing AVL tree and
  Huffman tree. Basically, each node of the AVL tree contains a
  sub-AVL tree of further matches (that's what the 'down' branch represents)
  */

static inline int max(int a, int b) {
  return (a > b) ? a : b;
}

static inline int Height(AVLNode node) {
  if (node == nullptr) {
    return 0;
  }
  return node->height;
}

static inline int getBalance(AVLNode node) {
  if (node == nullptr) {
    return 0;
  }
  return Height(node->left) - Height(node->right);
}

static AVLNode rotateRight(AVLNode y) {
  auto x = y->left;
  auto t = x->right;
  x->right = y;
  y->left = t;
  y->height = max(Height(y->left), Height(y->right)) + 1;
  x->height = max(Height(x->left), Height(x->right)) + 1;
  return x;
}

static AVLNode rotateLeft(AVLNode x) {
  auto y = x->right;
  auto t = y->left;
  y->left = x;
  x->right = t;
  x->height = max(Height(x->left), Height(x->right)) + 1;
  y->height = max(Height(y->left), Height(y->right)) + 1;
  return y;
}

AVLNode AVL::insertOnce(AVLNode node, uint32_t key) {
  if (node == nullptr) {
    node = std::make_shared<AVLNode_>();
    node->key = key;
    node->left = nullptr;
    node->right = nullptr;
    node->down = nullptr;
    node->height = 1;
    node->matched = false;
    return node;
  }
  if (key < node->key) {
    node->left = insertOnce(node->left, key);
  } else if (key > node->key) {
    node->right = insertOnce(node->right, key);
  } else {  // key already exists
    return node;
  }
  node->height = 1 + max(Height(node->left), Height(node->right));
  int balance = getBalance(node);
  if (balance > 1 && key < node->left->key) {
    return rotateRight(node);
  }
  if (balance < -1 && key > node->right->key) {
    return rotateLeft(node);
  }
  if (balance > 1 && key > node->left->key) {
    node->left = rotateLeft(node->left);
    return rotateRight(node);
  }
  if (balance < -1 && key < node->right->key) {
    node->right = rotateRight(node->right);
    return rotateLeft(node);
  }
  return node;
}

AVLNode AVL::walk(AVLNode root, uint32_t key) const {
  AVLNode node = root;
  if (node == nullptr) {
    node = this->root;
  }
  while (node != nullptr && node->key != key) {
    if (key < node->key) {
      node = node->left;
    } else {
      node = node->right;
    }
  }
  return node;
}

bool AVL::insert(const std::vector<uint32_t> &keys) {
  AVLNode *parent = &root;
  for (int i = 0; i < keys.size(); i++) {
    *parent = insertOnce(*parent, keys[i]);
    auto node = walk(*parent, keys[i]);
    if (i == keys.size() - 1) {
      if (node->matched) {  // duplicate
        return false;
      }
      node->matched = true;
    }
    parent = &node->down;
  }
  return true;
}
