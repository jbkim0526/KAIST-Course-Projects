/* 
Name: Kim JunBeum
Number of the assignment: 2
The name of the file: sgrep.c 
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> /* for getopt */
#include "str.h"


#define FIND_STR        "-f"
#define REPLACE_STR     "-r"
#define DIFF_STR        "-d"

#define MAX_STR_LEN 1023

#define FALSE 0
#define TRUE  1

typedef enum {
  INVALID,
  FIND,
  REPLACE,
  DIFF
} CommandType;


/* StrRip searchs str1 in line, rip line in two part. 
   print former to stdout and return the latter */
char *StrRip(char *line, char const *pcStr1, char const *pcStr2){
  char *lineStart,*lineEnd,*tempPointer,*linePivot;
  /* lineStart,End refers to the points in line
    where str1 starts, ends respectively */
  
  size_t str1_len;
  char temp[MAX_STR_LEN + 2];  
  char emptyStr = '\0';
  for( int i = 0; i < MAX_STR_LEN + 2 ; i++){
    temp[i] = emptyStr;
  }
  
  lineStart = StrSearch(line,pcStr1);
  lineEnd = lineStart;
  str1_len = StrGetLength(pcStr1);
  lineEnd  +=  str1_len;
  tempPointer = temp; 
  linePivot = line;
 

  
  /* printing the former */
  while(line != lineStart){
    fprintf(stdout,"%c",*line);   
    line++;
  }
  fprintf(stdout,"%s",pcStr2);
 

  /* ripping back part and return */
  while(*lineEnd != '\0'){  
    *tempPointer = *lineEnd;
    tempPointer++;
    lineEnd++; 
  }
  StrCopy(linePivot,temp);
  return linePivot;
}


void 
PrintUsage(const char* argv0) 
{
  const static char *fmt = 
    "Simple Grep (sgrep) Usage:\n"
    "%s [COMMAND] [OPTIONS]...\n"
    "\nCOMMNAD\n"
    "\tFind: -f [search-string]\n"
    "\tReplace: -r [string1] [string2]\n"
    "\tDiff: -d [file1] [file2]\n";

  printf(fmt, argv0);
}

/* read line from stdin and store in buf.
   if there is pcSearch in buf, print buf to stdout */
int
DoFind(const char *pcSearch)  
{
  char buf[MAX_STR_LEN + 2]; 
  int line_len;
  size_t pcSearch_len; 
   
  pcSearch_len = StrGetLength(pcSearch);
  if (pcSearch_len > MAX_STR_LEN){
    fprintf(stderr, "Error: argument is too long\n");
    return FALSE;
  }
  while (fgets(buf, sizeof(buf), stdin)){     
    if ((line_len = StrGetLength(buf)) > MAX_STR_LEN) {
      fprintf(stderr, "Error: input line is too long\n");
      return FALSE;
    }  
    if(StrSearch(buf,pcSearch) == NULL) continue;
    else fprintf(stdout, "%s",buf);
  }
   
  return TRUE;
}


/* reads line from stdin and store in buf. If pcString1 is in buf, 
   it uses StrRip until there is no pcString in buf */
int
DoReplace(const char *pcString1, const char *pcString2)
{
  size_t pcStr1_len, pcStr2_len;
  char buf[MAX_STR_LEN + 2];
  pcStr1_len = StrGetLength(pcString1);
  pcStr2_len = StrGetLength(pcString2); 

  if (pcStr1_len > MAX_STR_LEN || pcStr2_len > MAX_STR_LEN){
    fprintf(stderr,"Error: argument is too long");
    return FALSE;
  } 
  if (pcStr1_len == 0){
    fprintf(stderr,"Error: Can't replace an empty substring");
    return FALSE;
  }  
  while (fgets(buf, sizeof(buf), stdin)){     
    if (StrGetLength(buf) > MAX_STR_LEN) {
      fprintf(stderr, "Error: input line is too long\n");
      return FALSE;
    }
    /* uses StrRip until there is no pcString in buf */
    while( StrSearch(buf,pcString1)){ 
      StrCopy(buf,StrRip(buf,pcString1,pcString2)); 
    }
    fprintf(stdout,"%s",buf);
  }
  
  return TRUE;
}

/* reads line1 line2 from file1, file2 
   prints out lines that are different to stdout*/
int
DoDiff(const char *file1, const char *file2)
{
  char buf1[MAX_STR_LEN + 2], buf2[MAX_STR_LEN + 2];
  size_t file1_len, file2_len, line1_len, line2_len;
  file1_len = StrGetLength(file1);
  file2_len = StrGetLength(file2);
  int linenum = 0, check_buf1 = 0, check_buf2 = 0;
  
  if(file1_len > MAX_STR_LEN || file2_len > MAX_STR_LEN){
    fprintf(stderr,"Error: arugment is too long");
    return FALSE;
  }
  FILE *f1 = fopen(file1,"r");
  FILE *f2 = fopen(file2,"r");
  
  if( f1 == NULL){
    fprintf(stderr,"Error: failed to open file [%s]\n",file1);
    return FALSE;
  }
  if( f2 == NULL){
    fprintf(stderr,"Error: failed to open file [%s]\n",file2);
    return FALSE;
  }

  while(TRUE){   
    if(fgets(buf1,sizeof(buf1),f1) == NULL) check_buf1++;  
    if(fgets(buf2,sizeof(buf2),f2) == NULL) check_buf2++;
    if(check_buf1 == 1 && check_buf2 == 1) break;
    if(check_buf1 == 1){
      fprintf(stderr,"Error: [%s] ends early at line %d\n",
      file1,linenum);  
      return FALSE;
    } 
    if(check_buf2 == 1){
      fprintf(stderr,"Error: [%s] ends early at line %d\n",
      file2,linenum);  
      return FALSE;
    } 
    linenum++;
    line1_len = StrGetLength(buf1);
    line2_len = StrGetLength(buf2);
    
    if(line1_len > MAX_STR_LEN){
      fprintf(stderr,"Error: input line [%s] is too long",file1);
      return FALSE;
    }
    if(line2_len > MAX_STR_LEN){
      fprintf(stderr,"Error: input line [%s] is too long",file2);
      return FALSE;
    }
    
    if (StrCompare(buf1,buf2) == 0 )continue;
    else{
      fprintf(stdout,"%s@%d:%s",file1,linenum,buf1);
      fprintf(stdout,"%s@%d:%s",file2,linenum,buf2);
    }
  }
  return TRUE;
}

int CommandCheck(const int argc, const char *argv1)
{
  int cmdtype = INVALID;
   
  /* check minimum number of argument */
  if (argc < 3)
    return cmdtype;  /*if argc < 3 -> no input file*/
   
  /* check command type */ 
  if (StrCompare(argv1, FIND_STR) == 0) {  /* if argv1 == "-f" */
    if (argc != 3)
      return FALSE;    
    cmdtype = FIND;       
  }
  else if (StrCompare(argv1, REPLACE_STR) == 0) {
    if (argc != 4)
      return FALSE;
    cmdtype = REPLACE;
  }
  else if (StrCompare(argv1, DIFF_STR) == 0) {
    if (argc != 4)
      return FALSE;
    cmdtype = DIFF;
  }
   
  return cmdtype;
}

int 
main(const int argc, const char *argv[]) 
{
  int type, ret; 
   
  /* Do argument check and parsing */
  if (!(type = CommandCheck(argc, argv[1]))) {  
                        
    fprintf(stderr, "Error: argument parsing error\n");
    PrintUsage(argv[0]);
    return (EXIT_FAILURE);
  }
   
  /* Do appropriate job */
  switch (type) {
  case FIND:
    ret = DoFind(argv[2]);   
    break;
  case REPLACE:
    ret = DoReplace(argv[2], argv[3]);   
    break;
  case DIFF:
    ret = DoDiff(argv[2], argv[3]);
    break;
  } 

  return (ret)? EXIT_SUCCESS : EXIT_FAILURE;
}
