/* 
Name: Kim JunBeum 
Number of Assignment: 1
Name of the File: wc209.c
*/


#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <assert.h>

enum DFAState {SPACE,NONSPACE,COMMENT,NONSPACE_SLASH,
	       SPACE_SLASH,COMMENT_STAR};

/* Description about DFAstate
-SPACE/NONSPACE: The most recent input character
                 is space/nonspace character  
-COMMENT: The input character is part of a comment
-NONSPACE_SLASH : when slash is input during NONSPACE state  
-SPACE_SLASH : when slash is input during SPACE state
-COMMENT_Star when star is input during COMMENT state 
*/

int c;
int nLines = 0;
int nWords = 0;
int nCharacters = 0;
int line_of_error = 0;
enum DFAState state = SPACE;


int space(void){
 /*Function for state SPACE
 increases the value of the global variables */
  if(isspace(c)){
     if (c == '\n'){nLines++; nCharacters++;}
     else nCharacters++;}
  else{
     if( c == '/'){state = SPACE_SLASH; nWords++;
       nCharacters++;}
     else {state = NONSPACE; nWords++; nCharacters++;}}
  return 0;}

int nonspace(void){
 /*Function for state NONSPACE
  increases the value of the global variables */ 
  if(isspace(c))
    if( c == '\n'){state = SPACE; nLines++; nCharacters++;}
    else {state = SPACE;  nCharacters++;}
  else
    if( c == '/'){state = NONSPACE_SLASH; nCharacters++;}
    else nCharacters++;
  return 0;}

int nonspace_slash(void){
 /*Function for state NONSPACE_SLASH
   increases the value of the global variables */
  if(isspace(c))
    if( c == '\n'){state = SPACE; nLines++; nCharacters++;}
    else nCharacters++;
  else
    if( c == '*'){state = COMMENT;line_of_error = nLines;} 
    else if( c == '/'){nCharacters++;}
    else{state = NONSPACE; nCharacters++;}
  return 0;}

int space_slash(void){
 /*Function for state SPACE_SLASH
 increases or decreases the value of the global variables*/
  if(isspace(c))
    if( c == '\n'){state = SPACE;nLines++;nCharacters++;}
    else nCharacters++;
  else
    if(c == '*'){state = COMMENT;
      line_of_error = nLines; nWords--;}
    else if( c == '/'){state = NONSPACE_SLASH; nCharacters++;}
    else{state = NONSPACE; nCharacters++;}
  return 0;}

int comment(void){
 /*Function for state COMMENT
   increases the value of the global variables */
  if( c == '*'){state = COMMENT_STAR;}
  else if( c == '\n'){nLines++;nCharacters++;}
  return 0;}

int comment_star(void){
  /*Function for state COMMENT_STAR
    increases the value of the global variables */ 
  if( c == '/'){state = SPACE; line_of_error = 0;}
  else if(c == '\n'){state = COMMENT; nLines++;nCharacters++;}
  else if(c == '*'){state = COMMENT_STAR;}
  else state = COMMENT;
  return 0;}


int main(void){
/*Gets character from std input and runs a function, 
considering the state. After running function,
 main() prints the number of lines, words, characters*/


  if((c = getchar()) != EOF){ nLines++; space();}

  else{ fprintf(stdout,"%d %d %d",nLines,nWords,nCharacters);
    return EXIT_SUCCESS; }
  /*If nothing is input, return*/



  
  while( (c= getchar()) != EOF){
    switch(state){
    case SPACE:
      space();
      break;
    case NONSPACE:
      nonspace();
      break;
    case NONSPACE_SLASH:
      nonspace_slash();
      break;
    case SPACE_SLASH:
      space_slash();
      break;
    case COMMENT:
      comment();
      break;    
    case COMMENT_STAR:
      comment_star();
      break;
    default:
      assert(0);
      break;
    }
  }  
  if (state == COMMENT || state == COMMENT_STAR){
    /*when comment is not terminated print error */
    fprintf(stderr,"Error: line %d: unterminated comment\n",line_of_error);
    return EXIT_FAILURE;}

  else fprintf(stdout,"%d %d %d",nLines,nWords,nCharacters);
  return EXIT_SUCCESS;
  
}
