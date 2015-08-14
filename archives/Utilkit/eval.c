//--------------------------------------------------------------------
// Evaluate an expression
//--------------------------------------------------------------------
// 19/08/98		3.0		Laurent Destailleur		Creation
//--------------------------------------------------------------------
#define PROG	"Eval"
#define VERSION	"3.0"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

#include "misc.h"
#include "macros.h"

#define LAST_CHAR(string) (((char *)string)[strlen(string)-1])

// Variables
int i,nosys=-1,multicolonne=0,sub=0;
char c;
char argument[512]="";


struct operator {
      char        token;
      char       *tag;
      size_t      taglen;
      int         precedence;
      };

typedef enum {
		DIV_ZERO = -3,
		R_ERROR = -2,
		E_ERROR = -1,
		SUCCESS = 0
		} STATUS;

static struct operator verbs[] = {
      {'+',  "+",       1, 2 },
      {'-',  "-",       1, 3 },
      {'*',  "*",       1, 4 },
      {'/',  "/",       1, 5 },
      {'\\', "\\",      1, 5 },
      {'^',  "^",       1, 6 },
      {'(',  "(",       1, 0 },
      {')',  ")",       1, 99},
      {'S',  "SIN(",    4, 0 },
      {'C',  "COS(",    4, 0 },
      {'A',  "ABS(",    4, 0 },
      {'L',  "LN(",     3, 0 },
      {'E',  "EXP(",    4, 0 },
      {'t',  "ATAN(",   5, 0 },
      {'s',  "SQRT(",   5, 0 },
      {'\0',  NULL,      0, 0 }
      };
static char   op_stack[256];                    /* Operator stack       */
static double arg_stack[256];                   /* Argument stack       */
static char   token[256];                       /* Token buffer         */
static int    op_sptr,                          /* op_stack pointer     */
	      arg_sptr,                         /* arg_stack pointer    */
	      parens,                           /* Nesting level        */
	      state;                            /* 0 = Awaiting expression */
						/* 1 = Awaiting operator   */

const double Pi=3.14159265358979323846;

int evaluate(char *, double *);
char *rmallws(char *);
static int              do_op(void);
static int              do_paren(void);
static void             push_op(char);
static void             push_arg(double);
static int              pop_arg(double *);
static int              pop_op(int *);
static char            *get_exp(char *);
static struct operator *get_op(char *);
static int              getprec(char);
static int              getTOSprec(void);




char *rmallws(char *str)
//--------------------------------------------------------------------
//
//--------------------------------------------------------------------
/* Supprime espace de str */
{
char *obuf,*nbuf;
for (obuf=str,nbuf=str; *obuf && obuf; ++obuf) {
  if (!isspace(*obuf)) *nbuf++ = *obuf;
  }
*nbuf = '\0';
return str;
}


int evaluate(char *line, double *val)
//--------------------------------------------------------------------
// Evaluates an ASCII mathematical expression
// INPUT:  line:  String to evaluate
//         val:   Storage to receive double result
//   
// RETURN: SUCCESS =  0 if successful  
//         E_ERROR = -1 if syntax error  
//         R_ERROR = -2 if runtime error 
//         DUV_ZERO= -3 Division by 0    
// 
// Side effects: Removes all whitespace from the string and converts
//               it to U.C.
//--------------------------------------------------------------------
{
double arg;
char *ptr = line, *str, *endptr;
int ercode;
struct operator *op;

strupr(line);
rmallws(line);
state = op_sptr = arg_sptr = parens = 0;

while (*ptr)
      {
	    switch (state)
	    {
	    case 0:
		  if (NULL != (str = get_exp(ptr)))
		  {
			if (NULL != (op = get_op(str)) &&
			      strlen(str) == op->taglen)
			{
			      push_op(op->token);
			      ptr += op->taglen;
			      break;
			}

			if (SUCCESS == strcmp(str, "-"))
			{
			      push_op(*str);
			      ++ptr;
			      break;
			}

			if (SUCCESS == strcmp(str, "PI"))
			      push_arg(Pi);

			else
			{
			      if (0.0 == (arg = strtod(str, &endptr)) &&
				    NULL == strchr(str, '0'))
			      {
				    return E_ERROR;
			      }
			      push_arg(arg);
			}
			ptr += strlen(str);
		  }
		  else  return E_ERROR;

		  state = 1;
		  break;

	    case 1:
		  if (NULL != (op = get_op(ptr)))
		  {
			if (')' == *ptr)
			{
			      if (SUCCESS > (ercode = do_paren()))
				    return ercode;
			}
			else
			{
			      while (op_sptr &&
				    op->precedence <= getTOSprec())
			      {
				    do_op();
			      }
			      push_op(op->token);
			      state = 0;
			}

			ptr += op->taglen;
		  }
		  else  return E_ERROR;

		  break;
	    }
      }

      while (1 < arg_sptr)
      {
	    if (SUCCESS > (ercode = do_op()))
		  return ercode;
      }
      if (!op_sptr)
	    return pop_arg(val);
      else  return E_ERROR;
}



/* Evaluate stacked arguments and operands */
static int do_op(void)
{
      double arg1, arg2;
      int op;

      if (E_ERROR == pop_op(&op))
	    return E_ERROR;

      pop_arg(&arg1);
      pop_arg(&arg2);

      switch (op)
      {
      case '+':
	    push_arg(arg2 + arg1);
	    break;

      case '-':
	    push_arg(arg2 - arg1);
	    break;

      case '*':
	    push_arg(arg2 * arg1);
	    break;

      case '/':
	    if (0.0 == arg1) return(DIV_ZERO);
	    push_arg(arg2 / arg1);
	    break;

      case '\\':
	    if (0.0 == arg1)
		  return R_ERROR;
	    push_arg(fmod(arg2, arg1));
	    break;

      case '^':
	    push_arg(pow(arg2, arg1));
	    break;

      case 't':
	    ++arg_sptr;
	    push_arg(atan(arg1));
	    break;

      case 'S':
	    ++arg_sptr;
	    push_arg(sin(arg1));
	    break;

      case 's':
	    if (0.0 > arg2)
		  return R_ERROR;
	    ++arg_sptr;
	    push_arg(sqrt(arg1));
	    break;

      case 'C':
	    ++arg_sptr;
	    push_arg(cos(arg1));
	    break;

      case 'A':
	    ++arg_sptr;
	    push_arg(fabs(arg1));
	    break;

      case 'L':
	    if (0.0 < arg1)
	    {
		  ++arg_sptr;
		  push_arg(log(arg1));
		  break;
	    }
	    else  return R_ERROR;

      case 'E':
	    ++arg_sptr;
	    push_arg(exp(arg1));
	    break;

      case '(':
	    arg_sptr += 2;
	    break;

      default:
	    return E_ERROR;
      }
      if (1 > arg_sptr)
	    return E_ERROR;
      else  return op;
}


/* Evaluate one level */
static int do_paren(void)
{
      int op;
      if (1 > parens--)
	    return E_ERROR;
      do
      {
	    if (SUCCESS > (op = do_op()))
		  break;
      } while (getprec((char)op));
      return op;
}


/* Stack operations */
static void push_op(char op)
{
      if (!getprec(op))
	    ++parens;
      op_stack[op_sptr++] = op;
}

static void push_arg(double arg)
{
      arg_stack[arg_sptr++] = arg;
}

static int pop_arg(double *arg)
{
      *arg = arg_stack[--arg_sptr];
      if (0 > arg_sptr)
	    return E_ERROR;
      else  return SUCCESS;
}

static int pop_op(int *op)
{
      if (!op_sptr)
	    return E_ERROR;
      *op = op_stack[--op_sptr];
      return SUCCESS;
}


/* Get an expression */
static char * get_exp(char *str)
{
      char *ptr = str, *tptr = token;
      struct operator *op;

      if (SUCCESS == strncmp(str, "PI", 2))
	    return strcpy(token, "PI");


      while (*ptr)
      {
	    if (NULL != (op = get_op(ptr)))
	    {
		  if ('-' == *ptr)
		  {
			if (str != ptr && 'E' != ptr[-1])
			      break;
			if (str == ptr && !isdigit(ptr[1]) && '.' != ptr[1])
			{
			      push_arg(0.0);
			      strcpy(token, op->tag);
			      return token;
			}
		  }

		  else if (str == ptr)
		  {
			strcpy(token, op->tag);
			return token;
		  }

		  else break;
	    }

	    *tptr++ = *ptr++;
      }
      *tptr = '\0';

      return token;
}


/* Get an operator */
static struct operator * get_op(char *str)
{
      struct operator *op;

      for (op = verbs; op->token; ++op)
      {
	    if (SUCCESS == strncmp(str, op->tag, op->taglen))
		  return op;
      }
      return NULL;
}


/* Get precedence of a token */
static int getprec(char token)
{
      struct operator *op;
      for (op = verbs; op->token; ++op)
      {
	    if (token == op->token)
		  break;
      }
      if (op->token)
	    return op->precedence;
      else  return 0;
}


/* Get precedence of TOS token */
static int getTOSprec(void)
{
if (!op_sptr) return 0;
return getprec(op_stack[op_sptr - 1]);
}


int main(int argc, char *argv[])
//--------------------------------------------------------------------
// Retour:  0  Ok
//          1  Bad argument(s)
//          2  RunTime Error
//--------------------------------------------------------------------
{
int retval;
double val;

// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
    if ((argv[noarg][0])=='/' || (argv[noarg][0])=='-') {
    	switch (argv[noarg][1] | 0x20) {
			case '?':
			case 'h': help=-1;break;
			default: strcat(argument,argv[noarg]);
		}
    }
	else {
    	strcat(argument,argv[noarg]);
  	}
}

strupr(argument);
/* Affiche en-tete */
if (help) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage:  %s  <Expression>\n\n",PROG);
	printf("EVAL.EXE calculates and shows the result of a simple mathematic expression.\n");
	printf("EVAL is however limited to the following functions and symbols:\n");
	printf("                  (  )          brackets\n");
	printf("               +  -  *  /       addition,substraction,multiplication,division\n");
	printf("                   \\            modulo\n");
	printf("                   ^            power\n");
	printf("                 sqrt( )        root square\n");
	printf("             sin( )  cos( )     sinus, cosinus\n");
	printf("                 atan( )        arc tan.\n");
	printf("              ln( )  exp( )     neperian logarithm, exponent\n");
	printf("                 abs( )         absolute value\n");
	printf("                   pi           value of PI=3.14159265358979323846\n");
	printf("\n");
	printf("Example1: The command line  EVAL 1/3-0.3           returns 0.0333333\n");
	printf("Example2: The command line  EVAL 5+(5*cos(2*pi))   returns 10\n");
	printf("Note    : Error of rounding off is <= than the 5/1000000th of the result.\n");
	exit(0);
	}
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Error:  Bad command line\n");
	exit(1);
	}

/* Supprime les espaces de argument */
for (i=0;i<(int) strlen(argument);i++) {
  if (argument[i]==' ') {strcpy(argument+i,argument+i+1);}
  }
printf("Calculation of  %s  ",argument);
if ((retval=evaluate(argument,&val))==0)
  printf(" =  %g\n",val);
else printf(" - Failure.\n");
return(abs(retval));
}
