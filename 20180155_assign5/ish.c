/*--------------------------------------------------------------------*/
/* dfa.c                                                              */
/*--------------------------------------------------------------------*/

#include "dynarray.h"
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <wait.h>

/*--------------------------------------------------------------------*/

enum {MAX_LINE_SIZE = 1024};

enum {FALSE, TRUE};

enum TokenType {TOKEN_WORD, TOKEN_VB};

/*--------------------------------------------------------------------*/

/* A Token is either a word or vertical bar, expressed as a string. */

struct Token
{
   enum TokenType eType;
   /* The type of the token. */

   char *pcValue;
   /* The string which is the token's value. */
};

/*--------------------------------------------------------------------*/

static void freeToken(void *pvItem, void *pvExtra)

/* Free token pvItem.  pvExtra is unused. */

{
   struct Token *psToken = (struct Token*)pvItem;
   free(psToken->pcValue);
   free(psToken);
}



static struct Token *makeToken(enum TokenType eTokenType,
   char *pcValue)

/* Create and return a Token whose type is eTokenType and whose
   value consists of string pcValue.  Return NULL if insufficient
   memory is available.  The caller owns the Token. */

{
   struct Token *psToken;

   psToken = (struct Token*)malloc(sizeof(struct Token));
   if (psToken == NULL)
      return NULL;

   psToken->eType = eTokenType;

   psToken->pcValue = (char*)malloc(strlen(pcValue) + 1);
   if (psToken->pcValue == NULL)
   {
      free(psToken);
      return NULL;
   }

   strcpy(psToken->pcValue, pcValue);

   return psToken;
}



/*--------------------------------------------------------------------*/

static int lexLine(const char *pcLine, DynArray_T oTokens)

/* Lexically analyze string pcLine.  Populate oTokens with the
   tokens that pcLine contains.  Return 1 (TRUE) if successful, or
   0 (FALSE) otherwise.  In the latter case, oTokens may contain
   tokens that were discovered before the error. The caller owns the
   tokens placed in oTokens. */

/* lexLine() uses a DFA approach.  It "reads" its characters from
   pcLine. */

{
   enum LexState {STATE_START, STATE_WORD, STATE_DOUBLEQUOTE};

   enum LexState eState = STATE_START;

   int iLineIndex = 0;
   int iValueIndex = 0 ;
   char c;
   char acValue[MAX_LINE_SIZE];
   struct Token *psToken;

   assert(pcLine != NULL);
   assert(oTokens != NULL);

   for (;;)
   {
      /* "Read" the next character from pcLine. */
      c = pcLine[iLineIndex++];

      switch (eState)
      {
         case STATE_START:
            if ((c == '\n') || (c == '\0'))
               return TRUE;
	    else if ( c == '\"')
            {
               eState = STATE_DOUBLEQUOTE;
	    } 
            else if ( c == '|') 
            {
               /* Create a VB token. */
	       acValue[iValueIndex++] = c;      
               acValue[iValueIndex] = '\0';
               psToken = makeToken(TOKEN_VB, acValue);
               if (psToken == NULL)
               {
                  fprintf(stderr, "Cannot allocate memory\n");
                  return FALSE;
               }
               if (! DynArray_add(oTokens, psToken))
               {
                  fprintf(stderr, "Cannot allocate memory\n");
                  return FALSE;
               }
               iValueIndex = 0;
            }
            else if (isspace(c))
               eState = STATE_START;
            else
            {
               acValue[iValueIndex++] = c;
               eState = STATE_WORD;
            }
            break;

         case STATE_WORD:
            if ((c == '\n') || (c == '\0'))
            {
               /* Create a WORD token. */
               acValue[iValueIndex] = '\0';
               psToken = makeToken(TOKEN_WORD, acValue);
               if (psToken == NULL)
               {
                  fprintf(stderr, "Cannot allocate memory\n");
                  return FALSE;
               }
               if (! DynArray_add(oTokens, psToken))
               {
                  fprintf(stderr, "Cannot allocate memory\n");
                  return FALSE;
               }
               iValueIndex = 0;
	       return TRUE;

            }
            else if (c == '|')
            {
               /* Create a WORD token. */
               acValue[iValueIndex] = '\0';
               psToken = makeToken(TOKEN_WORD, acValue);
               if (psToken == NULL)
               {
                  fprintf(stderr, "Cannot allocate memory\n");
                  return FALSE;
               }
               if (! DynArray_add(oTokens, psToken))
               {
                  fprintf(stderr, "Cannot allocate memory\n");
                  return FALSE;
               }
               iValueIndex = 0;

	       /* Create a VB token. */
               acValue[iValueIndex++] = c;  
               acValue[iValueIndex] = '\0';
               psToken = makeToken(TOKEN_VB, acValue);
               if (psToken == NULL)
               {
                  fprintf(stderr, "Cannot allocate memory\n");
                  return FALSE;
               }
               if (! DynArray_add(oTokens, psToken))
               {
                  fprintf(stderr, "Cannot allocate memory\n");
                  return FALSE;
               }
               iValueIndex = 0;
	       eState = STATE_START;	
            }
            else if (c == '\"')
            {
               eState = STATE_DOUBLEQUOTE;
            }
	    else if (isspace(c))
            {
               /* Create a WORD token. */
               acValue[iValueIndex] = '\0';
               psToken = makeToken(TOKEN_WORD, acValue);
               if (psToken == NULL)
               {
                  fprintf(stderr, "Cannot allocate memory\n");
                  return FALSE;
               }
               if (! DynArray_add(oTokens, psToken))
               {
                  fprintf(stderr, "Cannot allocate memory\n");
                  return FALSE;
               }
               iValueIndex = 0;
               eState = STATE_START;
            }
            else
            {
               acValue[iValueIndex++] = c;
            }
            break;

         case STATE_DOUBLEQUOTE:
 	    if ((c == '\n') || (c == '\0'))
	    {
               fprintf(stderr, "ERROR - unmatched quote");
	       return FALSE;
            }
	    else if ( c == '\"' )
	    {
               eState = STATE_WORD;
	    }
	    else
	    {
               acValue[iValueIndex++] = c;
	    }
 	    break;
	
         default:
            assert(FALSE);
      }
   }
}


/* Do syntatic analysis of given oDynArray.
   return 0 at success, -1 at failure, 1 when oDynArray is empty */
int DynArray_syntactic(DynArray_T oDynArray)
{
   struct Token *psToken, *psToken2 ;
   int length;
   length = DynArray_getLength(oDynArray);
   if( length == 0 ){
      return 1 ;
   }
   psToken =  DynArray_get(oDynArray,0);
    
   if( psToken->eType == TOKEN_VB)
   {
      fprintf(stderr, "Missing command name\n");
      return -1;
   }
   for (int i = 1; i < length; i++)
   {
      psToken = DynArray_get(oDynArray,i);
      psToken2 = DynArray_get(oDynArray,i-1);
      if( psToken->eType == TOKEN_VB && psToken2->eType == TOKEN_VB)
      {
         fprintf(stderr,
                "Pipe or redirection destination not specified\n");
         return -1;
      }
   }
   psToken =  DynArray_get(oDynArray,length-1);
   if( psToken->eType == TOKEN_VB )
   {
      fprintf(stderr,
                 "Pipe or redirection destination not specified\n");
      return -1;
   }
   return 0;
}

/* checks if we can change directory or not and if we can,
   it changes directory and return 0 */
int change_directory(char *command[],int cmd_index)
{
   int c = 0;
   if(cmd_index == 1)
   {
      c = chdir("/home"); 
      if( c == -1)
      {
    	 fprintf(stderr,"./ish.c: No such file or directory\n");
      } 
   }
   if(cmd_index == 2)
   {
      c = chdir(*(command+1));
      if( c == -1)  
      {
         fprintf(stderr,"./ish.c: No such file or directory\n");
      } 
   }
   if(cmd_index > 2)
   {
      fprintf(stderr,"./ish.c: cd takes one parameter\n");
   }
   return 0;
}

/* check whether we can set an environment variable or not
   if we can, set the variable and return 0*/
int BC_setenv(char *command[],int cmd_index)
{
   if(cmd_index == 1)
   {
      fprintf(stderr,"./ish.c: setenv takes one or two parameters\n");
   }
   if(cmd_index == 2)
   {
      setenv(*(command+1),"",1);
   }
   if(cmd_index == 3)
   {
      setenv(*(command+1),*(command+2),1);
   }
   if(cmd_index > 3)
   {
      fprintf(stderr,"./ish.c: setenv takes one or two parameters\n");
   }
   return 0;
}

/* remove the existing environment variable and return 0*/
int BC_unsetenv(char *command[],int cmd_index)
{
   if(cmd_index == 1)
   {
      fprintf(stderr,"./ish.c: unsetenv takes one parameter\n");
   }
   if(cmd_index == 2)
   {
      unsetenv(*(command+1));
   }
   if(cmd_index > 2)
   {
      fprintf(stderr,"./ish.c: unsetenv takes one parameter\n");
   }
   return 0;
}


/*Analyze the command line in oDynArray and execute the line*/
int DynArray_Execution(DynArray_T oDynArray)
{
   int length = DynArray_getLength(oDynArray);
   int token_index = 0;
   int cmd_index = 0;
   int pipe_num = 0;
   int cmd_num = 0; 
   char *command[length][length];
   char *value ;
   
   struct Token *psToken ;
   
   for(;token_index < length;)
   {  cmd_index = 0;
      for(;token_index < length;)
      {  
         psToken = DynArray_get(oDynArray,token_index);
         value  = psToken->pcValue ;
         if( psToken->eType == TOKEN_VB )
         {  
            token_index++;
            pipe_num++;
            break;
         }
         else if( psToken->eType == TOKEN_WORD )
         {  
            command[cmd_num][cmd_index] = value;
            cmd_index++;
            token_index++;
         }
         else break; 
      }
      command[cmd_num][cmd_index] = NULL;
      cmd_num++;

      if( pipe_num != 0) continue;
      /*When there is no pipe operator*/
      if(strcmp(command[cmd_num-1][0],"cd") == 0)
      {  
         change_directory(command[cmd_num-1],cmd_index);
         return 0;
      }
      if(strcmp(command[cmd_num-1][0],"setenv") == 0)
      {  
         BC_setenv(command[cmd_num-1],cmd_index);
         return 0;
      }
      if(strcmp(command[cmd_num-1][0],"unsetenv") == 0)
      {  
         BC_unsetenv(command[cmd_num-1],cmd_index);
         return 0;
      }
      if(strcmp(command[cmd_num-1][0],"exit") == 0)
      {
         DynArray_map(oDynArray, freeToken, NULL);
         DynArray_free(oDynArray);
         exit(0);
      }
      pid_t iPid;
      iPid = getpid();
      fflush(NULL);
      iPid = fork();
      if (iPid == 0) 
      {  
         execvp(command[cmd_num-1][0], command[cmd_num-1]);
         perror(command[cmd_num-1][0]);
         exit(EXIT_FAILURE);
      }
      iPid = wait(NULL);

      if (iPid == -1) 
      {
        perror(command[cmd_num-1][0]);
        return EXIT_FAILURE;
      }
   }
   /*When there are pipe operator in command line*/
   if( pipe_num != 0 )
   {
      pid_t pid;
      int fds[2*pipe_num];
      for( int i = 0; i < pipe_num; i++ )
      {
         if( pipe(fds+ i*2) < 0 )
         {
            exit(EXIT_FAILURE);
         }
      }
      for (int i = 0; i< pipe_num; i++)
      {  printf("%s\n",command[i][0]);
         fflush(NULL);
         pid = fork();
         if (pid == -1)
         {
            exit(EXIT_FAILURE);
         }
         if (pid == 0)
         {  
            if (i == 0)
            { 
               dup2(fds[1],1);
               close(fds[1]);
               execvp(command[0][0], command[0]);
               perror(command[0][0]);
               exit(EXIT_FAILURE);
            }
            else if( i == (pipe_num-1))
            {  
               dup2(fds[2*i],0);
               close(fds[2*i]);  
               execvp(command[i+1][0], command[i+1]);
               perror(command[i+1][0]);
               exit(EXIT_FAILURE);
            }
            else
            {
               dup2(fds[2*i],0);
               dup2(fds[2*i+3],1);
               close(fds[2*i]);
               close(fds[2*i+3]);
               execvp(command[i+1][0], command[i+1]);
               perror(command[i+1][0]);
               exit(EXIT_FAILURE);
            }
         }

         if( i == 0){
            dup2(fds[0],0);
            close(fds[0]); 
            dup2(fds[3],1);
            close(fds[3]);
            execvp(command[1][0], command[1]);
            perror(command[1][0]);
            exit(EXIT_FAILURE);
         }
         wait(NULL);
      }
   }

   return 0;
}


/*--------------------------------------------------------------------*/

int main(void)

/* Read a line from stdin, and write to stdout each VB and word
   that it contains.  Repeat until EOF.  Return 0 if successful. */

{
   char acLine[MAX_LINE_SIZE];
   DynArray_T oTokens;
   int lexSuccessful;
   int synSuccessful;
   FILE *fp;
   fp = fopen(".ishrc","r");

   /*Getting an input line from .ishrc*/
   while (fp != NULL && fgets(acLine, MAX_LINE_SIZE, fp) != NULL)
   {  
      printf("%% %s",acLine);
      oTokens = DynArray_new(0);
      if (oTokens == NULL)
      {
         fprintf(stderr, "Cannot allocate memory\n");
         exit(EXIT_FAILURE);
      }
      
      lexSuccessful = lexLine(acLine, oTokens);
      if (lexSuccessful)
      {
	 synSuccessful = DynArray_syntactic(oTokens);     
      }  
      if (synSuccessful < 0)
      {
	 continue;
      }
      if (synSuccessful == 1)
      { 
         continue;
      }
      DynArray_Execution(oTokens); 
     
      DynArray_map(oTokens, freeToken, NULL);
      DynArray_free(oTokens);
   }
   /*Getting an input line from standard input*/
   if( fp != NULL) fclose(fp);
   printf("%% ");
   while (fgets(acLine, MAX_LINE_SIZE, stdin) != NULL)
   { 
      
      oTokens = DynArray_new(0);
      if (oTokens == NULL)
      {
         fprintf(stderr, "Cannot allocate memory\n");
         exit(EXIT_FAILURE);
      }
      
      lexSuccessful = lexLine(acLine, oTokens);
      if (lexSuccessful)
      {
	 synSuccessful = DynArray_syntactic(oTokens);     
      }  
      if (synSuccessful < 0)
      {
	 exit(EXIT_FAILURE);
      }
      if (synSuccessful == 1)
      { 

         continue;
      }
      DynArray_Execution(oTokens); 
      DynArray_map(oTokens, freeToken, NULL);
      DynArray_free(oTokens);
      printf("%% ");
   }
   return 0;
}
