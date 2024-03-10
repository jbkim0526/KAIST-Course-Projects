/*
Name: Kim JunBeum
Number of Assignment: 3
Name of The File: customer_manager2.c 
*/



#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "customer_manager.h"



#define UNIT_ARRAY_SIZE 1024
#define MAX_ARRAY_SIZE 1048576

enum {HASH_MULTIPLIER = 65599};

struct UserInfo{
  char *name;                // customer name
  char *id;                  // customer id
  int purchase; // purchase amount (> 0)
  struct UserInfo *id_next; 
  struct UserInfo *name_next;
};
       

struct DB {
  struct UserInfo **id_pt;   // pointer to id hash table
  struct UserInfo **name_pt; // pointer to name hash table 
  int curArrSize;            // current array size (max # of elements)
  int numItems;              // # of stored items, needed to determine
			     // # whether the array should be expanded
			     // # or not
};


static int hash_function(const char *pcKey, int iBucketCount)
/* Return a hash code for pcKey that is between 0 and iBucketCount-1,
 inclusive. Adapted from the EE209 lecture notes. */
{
 int i;
 unsigned int uiHash = 0U;
 for (i = 0; pcKey[i] != '\0'; i++)
 uiHash = uiHash * (unsigned int)HASH_MULTIPLIER
 + (unsigned int)pcKey[i];
 return (int)(uiHash % (unsigned int)iBucketCount);
}



/* Extend hashtable of the given DataBase and return it */
DB_T extend_hashtable(DB_T d){
  DB_T new_d;
  struct UserInfo *p;

  
  new_d = (DB_T) calloc(1, sizeof(struct DB));
  if (d == NULL) {
    fprintf(stderr, "Can't allocate a memory for DB_T\n");
    return NULL;
  }
 
  new_d->curArrSize = (d->curArrSize);
  new_d->id_pt = calloc(new_d->curArrSize, sizeof(struct UserInfo*));
  if (new_d->id_pt == NULL) {
    fprintf(stderr, "Can't allocate a memory for array of size %d\n",
	    new_d->curArrSize);   
    free(new_d);
    return NULL;
  }
  
  new_d->name_pt=calloc(new_d->curArrSize, sizeof(struct UserInfo*));
  if (new_d->name_pt == NULL) {
    fprintf(stderr, "Can't allocate a memory for array of size %d\n",
	    new_d->curArrSize);   
    free(new_d);
    return NULL;
  }
  /* Copy d into new_d */
  for(int i = 0 ; i < d->curArrSize ; i++){  
    for( p = d->id_pt[i] ; p != NULL ; p = p->id_next){
      RegisterCustomer(new_d, (const char*)p->id, 
  (const char*)p->name,(const int) p->purchase);	
    } 
  }
  /* Expand d and fill it with UserInfo*/ 
  d->curArrSize = 2*(new_d->curArrSize);
  d->numItems = 0;
  d->id_pt = calloc(2*(new_d->curArrSize),sizeof(struct UserInfo*));
  d->name_pt = calloc(2*(new_d->curArrSize),sizeof(struct UserInfo*));
 

  for(int i = 0 ; i < new_d->curArrSize ; i++){  
    for( p = new_d->id_pt[i] ; p != NULL ; p = p->id_next){
      RegisterCustomer(d, (const char*)p->id, 
      (const char*)p->name,(const int) p->purchase);	
    } 
  }    
  return d;

}


/* Create DataBase */
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
  
  d->id_pt = calloc(d->curArrSize, sizeof(struct UserInfo*));
  if (d->id_pt == NULL) {
    fprintf(stderr, "Can't allocate a memory for array of size %d\n",
	    d->curArrSize);   
    free(d);
    return NULL;
  }
  
  d->name_pt = calloc(d->curArrSize, sizeof(struct UserInfo*));
  if (d->name_pt == NULL) {
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
  struct UserInfo *p; 
  assert(d != NULL); 
  for(int i = 0 ; i < d->curArrSize; i++){  
    for( p = d->id_pt[i] ; p != NULL ; p = p->id_next){
      free(p->name);
      free(p->id);
    }  
    free(d->id_pt[i]);
  }
  free(d->id_pt);
  free(d->name_pt);
  free(d);
  d = NULL;


}
/*Register Customer info in DataBase */
int
RegisterCustomer(DB_T d, const char *id,
		 const char *name, const int purchase)
{ 
  
  int id_index, name_index;
  struct UserInfo *p, *q,*r;
  if( d == NULL || id == NULL || name == NULL) return -1;
  if( purchase <= 0 ) return -1;
  
  /*If number of item reaches 0.75 of the Arrsize,
    extend the hashtable*/
  if( d->numItems >= 0.75*(d->curArrSize) && 
      d->curArrSize < MAX_ARRAY_SIZE ){
     d = extend_hashtable(d);
  }

  id_index = hash_function(id,d->curArrSize);
  name_index = hash_function(name,d->curArrSize);
  
  /*if there is same id or name, failure */
  for(p = d->id_pt[id_index]; p != NULL; p = p->id_next){
    if( strcmp(p->id,id) == 0)return -1;
  }
  for(q = d->name_pt[name_index]; q != NULL; q = q->name_next){
    
    if( strcmp(q->name,name) == 0)return -1;
  }
  
  /*create user info*/
  r = (struct UserInfo*)calloc(1,sizeof(struct UserInfo));
  r-> name = strdup(name);
  r-> id = strdup(id); 
  r-> purchase = purchase;
  r-> id_next = d->id_pt[id_index];
  r-> name_next = d->name_pt[name_index];
  d->id_pt[id_index] = r;
  d->name_pt[name_index] = r;
  d->numItems += 1;

  return 0;
  
}
/*Remove Customer info using ID*/
int
UnregisterCustomerByID(DB_T d, const char *id)
{
  if( d == NULL || id == NULL) return -1;
  int id_index, name_index , check_id = 0, 
  count_id = 0, count_name = 0;
  struct UserInfo *p_id,*p_name,*q_id,*q_name;
  id_index = hash_function(id,d->curArrSize);
  for(p_id = d->id_pt[id_index] ; p_id != NULL;){ 
    if(strcmp(p_id->id,id) == 0){check_id++; break;}
    q_id = p_id;       
    p_id = p_id->id_next; 
    count_id++;
  }  
   /*p_id is the "target" q_id is just one before target*/
 
  if(check_id == 0){return -1;} /*if there is no match for id */
  
  name_index = hash_function(p_id->name,d->curArrSize);
  for(p_name = d->name_pt[name_index] ; p_name != NULL;){ 
    if(strcmp(p_id->name,p_name->name) == 0){break;}
    q_name = p_name;
    p_name = p_name->name_next;
    count_name++;
  }
  free(p_id->name); 
  free(p_id->id);

  if(count_id == 0 && count_name == 0){  
    d->id_pt[id_index] = p_id->id_next;
    d->name_pt[name_index] = p_name->name_next;    
  }              
  else if(count_id != 0 && count_name == 0){
    q_id->id_next = p_id->id_next;
    d->name_pt[name_index] = p_name->name_next;   
  }  
  else if(count_id == 0 && count_name != 0){
    d->id_pt[id_index] = p_id -> id_next;
    q_name->name_next = p_name->name_next;
  }
  else{
    q_id->id_next = p_id->id_next;
    q_name->name_next = p_name->name_next;
  }   
  
  p_id->name = NULL;
  p_id->id = NULL;
  p_id->purchase = 0 ;
  free(p_id);
  d->numItems -= 1;
  return 0;         
 
}

/*Remove Customer info using Name*/
int
UnregisterCustomerByName(DB_T d, const char *name)
{
  if( d == NULL || name == NULL) return -1;
  int id_index, name_index , check_name = 0, 
  count_id = 0, count_name= 0;
  struct UserInfo *p_id,*p_name,*q_id,*q_name;
  name_index = hash_function(name,d->curArrSize);

  for(p_name = d->name_pt[name_index] ; p_name != NULL;){ 
    if(strcmp(p_name->name,name) == 0){check_name++; break;}
    q_name = p_name;       
    p_name = p_name->name_next; 
    count_name++;
  }  
  /*p_name is the target, q_name is just one before target*/
  if(check_name == 0){return -1;} /*if there is no match for id */
  
  id_index = hash_function(p_name->id,d->curArrSize);
  for(p_id = d->id_pt[id_index] ; p_id != NULL;){ 
    if(strcmp(p_name->id,p_id->id) == 0){break;}
    q_id = p_id;
    p_id = p_id->id_next;
    count_id++;
  }

  free(p_name->name); 
  free(p_name->id);
  if(count_id == 0 && count_name == 0){   /*when p is first*/
    d->id_pt[id_index] = p_id->id_next;
    d->name_pt[name_index] = p_name->name_next;    
  }              
  else if(count_id != 0 && count_name == 0){
    q_id->id_next = p_id->id_next;
    d->name_pt[name_index] = p_name->name_next;   
  }  
  else if(count_id == 0 && count_name != 0){
    d->id_pt[id_index] = p_id -> id_next;
    q_name->name_next = p_name->name_next;
  }
  else{
    q_id->id_next = p_id->id_next;
    q_name->name_next = p_name->name_next;
  } 

  p_name->name = NULL;
  p_name->id = NULL;
  p_name->purchase = 0 ;  
  free(p_name);
  d->numItems -= 1;
  return 0; 
}
/*Get the purchase info of customer using Id*/
int
GetPurchaseByID(DB_T d, const char* id)
{
  if( d == NULL || id == NULL) return -1; 
  struct UserInfo *p;
  int id_index, check = 0 ;
  id_index = hash_function(id,d->curArrSize); 
  for(p = d->id_pt[id_index]; p != NULL; p = p->id_next){
    if(strcmp(p->id,id) == 0){check++; break;}
  }
  if(check == 0){ return -1;}
  return p->purchase;
  
}
/*Get the purchase info of customer using Name*/
int
GetPurchaseByName(DB_T d, const char* name)
{
  if( d == NULL || name == NULL) return -1; 
  struct UserInfo *p;
  int name_index, check = 0 ;
  name_index = hash_function(name,d->curArrSize); 
  
  for(p = d->name_pt[name_index]; p != NULL; p = p->name_next){
    
    if(strcmp(p->name,name) == 0){check++; break;}
  }
  
  if(check == 0){ return -1;}
  return p->purchase;
  
}
/*Get the sum of Purchase from output of given function*/
int
GetSumCustomerPurchase(DB_T d, FUNCPTR_T fp)
{
  int sum = 0;
  struct UserInfo *p; 
  if(d == NULL || fp == NULL) return -1;
  
  for(int i = 0 ; i < d->curArrSize; i++){  
    for( p = d->id_pt[i] ; p != NULL ; p = p->id_next){
      sum += (*fp)(p->id,p->name,p->purchase);
    }  
  }
  return sum;
}
