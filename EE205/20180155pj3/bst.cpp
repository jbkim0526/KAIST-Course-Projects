#include "bst.h"
#include <cassert>

#include <iostream> //erase this

using namespace std;

//////////////////////////////////////////////////////////////////////////
// Implementation of IntBST
//////////////////////////////////////////////////////////////////////////


// search from the root to the external - returns when it meats External or the key.
IntEntry* IntBST::search(int k, IntEntry* Tpos){


   if(Tpos->key() == k) return Tpos;

   else if(Tpos->key() < k){

      if(Tpos->right() == NULL) return Tpos;

      else return search(k,Tpos->right());

   }
   
   else {

      if(Tpos->left() == NULL) return Tpos;

      else return search(k,Tpos->left());   
   }
   
}

IntEntry* IntBST::findLMINode(IntEntry* start){

   IntEntry* pos;
   pos = start;

   while(pos->left() != NULL){
      pos = pos->left();
   }
   
   return pos;
}



//////////////////////////////////////////////////////////////////////////
int IntBST::find(int k)
{

   if(empty()) return 0;

   IntEntry* target = search(k, T.getRoot());

   // k not found
   if(target->key() != k) return 0;

   // k found 
   else return target->value();

}
//////////////////////////////////////////////////////////////////////////
void IntBST::insert(int k)
{

   IntEntry* target;

   if(empty()){
      IntEntry* root = new IntEntry(k,1);
      T.setRoot(root);
      cnt++;
      return;
   }


   target = search(k,T.getRoot());


   // key is found
   if( target->key() == k ){
      
      target->setValue(target->value() + 1);
      cnt++;
      return;

   }
   
   // key not found  
   else{
         
      IntEntry* newNode = new IntEntry(k,1);

      if(target->key() < k){
         target->setRight(newNode);
         newNode->setParent(target);
         cnt++;
         return;
      } 
      else{
         target->setLeft(newNode);
         newNode->setParent(target);
         cnt++;
         return;
      }
   }


}

//////////////////////////////////////////////////////////////////////////
bool IntBST::remove(int k)
{

   IntEntry* target;
   IntEntry* LMINode;
   if(empty()) return false;
  
 
   target = search(k,T.getRoot());

   
   //key is found

   if(target->key() == k){
      if(target->value() == 1){


         
         // key is in External node - left & right are both null
         if(target->isExternal()){
            if(target->isRoot()){
               T.setRoot(NULL);
            
            }
            else if(target == target->parent()->left()){
               target->parent()->setLeft(NULL);
            }
            else{
               target->parent()->setRight(NULL);
            }
            delete(target);
            cnt--;
            return true;
         }
   

         if(target->right() == NULL && target->left() != NULL){

            if(target->isRoot()){
               T.setRoot(target->left());
               target->left()->setParent(NULL);
            }
            else if(target == target->parent()->right()){
               target->parent()->setRight(target->left());
               target->left()->setParent(target->parent());
            }

            else{
               target->parent()->setLeft(target->left());
               target->left()->setParent(target->parent());
            }
            
            cnt--;
            delete(target);
            return true;

         }


         if(target->right() != NULL && target->left() == NULL){
            if(target->isRoot()){
               T.setRoot(target->right());
               target->right()->setParent(NULL);
            }
            else if(target == target->parent()->right()){                  
               target->parent()->setRight(target->right());
               target->right()->setParent(target->parent());
            }
            else{
               target->parent()->setLeft(target->right());
               target->right()->setParent(target->parent());
            }
         
            cnt--;
            delete(target);
            return true;

         }

   
               

         // key is in Internal node
         LMINode = findLMINode(target->right());
         
         
         target->setKey(LMINode->key());
         target->setValue(LMINode->value())   ;      
         
         if(LMINode == LMINode->parent()->left()){

            LMINode->parent()->setLeft(LMINode->right());

            if(LMINode->right() != NULL){ 
               LMINode->right()->setParent(LMINode->parent());
                              
            }
         }
         else{
            LMINode->parent()->setRight(LMINode->right());
            
            if(LMINode->right() != NULL) LMINode->right()->setParent(LMINode->parent());
         }

          delete(LMINode);
         cnt--;

         return true;
         
      }
      
      else{
         target->setValue(target->value()-1);
         cnt--;
         return true;
         
      }

         
   }
   
   //key not found
   else{
      return false;
   }

}



void IntBST::inOrderTravel(IntEntry* v, int& sum, int left, int right){

   if( v == NULL) return;

   if( v->left() != NULL || v->key() >= left){
      inOrderTravel(v->left(),sum,left,right);
   }
   
   if( left <= v->key() && v->key() <= right){
      sum += v->value();
   }

   if( v->right() != NULL || v->key() <= right){
      inOrderTravel(v->right(),sum,left,right);
   }


}


//////////////////////////////////////////////////////////////////////////
int IntBST::countRange(int k1, int k2)
{
   
   int right;
   int left;
   int sum = 0;
   
   if (empty())
      return 0;


   // make left < right
   if(k1 > k2){
      left = k2;
      right = k1;
   }
   else{
      left = k1;
      right = k2;   
   }

   
   inOrderTravel(T.getRoot(),sum,left,right);

   return sum;

}

//////////////////////////////////////////////////////////////////////////
// Implementation of IntRBTree
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////

int IntRBTree::computeBlackHeight(IntEntry* currNode) {
    if (currNode == NULL) return 0; 

    int leftHeight = computeBlackHeight(currNode->left());
    int rightHeight = computeBlackHeight(currNode->right());
    int add = (currNode->color() == IntEntry::BLACK ) ? 1 : 0;
    if (leftHeight == -1 || rightHeight == -1 || leftHeight != rightHeight)
        return -1; 
    else
        return leftHeight + add;
}


bool IntRBTree::checkInternalProperty(IntEntry* currNode) {

    if (currNode == NULL)
        return true; 

    bool left = checkInternalProperty(currNode->left());
    bool right = checkInternalProperty(currNode->right());

    if (left == false || right == false) return false; 
    else{

		if(currNode->color() == IntEntry::RED){
			if(currNode->left() == NULL || currNode->left()->color() == IntEntry::BLACK &&
				currNode->right() == NULL || currNode->right()->color() == IntEntry::BLACK ) return true;
			else return false;
		}		
		return true;
	}
}



bool IntRBTree::isRBTreeInternalPropertyValid()
{
    return checkInternalProperty(T.getRoot());
}


bool IntRBTree::isRBTreeDepthPropertyValid()
{
    return computeBlackHeight(T.getRoot()) != -1;
} 


bool IntRBTree::isRBTreeRootPropertyValid()
{
	if(T.getRoot() == NULL) return true;
	return T.getRoot()->color() == IntEntry::BLACK;
}



void IntRBTree::restructure(IntEntry* target){

	
   	IntEntry* parent;
  	IntEntry* grand;

	IntEntry* child1;
	IntEntry* child2;
	IntEntry* child3;
	IntEntry* child4;

	int tempKey;
	int tempValue;

   	parent = target->parent();
   	grand = parent->parent();

  	
        if(parent->key() > target->key()){  //target is left child


		if(grand->key() < parent->key()){ //parent is right child

			//4
			child1 = grand->left();
			child2 = target->left();
			child3 = target->right();
			child4 = parent->right();

			grand->setLeft(target);
			grand->setRight(parent);
		
			target->setParent(grand);
			parent->setParent(grand);


			target->setLeft(child1);
			target->setRight(child2);
			parent->setLeft(child3);
			parent->setRight(child4);

			if(child1 != NULL){
				child1->setParent(target);
			}
			if(child2 != NULL){
				child2->setParent(target);
			}
			if(child3 != NULL){
				child3->setParent(parent);
			}
			if(child4 != NULL){
				child4->setParent(parent);
			}
			
			//swap value
			tempKey= target->key();
			tempValue = target->value();
			target->setKey(grand->key());
			target->setValue(grand->value());
			grand->setKey(tempKey);
			grand->setValue(tempValue);
			
			return;
		}

		else{  // parent is left child

			//1
			child1 = target->left();
			child2 = target->right();
			child3 = parent->right();
			child4 = grand->right();

			grand->setLeft(target);
			grand->setRight(parent);		
			target->setParent(grand);
			parent->setParent(grand);			


			target->setLeft(child1);
			target->setRight(child2);
			parent->setLeft(child3);
			parent->setRight(child4);


			if(child1 != NULL){
				child1->setParent(target);
			}
			if(child2 != NULL){
				child2->setParent(target);
			}
			if(child3 != NULL){
				child3->setParent(parent);
			}
			if(child4 != NULL){
				child4->setParent(parent);
			}

			

			tempKey= parent->key();
			tempValue = parent->value();

			parent->setKey(grand->key());
			parent->setValue(grand->value());
			grand->setKey(tempKey);
			grand->setValue(tempValue);

			return;
		}



	}

	else{   // target is right child

		if(grand->key() < parent->key()){  // parent is right child

			//3
	

			child1 = grand->left();
			child2 = parent->left();
			child3 = target->left();
			child4 = target->right();

			grand->setLeft(parent);
			grand->setRight(target);
			target->setParent(grand);
			parent->setParent(grand);

			parent->setLeft(child1);
			parent->setRight(child2);
			target->setLeft(child3);
			target->setRight(child4);


			if(child1 != NULL){
				child1->setParent(parent);
			}
			if(child2 != NULL){
				child2->setParent(parent);
			}
			if(child3 != NULL){
				child3->setParent(target);
			}
			if(child4 != NULL){
				child4->setParent(target);
			}
			
			//swap value
			tempKey= parent->key();
			tempValue = parent->value();

			parent->setKey(grand->key());
			parent->setValue(grand->value());
			grand->setKey(tempKey);
			grand->setValue(tempValue);

			return;

		}

		else{

                       //2
			child1 = parent->left();
			child2 = target->left();
			child3 = target->right();
			child4 = grand->right();

			grand->setLeft(parent);
			grand->setRight(target);
			target->setParent(grand);
			parent->setParent(grand);

			parent->setLeft(child1);
			parent->setRight(child2);
			target->setLeft(child3);
			target->setRight(child4);


			if(child1 != NULL){
				child1->setParent(parent);
			}
			if(child2 != NULL){
				child2->setParent(parent);
			}
			if(child3 != NULL){
				child3->setParent(target);
			}
			if(child4 != NULL){
				child4->setParent(target);
			}

			//swap value
			tempKey= target->key();
			tempValue = target->value();

			target->setKey(grand->key());
			target->setValue(grand->value());
			grand->setKey(tempKey);
			grand->setValue(tempValue);

			return;
		}

	}

   


}



void IntRBTree::doubleRed(IntEntry* target){

   	IntEntry* parent;
  	IntEntry* sibling;
  	IntEntry* grand;

        parent = target->parent();
   	grand = parent->parent();
   	if(parent == grand->left()){
     		sibling = grand->right();
   	}
   	else{
      		sibling = grand->left();
   	}
      

   	if( sibling == NULL || sibling->color() == IntEntry::BLACK ){ 
      		//cout << "restructure\n"	;	
		restructure(target);
		return;
   	}
	
   	else{ 	
		//cout << "recoloring\n"	;			
	
    		parent->setColor(IntEntry::BLACK);
   		sibling->setColor(IntEntry::BLACK);

      		if(grand->isRoot()) return;
		else{
			grand->setColor(IntEntry::RED);
		
		}

		if(grand->parent()->color() == IntEntry::RED) doubleRed(grand);

		return;  
      
   	}


}

void IntRBTree::insert(int k)
{
   
   IntEntry* target;

   // when inserting Root
   if(empty()){
      IntEntry* root = new IntEntry(k,1,IntEntry::BLACK);
      T.setRoot(root);
      cnt++;
      return;
   }

   					// insert does search also

   target = search(k,T.getRoot());
	

   // key is found
   if( target->key() == k ){
      target->setValue(target->value() + 1);
      cnt++;
      return;

   }
   
   // key not found  
   else{
         
      IntEntry* newNode = new IntEntry(k,1);

      if(target->key() < k){
         target->setRight(newNode);
         newNode->setParent(target);
         cnt++;
	 target = target->right();

      } 
      else{
         target->setLeft(newNode);
         newNode->setParent(target);
         cnt++;
	 target = target->left();

      }
   }

 
   // parent is red - double red
   if(target->parent()->color() == IntEntry::RED){ 

	doubleRed(target);
	return;

   }
   // parent is black - nothing to do
   else{ 
	return;
   }

   
}

//////////////////////////////////////////////////////////////////////////


void IntRBTree::doubleBlack(IntEntry* doubleBlackNode , IntEntry* parent)
{
	

	if(doubleBlackNode == T.getRoot()) return;

	IntEntry* sibling;


	if(doubleBlackNode == parent->left()){		
		sibling = parent->right();
	}
	else{
		

		sibling = parent->left();
	}



	if(sibling->color() == IntEntry::BLACK){
		
		// recolor
		if((sibling->left() == NULL || sibling->left()->color() == IntEntry::BLACK ) &&
		   (sibling->right() == NULL || sibling->right()->color() == IntEntry::BLACK))
		{
				
			sibling->setColor(IntEntry::RED);

			if(parent->color() == IntEntry::RED){
				parent->setColor(IntEntry::BLACK);
			}
			else{ 
				doubleBlack(parent,parent->parent());
			}			



		}
		// resturcture
		else{  


			if(sibling == parent->left()){


				if(sibling->left() != NULL && sibling->left()->color() == IntEntry::RED){
				
					restructure(sibling->left());
					parent->left()->setColor(IntEntry::BLACK);
					parent->right()->setColor(IntEntry::BLACK);
				}
	
				else{  // sibling->right is red

					restructure(sibling->right());
					parent->left()->setColor(IntEntry::BLACK);
					parent->right()->setColor(IntEntry::BLACK);
				}



			}

			else{   // silbing == parent->right()

				if(sibling->left() != NULL && sibling->left()->color() == IntEntry::RED){

	
					restructure(sibling->left());
					parent->left()->setColor(IntEntry::BLACK);
					parent->right()->setColor(IntEntry::BLACK);
				}
	
				else{
		
					//cout << sibling->left()<<"\n";

					restructure(sibling->right());
					parent->left()->setColor(IntEntry::BLACK);
					parent->right()->setColor(IntEntry::BLACK);
				}

			}



			

		}

	}
	// adjustment
	else{  
		
		IntEntry* child1;
		IntEntry* child2;
		IntEntry* child3;
		IntEntry* child4;

		if(sibling == parent->left()){


			restructure(sibling->left());
			doubleBlack(doubleBlackNode,parent->right());
		}
		else{
	
			child1 = parent->left();
			child2 = sibling->left();
			child3 = sibling->right()->left();
			child4 = sibling->right()->right();

			parent->setLeft(sibling);
			parent->setRight(sibling->right());
			sibling->setParent(parent);
			sibling->right()->setParent(parent);

			parent->left()->setLeft(child1);
			parent->left()->setRight(child2);
			parent->right()->setLeft(child3);
			parent->right()->setRight(child4);


			if(child1 != NULL){
				child1->setParent(parent->left());
			}
			if(child2 != NULL){
				child2->setParent(parent->left());
			}
			if(child3 != NULL){
				child3->setParent(parent->right());
			}
			if(child4 != NULL){
				child4->setParent(parent->right());
			}
			
			//swap value
			int tempKey= parent->key();
			int tempValue = parent->value();

			parent->setKey(sibling->key());
			parent->setValue(sibling->value());
			sibling->setKey(tempKey);
			sibling->setValue(tempValue);

			doubleBlack(doubleBlackNode,parent->left());	

				
		}

	}




}

bool IntRBTree::remove(int k)
{


   IntEntry* target;
   IntEntry* LMINode;
   IntEntry* doubleBlackNode;
   IntEntry* doubleBNParent;
   int doubleBlackFlag = 0;
   
   // First start with BST remove

   if(empty()) return false;
  
   
   target = search(k,T.getRoot());


   //key is found

   if(target->key() == k){

     if(target->value() == 1){

         // if target is external node
         if(target->isExternal()){

	    if(target->isRoot()){
		cnt--;
		delete target;
		T.setRoot(NULL);
		return true;
	    }


	    if(target->color()== IntEntry::BLACK){
		doubleBlackFlag = 1;
		doubleBlackNode = NULL;
		doubleBNParent = target->parent();
	    }	    


            if(target->isRoot()){
               T.setRoot(NULL);
            
            }
            else if(target== target->parent()->left()){
               target->parent()->setLeft(NULL);
            }
            else{
               target->parent()->setRight(NULL);
            }
            delete(target);
            cnt--;
	    if(!doubleBlackFlag) return true;
            
         }
   

         else if(target->right() == NULL && target->left() != NULL){
	    // set the flags
	    if(target->color() == IntEntry::RED || target->left()->color() == IntEntry::RED  ){
		target->left()->setColor(IntEntry::BLACK);
	    }
	    else{
		doubleBlackFlag = 1;
		doubleBlackNode = target->left();
		doubleBNParent = target->parent();
	    }


            if(target->isRoot()){
		
               T.setRoot(target->left());
               target->left()->setParent(NULL);
            }
            else if(target == target->parent()->right()){
               target->parent()->setRight(target->left());
               target->left()->setParent(target->parent());
            }

            else{
            
               target->parent()->setLeft(target->left());
               target->left()->setParent(target->parent());
            }
            
            cnt--;
            delete(target);
            
	    if(!doubleBlackFlag) return true;
         }


         else if(target->right() != NULL && target->left() == NULL){
	    // set the flags
	    if(target->color() == IntEntry::RED || target->right()->color() == IntEntry::RED  ){
		target->right()->setColor(IntEntry::BLACK);
	    }
	    else{
		doubleBlackFlag = 1;
		doubleBlackNode = target->right();
		doubleBNParent = target->parent();
	    }	  
 
            if(target->isRoot()){

               T.setRoot(target->right());
               target->right()->setParent(NULL);
            }
            else if(target == target->parent()->right()){                  
               target->parent()->setRight(target->right());
               target->right()->setParent(target->parent());
            }
            else{
               target->parent()->setLeft(target->right());
               target->right()->setParent(target->parent());
            }
         
            cnt--;
            delete(target);
            
	    if(!doubleBlackFlag) return true;

         }

   
         else {    
		
      	 	  // key is in Internal node
       	 	 LMINode = findLMINode(target->right());
	
		 // set the flags
	 	if(LMINode->right() != NULL){

		 	if(LMINode->color() == IntEntry::RED || LMINode->right()->color() == IntEntry::RED  ){

				LMINode->right()->setColor(IntEntry::BLACK);
		 	}
		 	else{
				doubleBlackFlag = 1;
				doubleBlackNode = LMINode->right();
				doubleBNParent = LMINode->parent();

		 	}
	 	}
		else{ // LMINode->right() == NULL 

			if(LMINode->color() == IntEntry::BLACK){ 
				doubleBlackFlag = 1;
				doubleBlackNode = LMINode->right();
				doubleBNParent = LMINode->parent();
					
			}
			
	 	}
         
         	target->setKey(LMINode->key());
         	target->setValue(LMINode->value());      
         
         	if(LMINode == LMINode->parent()->left()){

            		LMINode->parent()->setLeft(LMINode->right());

            		if(LMINode->right() != NULL) LMINode->right()->setParent(LMINode->parent());
                              
         	}
         	else{
            
            		LMINode->parent()->setRight(LMINode->right());
            
            		if(LMINode->right() != NULL) LMINode->right()->setParent(LMINode->parent());
         	}

         	delete(LMINode);
         	cnt--;
		
		if(!doubleBlackFlag) return true;

	}
         
      }
      
      else{ // value is more than 1
         
         target->setValue(target->value()-1);
         cnt--;
         return true;
         
      }

         
   }
   
   //key not found
   else{
      return false;
   }


   // BST remove complete


   doubleBlack(doubleBlackNode, doubleBNParent);
   return true;

}
