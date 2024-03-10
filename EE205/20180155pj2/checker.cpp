#include <iostream>
#include <stdexcept>
#include <string>


int	main(){
	
	std::string line;
	int correct = 0;
	int wrong = 0;
	int val = 0;

	while( 1 ){
		val = 0 ;
		std::cin >> line;	
		if(std::cin.eof()) break;

		for(int i = 0 ; i < line.length() ; i++){
			if(line[i] == '(') val++;
			if(line[i] == ')') val--;

			if(val < 0 ){
				wrong++;
				break;
			}
		}
		if(val < 0) continue;

		if(val != 0){
			wrong++;
			continue;
		}
		
		correct++;
	}

	std::cout << "correct " <<correct << ", " <<"wrong " << wrong << std::endl ;

	


	return 0;

}
