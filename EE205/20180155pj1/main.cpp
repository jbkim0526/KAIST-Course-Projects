#include <iostream>
#include <stdexcept>
#include <string>
#include "student.h"



// //****************************************************************
// //                   MAIN FUNCTION IN PROJECT
// //****************************************************************

int main()
{  
  char command;
  Manager myman;
  int isgrad;
  std::string name;
  int stunum;
  std::string labname;
  int freshmenclass;
  int index;
  bool isLast=true;


  while(isLast){
	std::cout << "\n\n\n*---------------------Welcome to Student Management System---------------------*" << std::endl;
	std::cout << "What do you want to do?\n1. Add student:a\n2. Compare student:c \n3. Find student:f\n4. Delete student:d\n5. Print all student:p\n6. Quit:q" << std::endl;

	// ******Modify here****** 
	//You need to handle wrong argument format
	std::cin >> command;
	switch(command)
	  {
	  case 'a':{
		// Type of student you want to add (Graduate student or Undergraduate student)
		std::cout << "Add student executed\n\nType\nUndergraduate:0 Graduate:1"<< std::endl;
		
		// ******Modify here****** 
		//You need to handle wrong argument format

		std::cin >> isgrad;
		if (isgrad == 1){
		  std::cout << "\nFormat: [name stunum labname]" << std::endl;
		  
		  // ******Modify here****** 
		  //You need to handle wrong argument format
		  std::cin >> name >> stunum >> labname;

                  if(stunum <= 0 ){
		     std::cout << "stunum has to be positive!\n";
                     break;	
		  }
		  myman.add_student(name, stunum, labname);		  
		}

		else if (isgrad == 0){
		  std::cout << "\nFormat: [name stunum freshmenclass] " << std::endl;
		  
		  // ******Modify here****** 
		  //You need to handle wrong argument format
		  std::cin >> name >> stunum >> freshmenclass;
                  if(stunum <= 0 ){
		     std::cout << "stunum has to be positive!\n";
                     break;	
		  }
		  if(freshmenclass <= 0 ){
		     std::cout << "class number has to be positive!\n";
                     break;	
		  }
		  myman.add_student(name, stunum, freshmenclass);		  
		}
		
	  }break;

	  case 'c':{
		std::cout << "Compare student executed\n\nType\nUndergraduate:0 Graduate:1" << std::endl;
		
		// ******Modify here****** 
		//You need to handle wrong argument format
		std::cin >> isgrad;
		if (isgrad == 1){
		  std::cout << "\nTarget student\nFormat: [index name stunum labname]" << std::endl;
		  
		  // ******Modify here****** 
		  //You need to handle wrong argument format
		  std::cin >> index >> name >> stunum >> labname;

 		  if(stunum <= 0 ){
		     std::cout << "stunum has to be positive!\n";
                     break;	
		  }	
	 
		  myman.compare_student(index, name, stunum, labname);
		}

		else if (isgrad == 0){
		  std::cout << "\nTarget student\nFormat: [index name stunum freshmenclass] " << std::endl;
		  std::cin >> index >> name >> stunum >> freshmenclass;

		  if(stunum <= 0 ){
		     std::cout << "stunum has to be positive!\n";
                     break;	
		  }

		  if(freshmenclass <= 0 ){
		     std::cout << "class number has to be positive!\n";
                     break;	
		  }

		  myman.compare_student(index, name, stunum, freshmenclass);
		}
	  }break;

	  case 'f':{
		std::cout << "Find student executed\n\nType\nUndergraduate:0 Graduate:1" << std::endl;
		
		// ******Modify here****** 
		//You need to handle wrong argument format
		std::cin >> isgrad;

		if (isgrad == 1){
		  std::cout << "\nFormat: [name stunum labname]" << std::endl;

		  // ******Modify here****** 
		  //You need to handle wrong argument format
		  std::cin >> name >> stunum >> labname;

		  if(stunum <= 0 ){
		     std::cout << "stunum has to be positive!\n";
                     break;	
		  }

		  myman.find_student(name, stunum, labname);
		}
		else if (isgrad == 0){
		  std::cout << "\nFormat: [name stunum freshmenclass]" << std::endl;

		  // ******Modify here****** 
		  //You need to handle wrong argument format
		  std::cin >> name >> stunum >> freshmenclass;

		  if(stunum <= 0 ){
		     std::cout << "stunum has to be positive!\n";
                     break;	
		  }

		  if(freshmenclass <= 0 ){
		     std::cout << "class number has to be positive!\n";
                     break;	
		  }

		  myman.find_student(name, stunum, freshmenclass);
		}
	  }break;


	  case 'd':{
		std::cout << "Delete student executed\n\nType\nUndergraduate:0 Graduate:1" << std::endl;

		// ******Modify here****** 
		//You need to handle wrong argument format
		std::cin >> isgrad;

		if (isgrad == 1){
		  std::cout << "\nFormat: [name stunum labname]" << std::endl;
		  
		  // ******Modify here****** 
		  //You need to handle wrong argument format
		  std::cin >> name >> stunum >> labname;
		
		  if(stunum <= 0 ){
		     std::cout << "stunum has to be positive!\n";
                     break;	
		  }

		  myman.delete_student(name, stunum, labname);
		}
		else if (isgrad == 0){
		  std::cout << "\nFormat: [name stunum freshmenclass]" << std::endl;
		  
		  // ******Modify here****** 
		  //You need to handle wrong argument format
		  std::cin >> name >> stunum >> freshmenclass;

		  if(stunum <= 0 ){
		     std::cout << "stunum has to be positive!\n";
                     break;	
		  }

		  if(freshmenclass <= 0 ){
		     std::cout << "class number has to be positive!\n";
                     break;	
		  }

		  myman.delete_student(name, stunum, freshmenclass);
		}
	  }break;

	  case 'p':{
		std::cout << "Print all executed" << std::endl;
		myman.print_all();
	  }break;

	  case 'q':{
	  std::cout << "Quit" << std::endl;
	  isLast = false;
	  }break;

	  default:{
		std::cout << "Invalid argument" << std::endl;
	  }break;
	  }
  }
  return 0;
}

