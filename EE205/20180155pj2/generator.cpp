#include <iostream>
#include <stdexcept>
#include <string>


void printParentheses(int n , int oParNum , int cParNum , std::string string ){

	
	if(cParNum == n ){ std::cout << string << std::endl; return; }


	// if open parentheses's positions are all determined
	if(oParNum == n ){ 
		for( int i = cParNum ; i < n ; i++){
			string += ")";		
		}
		std::cout << string << std::endl; 
		return;
	}

	//always makes oParNum > cParNum 
	if(cParNum == oParNum ){  
		string += "(";
		oParNum++;
	}  


	if( oParNum < n ) printParentheses(n,oParNum + 1, cParNum,string+"(");

	//since oParNum > cParNum 
	printParentheses(n,oParNum ,cParNum + 1,string+")");

}


int 	main( int argc , char* argv[] ){


	int n;
	if(argv[1] == NULL){
		std::cout << "There is no Input\n";
		return -1;
	}
	std::string s = "(";
	n = atoi(argv[1]);
 	
	if( n < 0 || n > 20){
		std::cout << "Input is not in range [1:20]\n"; return -1;}

	printParentheses(n,1,0,s);	
	

	return 0;

}


