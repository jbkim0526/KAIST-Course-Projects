#ifndef _BST_H_
#define _BST_H_

#include <cstddef>
#include <cstdlib>

#ifndef NULL
#define NULL nullptr
#endif

/////////////////////////////////////////////////////////////////////
// Integer node entry
// Do not modify this class
/////////////////////////////////////////////////////////////////////
class IntEntry {
 public:
  // used only for IntRBTree
  typedef enum{RED, BLACK} Color;
 public:
    IntEntry(int k, int v, Color c=RED) :
      _key(k), _val(v), _par(NULL), _left(NULL), _right(NULL) {setColor(c);}
	int key() const      {return _key;}
	int value() const    {return _val;}
	void setKey(int k)   {_key = k;}
	void setValue(int v) {_val = v;}

	IntEntry* left() const      {return _left;}
	IntEntry* right() const     {return _right;}
	IntEntry* parent() const    {return _par;}
	void setLeft(IntEntry *l)   {_left = l;}
	void setRight(IntEntry *r)  {_right = r;}
	void setParent(IntEntry *p) {_par = p;}
	
	bool isRoot() const     {return (_par == NULL);}
	bool isExternal() const {return (_left == NULL) && (_right == NULL);}
	bool isInternal() const {return !isExternal();}

    // only for IntRBtree
    Color color() const    {return (_col & 0x1) ? BLACK : RED;}
    void setColor(Color c) {_col = (c == RED) ? 0 : 1;} 
	
 protected:
	int  _key;        // key
	int _val:31;      // value
    	int _col:1;       // color (unset? RED, set? BLACK)
	IntEntry *_par;   // parent pointer
	IntEntry *_left;  // left child pointer
	IntEntry *_right; // right child pointer
};

/////////////////////////////////////////////////////////////////////
// Binary tree class
// Do not modify this class
/////////////////////////////////////////////////////////////////////
class IntBinaryTree {
 public:
	IntBinaryTree()	{root = NULL;}
	bool empty() const { return root == NULL; }
	IntEntry* getRoot() const {return root;}
	IntEntry* setRoot(IntEntry *r) {root = r;}
	
private:
	IntEntry *root;
};

// Integer binary search tree class definition
class IntBST {
 public:
	IntBST() {cnt = 0;}
	int size() const {return cnt;}
	bool empty() const { return (size() == 0);}
	virtual int find(int k);
	virtual void insert(int k);
	virtual bool remove(int k);
	int countRange(int k1, int k2);

 protected:
	int cnt;       
	IntEntry* search(int k, IntEntry* Tpos);
	IntEntry* findLMINode(IntEntry* start);

	void inOrderTravel(IntEntry* v, int& sum, int left, int right);
    
	IntBinaryTree T;
};


class IntRBTree : public IntBST {
 public:
	virtual void insert(int k);
	virtual bool remove(int k);
	void printRBTree();
	bool isRBTreeInternalPropertyValid();
	bool isRBTreeDepthPropertyValid();
	bool isRBTreeRootPropertyValid();

 protected:
	void restructure(IntEntry* z);
	void recoloring(IntEntry* z);
	void doubleRed(IntEntry* z);
	void doubleBlack(IntEntry* z,IntEntry* parent);
	int computeBlackHeight(IntEntry* currNode);
	bool checkInternalProperty(IntEntry* currNode);
};

#endif
