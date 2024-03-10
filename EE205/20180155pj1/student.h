// //***************************************************************
// //                   CLASS USED IN PROJECT
// //****************************************************************


class Student{
	// ******Modify here******
	// You need to properly define member variable in Student class
 private:
 protected:
	int stu_num;
	std::string name;
 public:
	// ******Modify here******
	// You need to implement get function which prints out every information about student argument in pure virtual function here
	Student(int,std::string);
	virtual void getInfo();
	int get_stu_num() const ;
	std::string get_name() const;
	virtual int get_freshmen_class() const;
	virtual std::string get_lab_name() const;
};

class Grad_Student: public Student{
	// ******Modify here******
	// You need to properly define member variable in Grad_Student class
 private:
	std::string lab_name;
 protected:
 public:
	// ******Modify here******
	// You need to implement get function in detail
	Grad_Student(int,std::string,std::string);
	void getInfo();
        std::string get_lab_name() const ;
};

class Undergrad_Student: public Student{
	// ******Modify here******
	// You need to properly define member variable in Undergrad_Student class
 private:
	int freshmen_class;
 protected:
 public:
	// ******Modify here******
	// You need to implement get function in detail
	Undergrad_Student(int,std::string,int);
	void getInfo();
	int get_freshmen_class() const ;
};


class Manager{
	// ******Modify here******
	// You need to properly define member variable in Manager class
 private:
	int num = 0;
	Student* studentArray[300];
 protected:
 
 public:
	// ******Modify here******
	// You need to implement every methods in Manager class
	int add_student(std::string name, int stunum, std::string labname);
	int add_student(std::string name, int stunum, int freshmenclass);
	bool compare_student(int index, std::string name, int stunum, std::string labname);
	bool compare_student(int index, std::string name, int stunum, int freshmenclass);
	int find_student(std::string name, int stunum, std::string labname);
	int find_student(std::string name, int stunum, int freshemenclass);
	int delete_student(std::string name, int stunum, std::string labname);
	int delete_student(std::string name, int stunum, int freshmenclass);
	int print_all();

};
