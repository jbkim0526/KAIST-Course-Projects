/*
Name: Kim JunBeum
Number of Assignment: 3
Name of The File: customer_manager1.c 
*/

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "customer_manager.h"
#define UNIT_ARRAY_SIZE 1024

struct UserInfo {
  char *name;                // customer name
  char *id;                  // customer id
  int purchase;              // purchase amount (> 0)
};

struct DB {
  struct UserInfo *pArray;   // pointer to the array
  int curArrSize;            // current array size (max # of elements)
  int numItems;              // # of stored items, needed to determine
              // # whether the array should be expanded
              // # or not
};



/* create DataBase */
DB_T
CreateCustomerDB(void)
{ 
  DB_T d;
  
  d = (DB_T) calloc(1, sizeof(struct DB));
  if (d == NULL) {
    fprintf(stderr, "Can't allocate a memory for DB_T\n");
    return NULL;
  }
  d->curArrSize = UNIT_ARRAY_SIZE; // start with 1024 elements
  d->pArray = (struct UserInfo *)calloc(d->curArrSize,
               sizeof(struct UserInfo));
  if (d->pArray == NULL) {
    fprintf(stderr, "Can't allocate a memory for array of size %d\n",
       d->curArrSize);   
    free(d);
    return NULL;
  }
  return d;
}

/* Destroy DataBase */
void
DestroyCustomerDB(DB_T d)
{ 
  if(d == NULL) return;
  for( int i = 0 ; i < d->curArrSize ; i++){
    free((d->pArray+i)->name); 
    free((d->pArray+i)->id);   
  }
  free(d->pArray);
  free(d);
  
}

/* Register Customer info in DataBase */
int
RegisterCustomer(DB_T d, const char *id,
       const char *name, const int purchase)
{ 
  int empty_index = 0 ,count = 0, i = 0 , check = 0 ;
  if( d == NULL || id == NULL || name == NULL) return -1;
  if( purchase <= 0 ) return -1;
  
  if( d->numItems >= d->curArrSize){
    d->curArrSize += UNIT_ARRAY_SIZE;
    d->pArray = (struct UserInfo *)realloc(d->pArray,
             (d->curArrSize)*sizeof(struct UserInfo) ); 
  }

  /*check if there is same name or id*/
  while(count < d->numItems){   
    
    /*if it finds first empty array, it remembers the index*/
    if( d->pArray[i].name == NULL && d->pArray[i].id == NULL){ 
      if(empty_index == 0){
        empty_index = i;
      }
      i++;
      check++;
      continue;
    }
    
    /*if it is not empty array*/ 
    if( strcmp(d->pArray[i].name,name) == 0){
      return -1;
    }
    if( strcmp(d->pArray[i].id,id) == 0){
      return -1;
    }
    i++;
    count++;
  }
  if(check == 0){empty_index = i;} 

  d->pArray[empty_index].id = strdup(id);
  d->pArray[empty_index].name = strdup(name);
  d->pArray[empty_index].purchase = purchase;
  d->numItems += 1 ;
  return 0;
}

/* Remove Customer info using ID */
int
UnregisterCustomerByID(DB_T d, const char *id)
{ 
  int i = 0, count = 0;
  if(d == NULL || id == NULL) return -1;
  
  while(count < d->numItems){
     
     if((d->pArray+i)->name == NULL && (d->pArray+i)->id == NULL){ 
     i++;  
     continue; 
     } 

     if(strcmp((d->pArray+i)->id,id) == 0){
        free((d->pArray+i)->name); 
        free((d->pArray+i)->id);
        (d->pArray+i)->name = NULL;
        (d->pArray+i)->id = NULL;
        (d->pArray+i)->purchase = 0;
        d->numItems -= 1 ;
        return 0;
     }
     i++; 
     count++; 
  }

  return -1;
}

/* Remove Customer info using Name */
int
UnregisterCustomerByName(DB_T d, const char *name)
{ 
  int i = 0, count = 0;
  if(d == NULL || name == NULL) return -1;
  
  while(count < d->numItems){
     
     if((d->pArray+i)->name == NULL && (d->pArray+i)->id == NULL){ 
     i++;  
     continue; 
     } 

     if(strcmp((d->pArray+i)->name,name) == 0){
        free((d->pArray+i)->name); 
        free((d->pArray+i)->id);
        (d->pArray+i)->name = NULL;
        (d->pArray+i)->id = NULL;
        (d->pArray+i)->purchase = 0;
        d->numItems -= 1 ;
        return 0;
     }
     i++; 
     count++; 
  }

  return -1;
}

/*Get the purchase info if customer using Id */
int
GetPurchaseByID(DB_T d, const char* id)
{
  int i = 0, count = 0;
  if(d == NULL || id == NULL) return -1;
  
  while(count < d->numItems){
     
     if((d->pArray+i)->name == NULL && (d->pArray+i)->id == NULL){ 
     i++;  
     continue; 
     } 

     if(strcmp((d->pArray+i)->id,id) == 0){
       return (d->pArray+i)->purchase; 
     }
     i++; 
     count++; 
  }

  return -1;
}
/*Get the purchase info of customer using Name */
int
GetPurchaseByName(DB_T d, const char* name)
{
  int i = 0, count = 0;
  if(d == NULL || name == NULL) return -1;
  
  while(count < d->numItems){
     
     if((d->pArray+i)->name == NULL && (d->pArray+i)->id == NULL){ 
     i++;  
     continue; 
     } 

     if(strcmp((d->pArray+i)->name,name) == 0){
       return (d->pArray+i)->purchase;  
     }
     i++; 
     count++; 
  }

  return -1;
}

/*Get the sum of Purchase from output of given function */
int
GetSumCustomerPurchase(DB_T d, FUNCPTR_T fp)
{ 
  int sum = 0 , count = 0 , i = 0;

  if(d == NULL || fp == NULL) return -1;
  
  while(count < d->numItems){
    if((d->pArray+i)->name == NULL && (d->pArray+i)->id == NULL){
      i++;    
      continue;
    }
    sum += (*fp)( (d->pArray+i)->id , (d->pArray+i)->name ,
           (d->pArray+i)->purchase );
    i++;
    count++;

  } 
  return sum;
}
