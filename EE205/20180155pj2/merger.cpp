#include <iostream>
#include <stdexcept>
#include <string>


class Node{

public:
	int getOffset() const;
	int getLength() const;
	int getEnd() const;
	void setLength(int n);
	Node* getNext() const;
	void setNext(Node* n);
	
	Node(int offset, int length);

private:
	int start;
	int end;
	Node* next; 	

};

Node::Node(int _offset ,int _length){
	start = _offset;
	end = _offset + _length;
}

int Node::getOffset() const {
	return start;
}

int Node::getLength() const {
	return end - start;
}

int Node::getEnd() const {
	return end ;
}

void Node::setLength(int n){
	end = start + n;
}

Node* Node::getNext() const {
	return next;
}
void Node::setNext(Node* n){
	next =  n;
}

class SortedLinkedList{

public:
	SortedLinkedList();
	void addLine(int offset,int length);
	void mergeLine1();
	void mergeLine2();
	void printAll();
	int getNum();	 

private:
	Node* head;
	int num = 0;
};


SortedLinkedList::SortedLinkedList(){
	head = NULL;
}

int SortedLinkedList::getNum(){
	return num;	
}


void SortedLinkedList::printAll(){
	if(num == 0){ std::cout << "no element"; return;}
	Node *p = head; 
	for(p ; p != NULL ; p= p->getNext()){
		std::cout << p->getOffset() <<" " << p->getLength() <<std::endl;
		
	}	
}	

//adds Node in increasing offset
void SortedLinkedList::addLine(int offset,int length){


	Node* p;

	Node* pBefore = NULL;	
	int count = 0;
	// no elements in List
	if(head == NULL){
		Node* n = new Node(offset,length);
		head = n;
		n->setNext(NULL);
		num++;
		return;
	}

	else{

		for(p = head, pBefore = p ; p != NULL ; p = p->getNext()){
			
			int pOff = p->getOffset();
			if( pOff < offset ){
				pBefore = p;
				count++;
				continue;
			}
			else{	
				Node* n = new Node(offset,length);

				if(count == 0){
					n->setNext(head);
					head = n;
					num++;
				}
				else{
					n->setNext(pBefore->getNext());
					pBefore->setNext(n);
					num++;
				}
				return;
			}
			

		}
		if(p == NULL ){
			Node* n = new Node(offset,length);
			n->setNext(pBefore->getNext());
			pBefore->setNext(n);
			num++;
			return;
		}

		

	}
	

}

void SortedLinkedList::mergeLine1(){

	
	Node* p;
	Node* q;
	Node* r;
	int off;
	int maxLen; 


	if(num == 1) return;

	for(p = head ; p != NULL ; ){

		maxLen = p->getLength();
		off = p->getOffset();

		for(q = p->getNext() ; ; ){

			
			if(q == NULL || q->getOffset() != off){ 
				p = q;
				break;
			}			

			maxLen = (maxLen < q->getLength())? q->getLength(): maxLen;


			//this part is for deleting q;
			r = q->getNext();
			if(r == NULL || r->getOffset() != off){
				p->setLength(maxLen);
				p->setNext(r);
				num--;
				delete q;
		
				if( r == NULL) return;

				p = r;
				break;
			}
			else{
				
				num--;		
				delete q;
				q = r;
					
			}
		}
		
		 

	}

}

void SortedLinkedList::mergeLine2(){

	Node* p;
	Node* q;
	Node* r;
	int start;
	int end;

	if(num == 1) return;

	for(p = head ; p != NULL ; ){

		start = p->getOffset();
		end = p->getEnd();

		for(q = p->getNext() ; ; ){

			if(q == NULL){p = q;  break;}

			if(q->getOffset() > end ){
				p->setNext(q);
				p = q;
				break;
			}

			
			end = ( end < q->getEnd()) ? q->getEnd() : end ; 
			p->setLength(end-start);

			r = q->getNext();
			
			if(r == NULL ){
				p->setNext(NULL);
				delete q;
				num--;
				break;
			}
			if( r->getOffset() > end ){
				p->setNext(r);
				p = r;
				delete q;
				num--;
				break;
			}
			
			delete q;
			num--;
			q = r;
			
		}


	}

}


int main(){
		
	SortedLinkedList* sll = new SortedLinkedList();
	std::string arg1;
	std::string arg2;
	int a1;
	int a2;
	while(1){
		std::cin >> arg1;
		std::cin >> arg2;	
		if(std::cin.eof()) break;
		a1 = atoi(arg1.c_str());
		a2 = atoi(arg2.c_str());
		if(a1 < 0 ){
			std::cout << "Offset has to be non negative!\n";
			return -1;
		}
		if(a2 <= 0){
			std::cout << "Length has to be positive!\n";
			return -1;
		}
		sll->addLine(a1,a2);
	}
	sll->mergeLine1();
	sll->mergeLine2();
	sll->printAll();

	delete sll;

	return 0;

}
