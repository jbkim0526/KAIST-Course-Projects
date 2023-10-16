/*
Name: Kim JunBeum
Number of the assignment: 2
The name of the file: str.c
*/

#include <assert.h> 
#include <stdio.h>
#include "str.h"


/* gets source and returns its length */
size_t StrGetLength(const char* pcSrc)
{
  const char *pcEnd;
  assert(pcSrc); /* NULL address, 0, and FALSE are identical. */
  pcEnd = pcSrc;
	
  while (*pcEnd) /* null character and FALSE are identical. */
    pcEnd++;

  return (size_t)(pcEnd - pcSrc);
}

/* copies Source to the Destination and returns pointer to Dest */
char *StrCopy(char *pcDest, const char*pcSrc)
{
  size_t pcSrcLength;
  char *destPointer;
  pcSrcLength = StrGetLength(pcSrc);
  
  assert( pcDest != NULL && pcSrc != NULL);
  if(pcSrcLength == 0){ *pcDest = *pcSrc; return pcDest;}

  destPointer = pcDest; 
  while (*pcSrc != '\0'){
    *destPointer = *pcSrc;
    destPointer++;
    pcSrc++;       /* ends before including '\0'*/
  }
  *destPointer = '\0';
  return pcDest;
}

/* compares Str1 and Str2. returns positive, negative, zero integer 
  if Str1 is bigger than, smaller than, same to Str2 respectively. */
int StrCompare(const char* pcStr1, const char* pcStr2)
{
  assert(pcStr1 != NULL && pcStr2 != NULL);
  while (*pcStr1 != '\0' && *pcStr2 != '\0'){
    if( *pcStr1 > *pcStr2 ) return 1;
    else if( *pcStr1 < *pcStr2) return -1;
    else {pcStr1++; pcStr2++;}
  }   
  if( *pcStr1 == '\0' && *pcStr2 != '\0') return -1;
  if( *pcStr1 != '\0' && *pcStr2 == '\0') return 1;
  return 0;
}

/* gets Haystack, Needle. if there is Needle in a Haystack 
 returns pointer to the common part. if not, returns NULL pointer */
char *StrSearch(const char* pcHaystack, const char *pcNeedle)
{ 
  int count_num = 0;  
  size_t Haystack_len,Needle_len;
  const char *pivot, *NeedleStart; 
  /* pivot is for points we want to investigate */
  Haystack_len = StrGetLength(pcHaystack);
  Needle_len = StrGetLength(pcNeedle);
  pivot = pcHaystack, NeedleStart = pcNeedle; 

  assert(pcHaystack != NULL && pcNeedle != NULL);
  if (Haystack_len == 0 && Needle_len == 0) 
    return (char*)pivot;
  if (Needle_len == 0) return (char*)pivot;
  if (Haystack_len == 0 ) return NULL;   
  
  for(int i= 0; i< Haystack_len; i++){
    if( *pivot == *NeedleStart){
      count_num = 0 ;
      while( *pcNeedle != '\0'){ 
        pcHaystack++, pcNeedle++, count_num++; 
        if (*pcHaystack == *pcNeedle) continue;
        else {
          if(*pcNeedle != '\0') pivot++; 
          pcHaystack = pivot; 
          pcNeedle = NeedleStart; break;
        }   
      }
      if(count_num == Needle_len) return (char*)pivot;   
    } 
    else { pcHaystack++; pivot++;}  
  }   
  return NULL;
}

/* gets Source and attach it to the Destination.
   returns pointer to Destination  */
char *StrConcat(char *pcDest, const char* pcSrc)
{
  assert(pcDest != NULL && pcSrc != NULL);
  char *pcDestStart = pcDest;
  size_t dest_len, src_len;
  dest_len = StrGetLength(pcDest);
  src_len = StrGetLength(pcSrc);
  for(int i=0; i < dest_len; i++){
    pcDest++;
  }
  for(int i=0; i < src_len; i++){
    *pcDest = *pcSrc;
    pcDest++;
    pcSrc++; 
  }
  return pcDestStart;
}
