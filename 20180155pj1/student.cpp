#include <iostream>
#include "student.h"

// //****************************************************************
// //                   REQUIRED FUNCTIONALITY IN PROJECT
// //****************************************************************

// 1. You need to implement every detail of the function defined below
// 2. You additionally need to implement getInfo methods in each classes.
// 3. You additionally need to implement 'operator overloading' with '==' which compares two students whether all the members are the same




bool operator== (const Student& x, const Student& y)
{
  // operator overloading 
  // Check whether two students x, y have same information (stunum, name, class) or not. 
  // Returns true if two students are the same or false otherwise.
  // This function must be used in "find_student()"


  int x_stu_num = x.get_stu_num();
  std::string x_stu_name = x.get_name();
  int x_freshmen_class = x.get_freshmen_class();
  std::string x_lab_name = x.get_lab_name();

  int y_stu_num = y.get_stu_num();
  std::string y_stu_name = y.get_name();
  int y_freshmen_class = y.get_freshmen_class();
  std::string y_lab_name = y.get_lab_name();   
  
  if(x_lab_name == "" && y_lab_name == ""){ // undergrad , undergrad
    return (x_stu_num == y_stu_num && x_stu_name == y_stu_name && x_freshmen_class == y_freshmen_class)? true : false;
  }
 
  if(x_lab_name == "" && y_freshmen_class == 0){ // undergrad , grad
    return false;
  }

  if(x_freshmen_class == 0 && y_lab_name == ""){ // grad , undergrad
    return false;
  }
  if(x_freshmen_class == 0 && y_freshmen_class == 0){ // grad , grad
    return (x_stu_num == y_stu_num && x_stu_name == y_stu_name && x_lab_name == y_lab_name)? true : false;
  }
}


int Manager::add_student(std::string name, int stunum, std::string labname)
{
  // Adds a Grad_Student object with given arguments
  // stunum should be positive and unique across the student array. 
  // If successful, this function returns the total number of objects in the student array or -1 if it fails. If a student with the same stunum already exists, this function should fail.

  if(stunum <= 0){
    std::cout << "stunum has to be positive!\n";
    return -1;
  }

  if(num == 300){ 
    std::cout << "Manager Array is Full!\n";
    return -1;
  }

  for(int i = 0 ; i < num ; i++){
    if(stunum == studentArray[i]->get_stu_num()){
       std::cout << "stunum should be unique across the student array!\n";	  
       return -1; 
    }
  }
  
  Grad_Student* grad_student = new Grad_Student(stunum,name,labname);
  studentArray[num] = grad_student;
  num++;
  std::cout << "add graduate student DONE" << std::endl;
  return num;
}

int Manager::add_student(std::string name, int stunum, int freshmenclass)
{
  // Adds an Undergrad_Student object with given arguments
  // stunum should be positive and unique across the student array. 
  // If successful, this function returns the total number of objects in the student array or -1 if it fails. If a student with the same stunum already exists, this function should fail.


  if(stunum <= 0){
    std::cout << "stunum has to be positive!\n";
    return -1;
  }
  if(freshmenclass <= 0){
    std::cout << "class number has to be positive!\n";
    return -1;
  }

  if(num == 300){ 
    std::cout << "Manager Array is Full!\n";
    return -1;
  }

  for(int i = 0 ; i < num ; i++){
    if(stunum == studentArray[i]->get_stu_num()){
       std::cout << "stunum should be unique across the student array!\n";	  
       return -1; 
    }
  }

  Undergrad_Student* undergrad_student = new Undergrad_Student(stunum,name,freshmenclass);
  studentArray[num] = undergrad_student;
  num++;
  
  std::cout << "add undergraduate student DONE" << std::endl;
  return num;
}

bool Manager::compare_student(int index, std::string name, int stunum, int freshmenclass)
{
 // Compares whether the element at "index" in the student array has the same undergraduate student described by the arguments.
  // If "index" is out of range of the student array, it should fail and return false.
  // Returns true if they are the same or false otherwise
  if(index>=num || index < 0) return false;
   
  if(stunum <= 0){
    std::cout << "stunum has to be positive!\n";
    return false;
  }

  if(freshmenclass <= 0){
    std::cout << "class number has to be positive!\n";
    return false;
  }
 
  Student* temp = studentArray[index]; 
  
  int stu_num = temp->get_stu_num();
  std::string stu_name = temp->get_name();
  int freshmen_class =temp->get_freshmen_class();

  if(stu_num == stunum && stu_name == name && freshmen_class == freshmenclass){
    std::cout << "compare to undergraduate student DONE" << std::endl;
    return true;
  }
  else{
    std::cout << "compare to undergraduate student DONE" << std::endl;
    return false;
  }
}

bool Manager::compare_student(int index, std::string name, int stunum, std::string labname)
{
  // Compares whether the element at "index" in the student array has the same graduate student described by the arguments.
  // If "index" is out of range of the student array, it should fail and return false.
  // Returns true if they are the same or false otherwise


  if(index>=num || index < 0) return false;
   
  if(stunum <= 0){
    std::cout << "stunum has to be positive!\n";
    return false;
  }
  
  Student* temp = studentArray[index]; 
  
  int stu_num = temp->get_stu_num();
  std::string stu_name = temp->get_name();
  std::string lab_name = temp->get_lab_name();

  if(stu_num == stunum && stu_name == name && lab_name == labname){
    std::cout << "compare to undergraduate student DONE" << std::endl;
    return true;
  }
  else{
    std::cout << "compare to undergraduate student DONE" << std::endl;
    return false;
  }
}

int Manager::find_student(std::string name, int stunum, std::string labname)
{
  // Finds the Grad_Student object in the student array that matches the provided arguments
  // Returns the array index of a matched object (an array index starts from 0), -1 if there's no match
 

  if(stunum <= 0){
    std::cout << "stunum has to be positive!\n";
    return -1;
  }

  Student *grad_student = new Grad_Student(stunum,name,labname);


  for(int i = 0 ; i < num ; i++){
     if( *grad_student == *studentArray[i]){	
       return i;
    }
  }
  delete grad_student;
  std::cout << "find graduate student DONE" << std::endl;
  return -1;
}

int Manager::find_student(std::string name, int stunum, int freshmenclass)
{
  // Finds the Undergrad_Student object in the student array that matches the provided arguments
  // Returns the array index of a matched object (an array index starts from 0), -1 if there's no match
 
 if(stunum <= 0){
    std::cout << "stunum has to be positive!\n";
    return -1;
  }
 if(freshmenclass <= 0){
    std::cout << "class number has to be positive!\n";
    return -1;
  }
  Student *undergrad_student = new Undergrad_Student(stunum,name,freshmenclass);
  for(int i = 0 ; i < num ; i++){
     if( *undergrad_student == *studentArray[i]){	
       return i;
    }
  }
  delete undergrad_student;
  std::cout << "find undergraduate student DONE" << std::endl;
  return -1;
}

int Manager::delete_student(std::string name, int stunum, std::string labname)
{
  // Deletes the Grad_Student object in the student array that matches the provided arguments
  // If successful, it returns the total number of objects in the student array after deleting
  // If there is no object that matches the argument object, it return -1.

  if(stunum <= 0){
    std::cout << "stunum has to be positive!\n";
    return -1;
  }

  int index = find_student(name,stunum,labname);
  if(index == -1 ) return -1;
  delete studentArray[index];
  for(int i = index ; i < num -1 ; i++){
     studentArray[i] = studentArray[i+1];
  }
  num--;

  std::cout << "delete graduate student DONE" << std::endl;
  return num;
}

int Manager::delete_student(std::string name, int stunum, int freshmenclass)
{
  // Deletes the Undergrad_Student object in the student array that matches the provided arguments
  // If successful, it returns the total number of objects in the student array after deleting
  // If there is no object that matches the argument object, it return -1.


  if(stunum <= 0){
    std::cout << "stunum has to be positive!\n";
    return -1;
  }

 if(freshmenclass <= 0){
    std::cout << "class number has to be positive!\n";
    return -1;
  }

  int index = find_student(name,stunum,freshmenclass); 
  if(index == -1 ) return -1;
  delete studentArray[index];
  for(int i = index ; i < num -1 ; i++){
     studentArray[i] = studentArray[i+1];
  }
  num--;


  std::cout << "delete undergraduate student DONE" << std::endl;
  return num;
}



int Manager::print_all()
{
  // Prints all the information of an existing object in the student array
  // Returns the total number of objects in the student array

  for( int i = 0 ; i < num ; i++){
     studentArray[i]->getInfo();
  }
  std::cout << "print all DONE" << std::endl;
  return 0;
}




int Student::get_stu_num() const {
  return stu_num;
}

std::string Student::get_name() const {
  return name;
}

int Student::get_freshmen_class() const {
  return 0;
}

std::string Student::get_lab_name() const {
  return ""; 
}

int Undergrad_Student::get_freshmen_class() const {
  return freshmen_class;
}

std::string Grad_Student::get_lab_name() const {
  return lab_name;
}

Student::Student(int _stu_num, std::string _name){
	stu_num = _stu_num;
	name = _name;
}

Grad_Student::Grad_Student(int _stu_num, std::string _name,std::string _lab_name):Student(_stu_num,_name){
	lab_name = _lab_name;

}

Undergrad_Student::Undergrad_Student(int _stu_num, std::string _name,int _freshmen_class):Student(_stu_num,_name){
	freshmen_class = _freshmen_class;
}

void Student::getInfo(){
	std::cout<<"Student Number : "<<stu_num<< std::endl;
	std::cout<<"Name : "<<name<< std::endl;
}

void Grad_Student::getInfo(){
	std::cout<<"Student Number : "<<stu_num<< " | ";
	std::cout<<"Name : "<<name<<" | ";
	std::cout<<"Lab Name : "<< lab_name << std::endl;
}

void Undergrad_Student::getInfo(){
	std::cout<<"Student Number : "<<stu_num<< " | ";
	std::cout<<"Name : "<<name<< " | ";
	std::cout<<"Freshmen Class : "<< freshmen_class << std::endl;
}


