//********************************************************************
// Converts dos batch files to unix csh files
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"Bat2csh"
#define VERSION	"3.0"

#include <string.h>


// Variables
int accent=0,hide=0,rea=0,sys=0,sub=0,toujours=0;
char argument[256];

#define FLEX_SCANNER
#define YY_FLEX_MAJOR_VERSION 2
#define YY_FLEX_MINOR_VERSION 5
#include <stdio.h>
/* cfront 1.2 defines "c_plusplus" instead of "__cplusplus" */
#ifdef c_plusplus
#ifndef __cplusplus
#define __cplusplus
#endif
#endif
#ifdef __cplusplus
#include <stdlib.h>
#include <unistd.h>
/* Use prototypes in function declarations. */
/* The "const" storage-class-modifier is valid. */
#define YY_USE_CONST
#else	/* ! __cplusplus */
#if __STDC__
#define YY_USE_CONST
#endif	/* __STDC__ */
#endif	/* ! __cplusplus */
#ifdef __TURBOC__
 #pragma warn -rch
 #pragma warn -use
 #include <io.h>
 #include <stdlib.h>
 #define YY_USE_CONST
#endif
#ifndef YY_USE_CONST
#ifndef const
#define const
#endif
#endif


/* Returned upon end-of-file. */
#define YY_NULL 0
/* Promotes a possibly negative, possibly signed char to an unsigned
 * integer for use as an array index.  If the signed char is negative,
 * we want to instead treat it as an 8-bit unsigned char, hence the
 * double cast.
 */
#define YY_SC_TO_UI(c) ((unsigned int) (unsigned char) c)
/* Enter a start condition.  This macro really ought to take a parameter,
 * but we do it the disgusting crufty way forced on us by the ()-less
 * definition of BEGIN.
 */
#define BEGIN yy_start = 1 + 2 *
/* Translate the current start state into a value that can be later handed
 * to BEGIN to return to the state.  The YYSTATE alias is for lex
 * compatibility.
 */
#define YY_START ((yy_start - 1) / 2)
#define YYSTATE YY_START
/* Action number for EOF rule of a given start state. */
#define YY_STATE_EOF(state) (YY_END_OF_BUFFER + state + 1)
/* Special action meaning "start processing a new file". */
#define YY_NEW_FILE yyrestart( yyin )
#define YY_END_OF_BUFFER_CHAR 0
/* Size of default input buffer. */
#define YY_BUF_SIZE 16384
typedef struct yy_buffer_state *YY_BUFFER_STATE;
extern int yyleng;
extern FILE *yyin, *yyout;
FILE *yyin = stdin, *yyout = stdout;
#define EOB_ACT_CONTINUE_SCAN 0
#define EOB_ACT_END_OF_FILE 1
#define EOB_ACT_LAST_MATCH 2
/* The funky do-while in the following #define is used to turn the definition
 * int a single C statement (which needs a semi-colon terminator).  This
 * avoids problems with code like:
 *
 * 	if ( condition_holds )
 *		yyless( 5 );
 *	else
 *		do_something_else();
 *
 * Prior to using the do-while the compiler would get upset at the
 * "else" because it interpreted the "if" statement as being all
 * done when it reached the ';' after the yyless() call.
 */

/* Return all but the first 'n' matched characters back to the input stream. */
#define yyless(n) \
	do \
		{ \
		/* Undo effects of setting up yytext. */ \
		*yy_cp = yy_hold_char; \
		yy_c_buf_p = yy_cp = yy_bp + n - YY_MORE_ADJ; \
		YY_DO_BEFORE_ACTION; /* set up yytext again */ \
		} \
	while ( 0 )
#define unput(c) yyunput( c, yytext_ptr )
/* The following is because we cannot portably get our hands on size_t
 * (without autoconf's help, which isn't available because we want
 * flex-generated scanners to compile on their own).
 */
typedef unsigned int yy_size_t;
struct yy_buffer_state
	{
	FILE *yy_input_file;

	char *yy_ch_buf;		/* input buffer */
	char *yy_buf_pos;		/* current position in input buffer */

	/* Size of input buffer in bytes, not including room for EOB
	 * characters.
	 */
	yy_size_t yy_buf_size;

	/* Number of characters read into yy_ch_buf, not including EOB
	 * characters.
	 */
	int yy_n_chars;

	/* Whether we "own" the buffer - i.e., we know we created it,
	 * and can realloc() it to grow it, and should free() it to
	 * delete it.
	 */
	int yy_is_our_buffer;
	/* Whether this is an "interactive" input source; if so, and
	 * if we're using stdio for input, then we want to use getc()
	 * instead of fread(), to make sure we stop fetching input after
	 * each newline.
	 */
	int yy_is_interactive;
	/* Whether we're considered to be at the beginning of a line.
	 * If so, '^' rules will be active on the next match, otherwise
	 * not.
	 */
	int yy_at_bol;
	/* Whether to try to fill the input buffer when we reach the
	 * end of it.
	 */
	int yy_fill_buffer;
	int yy_buffer_status;
#define YY_BUFFER_NEW 0
#define YY_BUFFER_NORMAL 1
	/* When an EOF's been seen but there's still some text to process
	 * then we mark the buffer as YY_EOF_PENDING, to indicate that we
	 * shouldn't try reading from the input source any more.  We might
	 * still have a bunch of tokens to match, though, because of
	 * possible backing-up.
	 *
	 * When we actually see the EOF, we change the status to "new"
	 * (via yyrestart()), so that the user can continue scanning by
	 * just pointing yyin at a new input file.
	 */
#define YY_BUFFER_EOF_PENDING 2
	};
static YY_BUFFER_STATE yy_current_buffer = 0;
/* We provide macros for accessing buffer states in case in the
 * future we want to put the buffer states in a more general
 * "scanner state".
 */
#define YY_CURRENT_BUFFER yy_current_buffer
/* yy_hold_char holds the character lost when yytext is formed. */
static char yy_hold_char;
static int yy_n_chars;		/* number of characters read into yy_ch_buf */
int yyleng;
/* Points to current character in buffer. */
static char *yy_c_buf_p = (char *) 0;
static int yy_init = 1;		/* whether we need to initialize */
static int yy_start = 0;	/* start state number */
/* Flag which is used to allow yywrap()'s to do buffer switches
 * instead of setting up a fresh yyin.  A bit of a hack ...
 */
static int yy_did_buffer_switch_on_eof;
void yyrestart ( FILE *input_file );
void yy_switch_to_buffer ( YY_BUFFER_STATE new_buffer );
void yy_load_buffer_state ( void );
YY_BUFFER_STATE yy_create_buffer ( FILE *file, int size );
void yy_delete_buffer ( YY_BUFFER_STATE b );
void yy_init_buffer ( YY_BUFFER_STATE b, FILE *file );
void yy_flush_buffer ( YY_BUFFER_STATE b );
#define YY_FLUSH_BUFFER yy_flush_buffer( yy_current_buffer )
YY_BUFFER_STATE yy_scan_buffer ( char *base, yy_size_t size );
YY_BUFFER_STATE yy_scan_string ( const char *str );
YY_BUFFER_STATE yy_scan_bytes ( const char *bytes, int len );
static void *yy_flex_alloc ( yy_size_t );
static void *yy_flex_realloc ( void *, yy_size_t );
static void yy_flex_free ( void * );
#define yy_new_buffer yy_create_buffer
#define yy_set_interactive(is_interactive) \
	{ \
	if ( ! yy_current_buffer ) \
		yy_current_buffer = yy_create_buffer( yyin, YY_BUF_SIZE ); \
	yy_current_buffer->yy_is_interactive = is_interactive; \
	}
#define yy_set_bol(at_bol) \
	{ \
	if ( ! yy_current_buffer ) \
		yy_current_buffer = yy_create_buffer( yyin, YY_BUF_SIZE ); \
	yy_current_buffer->yy_at_bol = at_bol; \
	}
#define YY_AT_BOL() (yy_current_buffer->yy_at_bol)
#define yywrap() 1
#define YY_SKIP_YYWRAP
typedef unsigned char YY_CHAR;
typedef int yy_state_type;
extern char *yytext;
#define yytext_ptr yytext
#ifndef YY_SKIP_YYWRAP
#ifdef __cplusplus
extern "C" int yywrap ( void );
#else
extern int yywrap ( void );
#endif
#endif
#ifndef YY_NO_UNPUT
static void yyunput ( int c, char *buf_ptr );
#endif
#ifndef yytext_ptr
static void yy_flex_strncpy ( char *, const char *, int );
#endif
#ifndef YY_NO_INPUT
#ifdef __cplusplus
static int yyinput ( void );
#else
static int input ( void );
#endif
#endif
static yy_state_type yy_get_previous_state ( void );
static yy_state_type yy_try_NUL_trans ( yy_state_type current_state );
static int yy_get_next_buffer ( void );
static void yy_fatal_error ( const char msg[] );
/* Done after the current pattern has been matched and before the
 * corresponding action - sets up yytext.
 */
#define YY_DO_BEFORE_ACTION \
	yytext_ptr = yy_bp; \
	yyleng = (int) (yy_cp - yy_bp); \
	yy_hold_char = *yy_cp; \
	*yy_cp = '\0'; \
	yy_c_buf_p = yy_cp;
#define YY_NUM_RULES 32
#define YY_END_OF_BUFFER 33
static const short int yy_accept[94] =
    {   0,
	0,    0,    0,    0,    0,    0,    0,    0,   33,   31,
       29,   28,   14,   14,   14,   14,   14,   14,   14,   14,
       14,   13,    1,   30,   17,   30,   21,   31,   30,   30,
       31,   31,   31,   31,   29,   14,   14,   14,   14,   14,
	6,   14,   14,   14,   14,   12,   30,   30,   15,   21,
	0,    0,   23,   30,   30,   30,    0,   26,   25,   14,
       14,    4,   14,   14,   14,    8,    9,   14,   16,   22,
       24,   30,   30,   18,   27,    2,    3,    5,   10,   14,
       14,   30,   30,    7,   11,   30,   20,   30,   30,   30,
       30,   19,    0

    } ;
static const int yy_ec[256] =
    {   0,
	1,    1,    1,    1,    1,    1,    1,    1,    2,    3,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    2,    4,    5,    4,    4,    6,    4,    5,    7,
	8,    5,    5,    5,    4,    9,    5,   10,   10,   10,
       10,   10,   10,   10,   10,   10,   10,   11,    2,    2,
	2,    2,    5,   12,   13,    4,   14,   15,   16,   17,
       18,   19,   20,    4,    4,   21,   22,   23,   24,   25,
	4,   26,   27,   28,   29,   30,    4,   31,    4,    4,
	5,    5,    5,    5,    5,    5,   13,    4,   14,   15,

       16,   17,   18,   19,   20,    4,    4,   21,   22,   23,
       24,   25,    4,   26,   27,   28,   29,   30,    4,   31,
	4,    4,    4,    5,    4,    4,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,

	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1
    } ;
static const int yy_meta[32] =
    {   0,
	1,    1,    1,    2,    3,    4,    2,    5,    3,    2,
	3,    3,    2,    2,    2,    2,    2,    2,    2,    2,
	2,    2,    2,    2,    2,    2,    2,    2,    2,    2,
	2
    } ;
static const short int yy_base[102] =
    {   0,
	0,   21,   33,   57,   81,  104,  126,  145,  112,  200,
      109,  200,    0,   96,   94,   79,   78,   84,   87,   83,
       21,    0,  200,    0,    0,   21,   96,   35,   17,   72,
       89,    0,   70,   70,   90,    0,   70,   71,   63,   60,
	0,   18,   64,   57,   60,    0,    0,   62,    0,   76,
       71,    0,   70,   49,   54,   45,   64,  200,  200,   50,
       46,    0,   45,   49,   40,    0,    0,   48,    0,  200,
	0,   40,   35,    0,  200,    0,    0,    0,    0,   45,
       28,   29,   26,    0,    0,   32,    0,   36,   21,   34,
       28,    0,  200,  165,  170,  174,  178,  182,  186,  191,

      194
    } ;
static const short int yy_def[102] =
    {   0,
       93,    1,   94,   94,   94,   94,   95,   95,   93,   93,
       93,   93,   96,   96,   96,   96,   96,   96,   96,   96,
       96,   97,   93,   98,   98,   98,   93,   99,   98,   98,
       93,  100,   93,   93,   93,   96,   96,   96,   96,   96,
       96,   96,   96,   96,   96,   97,   98,   98,   98,   93,
       99,  101,   99,   98,   98,   98,  100,   93,   93,   96,
       96,   96,   96,   96,   96,   96,   96,   96,   98,   93,
      101,   98,   98,   98,   93,   96,   96,   96,   96,   96,
       96,   98,   98,   96,   96,   98,   98,   98,   98,   98,
       98,   98,    0,   93,   93,   93,   93,   93,   93,   93,

       93
    } ;
static const short int yy_nxt[232] =
    {   0,
       10,   11,   12,   13,   10,   10,   13,   13,   10,   13,
       10,   10,   13,   14,   13,   15,   16,   17,   13,   18,
       13,   13,   13,   13,   19,   20,   21,   13,   13,   13,
       13,   22,   23,   10,   11,   12,   44,   48,   10,   45,
       52,   25,   54,   49,   53,   64,   65,   55,   92,   91,
       90,   89,   88,   87,   86,   85,   26,   10,   11,   12,
       84,   83,   10,   82,   81,   25,   80,   79,   78,   77,
       76,   75,   74,   73,   72,   70,   70,   50,   69,   68,
       26,   10,   27,   12,   67,   66,   28,   63,   62,   61,
       60,   35,   59,   58,   52,   56,   29,   50,   43,   42,

       41,   40,   39,   30,   10,   27,   12,   38,   37,   28,
       35,   93,   93,   93,   93,   93,   93,   93,   93,   29,
       93,   93,   93,   93,   93,   93,   30,   11,   12,   93,
       93,   31,   32,   93,   93,   93,   93,   93,   93,   93,
       33,   93,   93,   93,   93,   34,   11,   12,   93,   93,
       31,   32,   93,   93,   93,   93,   93,   93,   93,   33,
       93,   93,   93,   93,   34,   24,   24,   24,   24,   24,
       10,   10,   10,   10,   10,   36,   93,   93,   36,   46,
       93,   93,   46,   47,   47,   93,   47,   51,   93,   51,
       51,   57,   57,   57,   57,   71,   93,   93,   71,    9,

       93,   93,   93,   93,   93,   93,   93,   93,   93,   93,
       93,   93,   93,   93,   93,   93,   93,   93,   93,   93,
       93,   93,   93,   93,   93,   93,   93,   93,   93,   93,
       93
    } ;
static const short int yy_chk[232] =
    {   0,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	1,    2,    2,    3,    3,    3,   21,   26,    3,   21,
       28,    3,   29,   26,   28,   42,   42,   29,   91,   90,
       89,   88,   86,   83,   82,   81,    3,    4,    4,    4,
       80,   73,    4,   72,   68,    4,   65,   64,   63,   61,
       60,   57,   56,   55,   54,   53,   51,   50,   48,   45,
	4,    5,    5,    5,   44,   43,    5,   40,   39,   38,
       37,   35,   34,   33,   31,   30,    5,   27,   20,   19,

       18,   17,   16,    5,    6,    6,    6,   15,   14,    6,
       11,    9,    0,    0,    0,    0,    0,    0,    0,    6,
	0,    0,    0,    0,    0,    0,    6,    7,    7,    0,
	0,    7,    7,    0,    0,    0,    0,    0,    0,    0,
	7,    0,    0,    0,    0,    7,    8,    8,    0,    0,
	8,    8,    0,    0,    0,    0,    0,    0,    0,    8,
	0,    0,    0,    0,    8,   94,   94,   94,   94,   94,
       95,   95,   95,   95,   95,   96,    0,    0,   96,   97,
	0,    0,   97,   98,   98,    0,   98,   99,    0,   99,
       99,  100,  100,  100,  100,  101,    0,    0,  101,   93,

       93,   93,   93,   93,   93,   93,   93,   93,   93,   93,
       93,   93,   93,   93,   93,   93,   93,   93,   93,   93,
       93,   93,   93,   93,   93,   93,   93,   93,   93,   93,
       93
    } ;
static yy_state_type yy_last_accepting_state;
static char *yy_last_accepting_cpos;
/* The intent behind this definition is that it'll catch
 * any uses of REJECT which flex missed.
 */
#define REJECT reject_used_but_not_detected
#define yymore() yymore_used_but_not_detected
#define YY_MORE_ADJ 0
char *yytext;
#define INITIAL 0

#include <assert.h>
#include <ctype.h>
#include <direct.h>
#include <dos.h>
#include <errno.h>
#include <float.h>
#include <fcntl.h>
#include <io.h>
#include <limits.h>
#include <malloc.h>
#include <math.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#ifdef __BORLANDC__
#pragma hdrstop
#endif
#define putstr(s)	fputs((s),  stdout)
#define puttab()	fputc('\t', stdout)
#define putln()		fputc('\n', stdout)
#define token(t)	(t)
#define ckeol(t)	do { if((t)==EOL) { puts(" ### SYNTAX ERROR ###"); \
			  errorcount++; return;} } while(0)
#define cktok(t, x)	do { if((t)!=(x)) { puts(" ### SYNTAX ERROR ###"); \
			  errorcount++; eattokens(); return;} } while(0)
typedef struct
{
	int token;
	void (*fn)(void);
} FNTBL;
#define STRBUFSIZE	257
char textbuf[STRBUFSIZE];
/**************************************************************************/
/* token enumeration                                                      */
/**************************************************************************/
enum {
	OTHER=1,
	EOL,
	SPACE,
	VARIABLE,
	PARAMETER,
	WORD,
	INIT_CALL,
	INIT_ECHO,
	INIT_FOR,
	INIT_GOTO,
	INIT_IF,
	INIT_PATH,
	INIT_PAUSE,
	INIT_REM,
	INIT_SET,
	INIT_SHIFT,
	INIT_LABEL,
	INIT_COMMAND,
	ECHO_ON,
	ECHO_OFF,
	ECHO_DOT,
	IF_NOT,
	IF_ERRORLEVEL,
	IF_EXIST,
	FOR_VARIABLE,
	FOR_IN,
	FOR_WORDLIST,
	FOR_DO
};


/**************************************************************************/
/* function prototypes                                                    */
/**************************************************************************/
/* support functions */
char *cvt_parameter(char *s);
char *cvt_variable(char *s);
char *cvt_for_variable(char *s);
char *cvt_set_variable(int token);
char *cvt_token(int token, char *s);
int dispatch(void);
void indent(void);
int lex(void);
void putbacktoken(void);
void puttokln(int token, char *start, char *end);
int  reporterrors(void);
void terminate(void);
char *tr(char *s, int oldch, int newch);
/* keyword functions */
void kw_call(void);
void kw_command(void);
void kw_echo(void);
void kw_for(void);
void kw_goto(void);
void kw_if(void);
void kw_label(void);
void kw_ln(void);
void kw_path(void);
void kw_pause(void);
void kw_remark(void);
void kw_set(void);
void kw_shift(void);
#define ECHOS 1
#define TEXT 2
#define FOR 3
/* Macros after this point can all be overridden by user definitions in
 * section 1.
 */
#if YY_STACK_USED
static int yy_start_stack_ptr = 0;
static int yy_start_stack_depth = 0;
static int *yy_start_stack = 0;
#ifndef YY_NO_PUSH_STATE
static void yy_push_state ( int new_state );
#endif
#ifndef YY_NO_POP_STATE
static void yy_pop_state ( void );
#endif
#ifndef YY_NO_TOP_STATE
static int yy_top_state ( void );
#endif
#else
#define YY_NO_PUSH_STATE 1
#define YY_NO_POP_STATE 1
#define YY_NO_TOP_STATE 1
#endif
#ifdef YY_MALLOC_DECL
YY_MALLOC_DECL
#else
#if __STDC__
#ifndef __cplusplus
#include <stdlib.h>
#endif
#else
/* Just try to get by without declaring the routines.  This will fail
 * miserably on non-ANSI systems for which sizeof(size_t) != sizeof(int)
 * or sizeof(void*) != sizeof(int).
 */
#endif
#endif

/* Amount of stuff to slurp up with each read. */
#ifndef YY_READ_BUF_SIZE
#define YY_READ_BUF_SIZE 8192
#endif
/* Copy whatever the last rule matched to the standard output. */
#ifndef ECHO
/* This used to be an fputs(), but since the string might contain NUL's,
 * we now use fwrite().
 */
#define ECHO (void) fwrite( yytext, yyleng, 1, yyout )
#endif
/* Gets input and stuffs it into "buf".  number of characters read, or YY_NULL,
 * is returned in "result".
 */
#ifndef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( yy_current_buffer->yy_is_interactive ) \
		{ \
		int c = '*', n; \
		for ( n = 0; n < max_size && \
			     (c = getc( yyin )) != EOF && c != '\n'; ++n ) \
			buf[n] = (char) c; \
		if ( c == '\n' ) \
			buf[n++] = (char) c; \
		if ( c == EOF && ferror( yyin ) ) \
			YY_FATAL_ERROR( "input in flex scanner failed" ); \
		result = n; \
		} \
	else if ( ((result = fread( buf, 1, max_size, yyin )) == 0) \
		  && ferror( yyin ) ) \
		YY_FATAL_ERROR( "input in flex scanner failed" );
#endif

/* No semi-colon after return; correct usage is to write "yyterminate();" -
 * we don't want an extra ';' after the "return" because that will cause
 * some compilers to complain about unreachable statements.
 */
#ifndef yyterminate
#define yyterminate() return YY_NULL
#endif
/* Number of entries by which start-condition stack grows. */
#ifndef YY_START_STACK_INCR
#define YY_START_STACK_INCR 25
#endif
/* Report a fatal error. */
#ifndef YY_FATAL_ERROR
#define YY_FATAL_ERROR(msg) yy_fatal_error( msg )
#endif
/* Code executed at the beginning of each rule, after yytext and yyleng
 * have been set up.
 */
#ifndef YY_USER_ACTION
#define YY_USER_ACTION
#endif
/* Code executed at the end of each rule. */
#ifndef YY_BREAK
#define YY_BREAK break;
#endif
#define YY_RULE_SETUP \
	if ( yyleng > 0 ) \
		yy_current_buffer->yy_at_bol = \
				(yytext[yyleng - 1] == '\n'); \
	YY_USER_ACTION
int yylex ( void ) {
register yy_state_type yy_current_state;
register char *yy_cp, *yy_bp;
register int yy_act;
if ( yy_init )	{
  yy_init = 0;
#ifdef YY_USER_INIT
  YY_USER_INIT;
#endif
  if ( ! yy_start ) yy_start = 1;	/* first start state */
  if ( ! yyin ) yyin = stdin;
  if ( ! yyout ) yyout = stdout;
  if ( ! yy_current_buffer )
			yy_current_buffer =
				yy_create_buffer( yyin, YY_BUF_SIZE );
		yy_load_buffer_state();
		}
	while ( 1 )		/* loops until end-of-file is reached */
		{
		yy_cp = yy_c_buf_p;
		/* Support of yytext. */
		*yy_cp = yy_hold_char;
		/* yy_bp points to the position in yy_ch_buf of the start of
		 * the current run.
		 */
		yy_bp = yy_cp;
		yy_current_state = yy_start;
		yy_current_state += YY_AT_BOL();
yy_match:
		do
			{
			register YY_CHAR yy_c = yy_ec[YY_SC_TO_UI(*yy_cp)];
			if ( yy_accept[yy_current_state] )
				{
				yy_last_accepting_state = yy_current_state;
				yy_last_accepting_cpos = yy_cp;
				}
			while ( yy_chk[yy_base[yy_current_state] + yy_c] != yy_current_state )
				{
				yy_current_state = (int) yy_def[yy_current_state];
				if ( yy_current_state >= 94 )
					yy_c = yy_meta[(unsigned int) yy_c];
				}
			yy_current_state = yy_nxt[yy_base[yy_current_state] + (unsigned int) yy_c];
			++yy_cp;
			}
		while ( yy_base[yy_current_state] != 200 );

yy_find_action:
		yy_act = yy_accept[yy_current_state];
		if ( yy_act == 0 )
			{ /* have to back up */
			yy_cp = yy_last_accepting_cpos;
			yy_current_state = yy_last_accepting_state;
			yy_act = yy_accept[yy_current_state];
			}

		YY_DO_BEFORE_ACTION;


do_action:	/* This label is used only to access EOF actions. */


		switch ( yy_act )
	{ /* beginning of action switch */
			case 0: /* must back up */
			/* undo the effects of YY_DO_BEFORE_ACTION */
			*yy_cp = yy_hold_char;
			yy_cp = yy_last_accepting_cpos;
			yy_current_state = yy_last_accepting_state;
			goto yy_find_action;

case 1:
YY_RULE_SETUP
;
	YY_BREAK
case 2:
YY_RULE_SETUP
return token(INIT_CALL);
	YY_BREAK
case 3:
YY_RULE_SETUP
return token(INIT_ECHO);
	YY_BREAK
case 4:
YY_RULE_SETUP
return token(INIT_FOR);
	YY_BREAK
case 5:
YY_RULE_SETUP
return token(INIT_GOTO);
	YY_BREAK
case 6:
YY_RULE_SETUP
return token(INIT_IF);
	YY_BREAK
case 7:
YY_RULE_SETUP
return token(INIT_PAUSE);
	YY_BREAK
case 8:
YY_RULE_SETUP
return token(INIT_REM);
	YY_BREAK
case 9:
YY_RULE_SETUP
return token(INIT_SET);
	YY_BREAK
case 10:
YY_RULE_SETUP
return token(INIT_PATH);
	YY_BREAK
case 11:
YY_RULE_SETUP
return token(INIT_SHIFT);
	YY_BREAK
case 12:
YY_RULE_SETUP
return token(INIT_LABEL);
	YY_BREAK
case 13:
YY_RULE_SETUP
return token(INIT_REM);
	YY_BREAK
case 14:
YY_RULE_SETUP
return token(INIT_COMMAND);
	YY_BREAK
case 15:
YY_RULE_SETUP
return token(ECHO_ON);
	YY_BREAK
case 16:
YY_RULE_SETUP
return token(ECHO_OFF);
	YY_BREAK
case 17:
YY_RULE_SETUP
return token(ECHO_DOT);
	YY_BREAK
case 18:
YY_RULE_SETUP
return token(IF_NOT);
	YY_BREAK
case 19:
YY_RULE_SETUP
return token(IF_ERRORLEVEL);
	YY_BREAK
case 20:
YY_RULE_SETUP
return token(IF_EXIST);
	YY_BREAK
case 21:
YY_RULE_SETUP
return token(SPACE);
	YY_BREAK
case 22:
YY_RULE_SETUP
return token(VARIABLE);
	YY_BREAK
case 23:
YY_RULE_SETUP
return token(PARAMETER);
	YY_BREAK
case 24:
YY_RULE_SETUP
return token(FOR_VARIABLE);
	YY_BREAK
case 25:
YY_RULE_SETUP
return token(FOR_IN);
	YY_BREAK
case 26:
YY_RULE_SETUP
return token(FOR_DO);
	YY_BREAK
case 27:
YY_RULE_SETUP
return token(FOR_WORDLIST);
	YY_BREAK
case 28:
YY_RULE_SETUP
return token(EOL);
	YY_BREAK
case 29:
YY_RULE_SETUP
;
	YY_BREAK
case 30:
YY_RULE_SETUP
return token(WORD);
	YY_BREAK
case 31:
YY_RULE_SETUP
return token(OTHER);
	YY_BREAK
case 32:
YY_RULE_SETUP
ECHO;
	YY_BREAK
case YY_STATE_EOF(INITIAL):
case YY_STATE_EOF(ECHOS):
case YY_STATE_EOF(TEXT):
case YY_STATE_EOF(FOR):
	yyterminate();

	case YY_END_OF_BUFFER:
		{
		/* Amount of text matched not including the EOB char. */
		int yy_amount_of_matched_text = (int) (yy_cp - yytext_ptr) - 1;

		/* Undo the effects of YY_DO_BEFORE_ACTION. */
		*yy_cp = yy_hold_char;

		if ( yy_current_buffer->yy_buffer_status == YY_BUFFER_NEW )
			{
			/* We're scanning a new file or input source.  It's
			 * possible that this happened because the user
			 * just pointed yyin at a new source and called
			 * yylex().  If so, then we have to assure
			 * consistency between yy_current_buffer and our
			 * globals.  Here is the right place to do so, because
			 * this is the first action (other than possibly a
			 * back-up) that will match for the new input source.
			 */
			yy_n_chars = yy_current_buffer->yy_n_chars;
			yy_current_buffer->yy_input_file = yyin;
			yy_current_buffer->yy_buffer_status = YY_BUFFER_NORMAL;
			}

		/* Note that here we test for yy_c_buf_p "<=" to the position
		 * of the first EOB in the buffer, since yy_c_buf_p will
		 * already have been incremented past the NUL character
		 * (since all states make transitions on EOB to the
		 * end-of-buffer state).  Contrast this with the test
		 * in input().
		 */
		if ( yy_c_buf_p <= &yy_current_buffer->yy_ch_buf[yy_n_chars] )
			{ /* This was really a NUL. */
			yy_state_type yy_next_state;

			yy_c_buf_p = yytext_ptr + yy_amount_of_matched_text;

			yy_current_state = yy_get_previous_state();

			/* Okay, we're now positioned to make the NUL
			 * transition.  We couldn't have
			 * yy_get_previous_state() go ahead and do it
			 * for us because it doesn't know how to deal
			 * with the possibility of jamming (and we don't
			 * want to build jamming into it because then it
			 * will run more slowly).
			 */

			yy_next_state = yy_try_NUL_trans( yy_current_state );

			yy_bp = yytext_ptr + YY_MORE_ADJ;

			if ( yy_next_state )
				{
				/* Consume the NUL. */
				yy_cp = ++yy_c_buf_p;
				yy_current_state = yy_next_state;
				goto yy_match;
				}

			else
				{
				yy_cp = yy_c_buf_p;
				goto yy_find_action;
				}
			}

		else switch ( yy_get_next_buffer() )
			{
			case EOB_ACT_END_OF_FILE:
				{
				yy_did_buffer_switch_on_eof = 0;

				if ( yywrap() )
					{
					/* Note: because we've taken care in
					 * yy_get_next_buffer() to have set up
					 * yytext, we can now set up
					 * yy_c_buf_p so that if some total
					 * hoser (like flex itself) wants to
					 * call the scanner after we return the
					 * YY_NULL, it'll still work - another
					 * YY_NULL will get returned.
					 */
					yy_c_buf_p = yytext_ptr + YY_MORE_ADJ;

					yy_act = YY_STATE_EOF(YY_START);
					goto do_action;
					}

				else
					{
					if ( ! yy_did_buffer_switch_on_eof )
						YY_NEW_FILE;
					}
				break;
				}

			case EOB_ACT_CONTINUE_SCAN:
				yy_c_buf_p =
					yytext_ptr + yy_amount_of_matched_text;

				yy_current_state = yy_get_previous_state();

				yy_cp = yy_c_buf_p;
				yy_bp = yytext_ptr + YY_MORE_ADJ;
				goto yy_match;

			case EOB_ACT_LAST_MATCH:
				yy_c_buf_p =
				&yy_current_buffer->yy_ch_buf[yy_n_chars];

				yy_current_state = yy_get_previous_state();

				yy_cp = yy_c_buf_p;
				yy_bp = yytext_ptr + YY_MORE_ADJ;
				goto yy_find_action;
			}
		break;
		}

	default:
		YY_FATAL_ERROR(
			"fatal flex scanner internal error--no action found" );
	} /* end of action switch */
		} /* end of scanning one token */
	} /* end of yylex */


/* yy_get_next_buffer - try to read in a new buffer
 *
 * Returns a code representing an action:
 *	EOB_ACT_LAST_MATCH -
 *	EOB_ACT_CONTINUE_SCAN - continue scanning from current position
 *	EOB_ACT_END_OF_FILE - end of file
 */

static int yy_get_next_buffer()
	{
	register char *dest = yy_current_buffer->yy_ch_buf;
	register char *source = yytext_ptr;
	register int number_to_move, i;
	int ret_val;

	if ( yy_c_buf_p > &yy_current_buffer->yy_ch_buf[yy_n_chars + 1] )
		YY_FATAL_ERROR(
		"fatal flex scanner internal error--end of buffer missed" );

	if ( yy_current_buffer->yy_fill_buffer == 0 )
		{ /* Don't try to fill the buffer, so this is an EOF. */
		if ( yy_c_buf_p - yytext_ptr - YY_MORE_ADJ == 1 )
			{
			/* We matched a singled characater, the EOB, so
			 * treat this as a final EOF.
			 */
			return EOB_ACT_END_OF_FILE;
			}

		else
			{
			/* We matched some text prior to the EOB, first
			 * process it.
			 */
			return EOB_ACT_LAST_MATCH;
			}
		}

	/* Try to read more data. */

	/* First move last chars to start of buffer. */
	number_to_move = (int) (yy_c_buf_p - yytext_ptr) - 1;

	for ( i = 0; i < number_to_move; ++i )
		*(dest++) = *(source++);

	if ( yy_current_buffer->yy_buffer_status == YY_BUFFER_EOF_PENDING )
		/* don't do the read, it's not guaranteed to return an EOF,
		 * just force an EOF
		 */
		yy_n_chars = 0;

	else
		{
		int num_to_read =
			yy_current_buffer->yy_buf_size - number_to_move - 1;

		while ( num_to_read <= 0 )
			{ /* Not enough room in the buffer - grow it. */
#ifdef YY_USES_REJECT
			YY_FATAL_ERROR(
"input buffer overflow, can't enlarge buffer because scanner uses REJECT" );
#else

			/* just a shorter name for the current buffer */
			YY_BUFFER_STATE b = yy_current_buffer;

			int yy_c_buf_p_offset =
				(int) (yy_c_buf_p - b->yy_ch_buf);

			if ( b->yy_is_our_buffer )
				{
				int new_size = b->yy_buf_size * 2;

				if ( new_size <= 0 )
					b->yy_buf_size += b->yy_buf_size / 8;
				else
					b->yy_buf_size *= 2;

				b->yy_ch_buf = (char *)
					/* Include room in for 2 EOB chars. */
					yy_flex_realloc( (void *) b->yy_ch_buf,
							 b->yy_buf_size + 2 );
				}
			else
				/* Can't grow it, we don't own it. */
				b->yy_ch_buf = 0;

			if ( ! b->yy_ch_buf )
				YY_FATAL_ERROR(
				"fatal error - scanner input buffer overflow" );

			yy_c_buf_p = &b->yy_ch_buf[yy_c_buf_p_offset];

			num_to_read = yy_current_buffer->yy_buf_size -
						number_to_move - 1;
#endif
			}

		if ( num_to_read > YY_READ_BUF_SIZE )
			num_to_read = YY_READ_BUF_SIZE;

		/* Read in more data. */
		YY_INPUT( (&yy_current_buffer->yy_ch_buf[number_to_move]),
			yy_n_chars, num_to_read );
		}

	if ( yy_n_chars == 0 )
		{
		if ( number_to_move == YY_MORE_ADJ )
			{
			ret_val = EOB_ACT_END_OF_FILE;
			yyrestart( yyin );
			}

		else
			{
			ret_val = EOB_ACT_LAST_MATCH;
			yy_current_buffer->yy_buffer_status =
				YY_BUFFER_EOF_PENDING;
			}
		}

	else
		ret_val = EOB_ACT_CONTINUE_SCAN;

	yy_n_chars += number_to_move;
	yy_current_buffer->yy_ch_buf[yy_n_chars] = YY_END_OF_BUFFER_CHAR;
	yy_current_buffer->yy_ch_buf[yy_n_chars + 1] = YY_END_OF_BUFFER_CHAR;

	yytext_ptr = &yy_current_buffer->yy_ch_buf[0];

	return ret_val;
	}


/* yy_get_previous_state - get the state just before the EOB char was reached */

static yy_state_type yy_get_previous_state()
	{
	register yy_state_type yy_current_state;
	register char *yy_cp;

	yy_current_state = yy_start;
	yy_current_state += YY_AT_BOL();

	for ( yy_cp = yytext_ptr + YY_MORE_ADJ; yy_cp < yy_c_buf_p; ++yy_cp )
		{
		register YY_CHAR yy_c = (*yy_cp ? yy_ec[YY_SC_TO_UI(*yy_cp)] : 1);
		if ( yy_accept[yy_current_state] )
			{
			yy_last_accepting_state = yy_current_state;
			yy_last_accepting_cpos = yy_cp;
			}
		while ( yy_chk[yy_base[yy_current_state] + yy_c] != yy_current_state )
			{
			yy_current_state = (int) yy_def[yy_current_state];
			if ( yy_current_state >= 94 )
				yy_c = yy_meta[(unsigned int) yy_c];
			}
		yy_current_state = yy_nxt[yy_base[yy_current_state] + (unsigned int) yy_c];
		}

	return yy_current_state;
	}


/* yy_try_NUL_trans - try to make a transition on the NUL character
 *
 * synopsis
 *	next_state = yy_try_NUL_trans( current_state );
 */

static yy_state_type yy_try_NUL_trans( yy_state_type yy_current_state )
	{
	register int yy_is_jam;
	register char *yy_cp = yy_c_buf_p;

	register YY_CHAR yy_c = 1;
	if ( yy_accept[yy_current_state] )
		{
		yy_last_accepting_state = yy_current_state;
		yy_last_accepting_cpos = yy_cp;
		}
	while ( yy_chk[yy_base[yy_current_state] + yy_c] != yy_current_state )
		{
		yy_current_state = (int) yy_def[yy_current_state];
		if ( yy_current_state >= 94 )
			yy_c = yy_meta[(unsigned int) yy_c];
		}
	yy_current_state = yy_nxt[yy_base[yy_current_state] + (unsigned int) yy_c];
	yy_is_jam = (yy_current_state == 93);

	return yy_is_jam ? 0 : yy_current_state;
	}


static void yyunput( int c, register char *yy_bp )
	{
	register char *yy_cp = yy_c_buf_p;

	/* undo effects of setting up yytext */
	*yy_cp = yy_hold_char;

	if ( yy_cp < yy_current_buffer->yy_ch_buf + 2 )
		{ /* need to shift things up to make room */
		/* +2 for EOB chars. */
		register int number_to_move = yy_n_chars + 2;
		register char *dest = &yy_current_buffer->yy_ch_buf[
					yy_current_buffer->yy_buf_size + 2];
		register char *source =
				&yy_current_buffer->yy_ch_buf[number_to_move];

		while ( source > yy_current_buffer->yy_ch_buf )
			*--dest = *--source;

		yy_cp += (int) (dest - source);
		yy_bp += (int) (dest - source);
		yy_n_chars = yy_current_buffer->yy_buf_size;

		if ( yy_cp < yy_current_buffer->yy_ch_buf + 2 )
			YY_FATAL_ERROR( "flex scanner push-back overflow" );
		}

	*--yy_cp = (char) c;


	yytext_ptr = yy_bp;
	yy_hold_char = *yy_cp;
	yy_c_buf_p = yy_cp;
	}


#ifdef __cplusplus
static int yyinput()
#else
static int input()
#endif
	{
	int c;

	*yy_c_buf_p = yy_hold_char;

	if ( *yy_c_buf_p == YY_END_OF_BUFFER_CHAR )
		{
		/* yy_c_buf_p now points to the character we want to return.
		 * If this occurs *before* the EOB characters, then it's a
		 * valid NUL; if not, then we've hit the end of the buffer.
		 */
		if ( yy_c_buf_p < &yy_current_buffer->yy_ch_buf[yy_n_chars] )
			/* This was really a NUL. */
			*yy_c_buf_p = '\0';

		else
			{ /* need more input */
			yytext_ptr = yy_c_buf_p;
			++yy_c_buf_p;

			switch ( yy_get_next_buffer() )
				{
				case EOB_ACT_END_OF_FILE:
					{
					if ( yywrap() )
						{
						yy_c_buf_p =
						yytext_ptr + YY_MORE_ADJ;
						return EOF;
						}

					if ( ! yy_did_buffer_switch_on_eof )
						YY_NEW_FILE;
#ifdef __cplusplus
					return yyinput();
#else
					return input();
#endif
					}

				case EOB_ACT_CONTINUE_SCAN:
					yy_c_buf_p = yytext_ptr + YY_MORE_ADJ;
					break;

				case EOB_ACT_LAST_MATCH:
#ifdef __cplusplus
					YY_FATAL_ERROR(
					"unexpected last match in yyinput()" );
#else
					YY_FATAL_ERROR(
					"unexpected last match in input()" );
#endif
				}
			}
		}

	c = *(unsigned char *) yy_c_buf_p;	/* cast for 8-bit char's */
	*yy_c_buf_p = '\0';	/* preserve yytext */
	yy_hold_char = *++yy_c_buf_p;

	yy_current_buffer->yy_at_bol = (c == '\n');

	return c;
	}


void yyrestart( FILE *input_file )
	{
	if ( ! yy_current_buffer )
		yy_current_buffer = yy_create_buffer( yyin, YY_BUF_SIZE );

	yy_init_buffer( yy_current_buffer, input_file );
	yy_load_buffer_state();
	}


void yy_switch_to_buffer( YY_BUFFER_STATE new_buffer )
	{
	if ( yy_current_buffer == new_buffer )
		return;

	if ( yy_current_buffer )
		{
		/* Flush out information for old buffer. */
		*yy_c_buf_p = yy_hold_char;
		yy_current_buffer->yy_buf_pos = yy_c_buf_p;
		yy_current_buffer->yy_n_chars = yy_n_chars;
		}

	yy_current_buffer = new_buffer;
	yy_load_buffer_state();

	/* We don't actually know whether we did this switch during
	 * EOF (yywrap()) processing, but the only time this flag
	 * is looked at is after yywrap() is called, so it's safe
	 * to go ahead and always set it.
	 */
	yy_did_buffer_switch_on_eof = 1;
	}


void yy_load_buffer_state( void )
	{
	yy_n_chars = yy_current_buffer->yy_n_chars;
	yytext_ptr = yy_c_buf_p = yy_current_buffer->yy_buf_pos;
	yyin = yy_current_buffer->yy_input_file;
	yy_hold_char = *yy_c_buf_p;
	}


YY_BUFFER_STATE yy_create_buffer( FILE *file, int size ) {
YY_BUFFER_STATE b;
b = (YY_BUFFER_STATE) yy_flex_alloc( sizeof( struct yy_buffer_state ) );
if ( ! b ) YY_FATAL_ERROR( "Not enough memory." );
b->yy_buf_size = size;
/* yy_ch_buf has to be 2 characters longer than the size given because
 * we need to put in 2 end-of-buffer characters.
 */
b->yy_ch_buf = (char *) yy_flex_alloc( b->yy_buf_size + 2 );
if ( ! b->yy_ch_buf ) YY_FATAL_ERROR( "Not enough memory." );
b->yy_is_our_buffer = 1;
yy_init_buffer( b, file );
return b;
}


void yy_delete_buffer( YY_BUFFER_STATE b )
	{
	if ( b == yy_current_buffer )
		yy_current_buffer = (YY_BUFFER_STATE) 0;

	if ( b->yy_is_our_buffer )
		yy_flex_free( (void *) b->yy_ch_buf );

	yy_flex_free( (void *) b );
	}


#ifndef YY_ALWAYS_INTERACTIVE
#ifndef YY_NEVER_INTERACTIVE
extern int isatty ( int );
#endif
#endif

void yy_init_buffer( YY_BUFFER_STATE b, FILE *file )
{
yy_flush_buffer( b );
b->yy_input_file = file;
b->yy_fill_buffer = 1;
#if YY_ALWAYS_INTERACTIVE
	b->yy_is_interactive = 1;
#else
#if YY_NEVER_INTERACTIVE
	b->yy_is_interactive = 0;
#else
	b->yy_is_interactive = file ? (isatty( fileno(file) ) > 0) : 0;
#endif
#endif
	}


void yy_flush_buffer( YY_BUFFER_STATE b )
{
b->yy_n_chars = 0;
/* We always need two end-of-buffer characters.  The first causes
 * a transition to the end-of-buffer state.  The second causes
 * a jam in that state. */
b->yy_ch_buf[0] = YY_END_OF_BUFFER_CHAR;
b->yy_ch_buf[1] = YY_END_OF_BUFFER_CHAR;
	b->yy_buf_pos = &b->yy_ch_buf[0];
	b->yy_at_bol = 1;
	b->yy_buffer_status = YY_BUFFER_NEW;
	if ( b == yy_current_buffer )
		yy_load_buffer_state();
	}


#ifndef YY_NO_SCAN_BUFFER
YY_BUFFER_STATE yy_scan_buffer( char *base, yy_size_t size )
	{
	YY_BUFFER_STATE b;

	if ( size < 2 ||
	     base[size-2] != YY_END_OF_BUFFER_CHAR ||
	     base[size-1] != YY_END_OF_BUFFER_CHAR )
		/* They forgot to leave room for the EOB's. */
		return 0;

	b = (YY_BUFFER_STATE) yy_flex_alloc( sizeof( struct yy_buffer_state ) );
	if ( ! b )
		YY_FATAL_ERROR( "out of dynamic memory in yy_scan_buffer()" );

	b->yy_buf_size = size - 2;	/* "- 2" to take care of EOB's */
	b->yy_buf_pos = b->yy_ch_buf = base;
	b->yy_is_our_buffer = 0;
	b->yy_input_file = 0;
	b->yy_n_chars = b->yy_buf_size;
	b->yy_is_interactive = 0;
	b->yy_at_bol = 1;
	b->yy_fill_buffer = 0;
	b->yy_buffer_status = YY_BUFFER_NEW;

	yy_switch_to_buffer( b );

	return b;
	}
#endif


#ifndef YY_NO_SCAN_STRING
YY_BUFFER_STATE yy_scan_string( const char *str )
	{
	int len;
	for ( len = 0; str[len]; ++len )
		;

	return yy_scan_bytes( str, len );
	}
#endif


#ifndef YY_NO_SCAN_BYTES
YY_BUFFER_STATE yy_scan_bytes( const char *bytes, int len )
	{
	YY_BUFFER_STATE b;
	char *buf;
	yy_size_t n;
	int i;
	/* Get memory for full buffer, including space for trailing EOB's. */
	n = len + 2;
	buf = (char *) yy_flex_alloc( n );
	if ( ! buf )
		YY_FATAL_ERROR( "out of dynamic memory in yy_scan_bytes()" );

	for ( i = 0; i < len; ++i )
		buf[i] = bytes[i];
	buf[len] = buf[len+1] = YY_END_OF_BUFFER_CHAR;
	b = yy_scan_buffer( buf, n );
	if ( ! b )
		YY_FATAL_ERROR( "bad buffer in yy_scan_bytes()" );
	/* It's okay to grow etc. this buffer, and we should throw it
	 * away when we're done.
	 */
	b->yy_is_our_buffer = 1;
	return b;
	}
#endif


#ifndef YY_NO_PUSH_STATE
static void yy_push_state( int new_state )
	{
	if ( yy_start_stack_ptr >= yy_start_stack_depth )
		{
		yy_size_t new_size;

		yy_start_stack_depth += YY_START_STACK_INCR;
		new_size = yy_start_stack_depth * sizeof( int );

		if ( ! yy_start_stack )
			yy_start_stack = (int *) yy_flex_alloc( new_size );

		else
			yy_start_stack = (int *) yy_flex_realloc(
					(void *) yy_start_stack, new_size );

		if ( ! yy_start_stack )
			YY_FATAL_ERROR(
			"out of memory expanding start-condition stack" );
		}

	yy_start_stack[yy_start_stack_ptr++] = YY_START;

	BEGIN(new_state);
	}
#endif


#ifndef YY_NO_POP_STATE
static void yy_pop_state()
	{
	if ( --yy_start_stack_ptr < 0 )
		YY_FATAL_ERROR( "start-condition stack underflow" );

	BEGIN(yy_start_stack[yy_start_stack_ptr]);
	}
#endif


#ifndef YY_NO_TOP_STATE
static int yy_top_state()
	{
	return yy_start_stack[yy_start_stack_ptr - 1];
	}
#endif

#ifndef YY_EXIT_FAILURE
#define YY_EXIT_FAILURE 2
#endif

static void yy_fatal_error( const char msg[] ) {
(void) fprintf( stderr, "%s\n", msg );
exit( YY_EXIT_FAILURE );
}



/* Redefine yyless() so it works in section 3 code. */

#undef yyless
#define yyless(n) \
	do \
		{ \
		/* Undo effects of setting up yytext. */ \
		yytext[yyleng] = yy_hold_char; \
		yy_c_buf_p = yytext + n - YY_MORE_ADJ; \
		yy_hold_char = *yy_c_buf_p; \
		*yy_c_buf_p = '\0'; \
		yyleng = n; \
		} \
	while ( 0 )


/* Internal utility routines. */

#ifndef yytext_ptr
static void yy_flex_strncpy( char *s1, const char *s2, int n )
{
register int i;
for ( i = 0; i < n; ++i )
		s1[i] = s2[i];
}
#endif


static void *yy_flex_alloc( yy_size_t size )
{
return (void *) malloc( size );
}

static void *yy_flex_realloc( void *ptr, yy_size_t size )
{
return (void *) realloc( ptr, size );
}

static void yy_flex_free( void *ptr )
{
free( ptr );
}



#if YY_MAIN
int main()
	{
	yylex();
	return 0;
	}
#endif


#ifdef __BORLANDC__
#pragma option -w
#pragma warn -use-
#pragma warn -ccc-
#endif

/**************************************************************************/
/* global variables                                                       */
/**************************************************************************/
int cmdtoken;         /* first token in each batch line */
int errorcount=0;     /* syntax error counter */
int errorlevelflag=0; /* control use of "set errorlevel=$status" */
int indentlevel=0;    /* indent level of output */

/**************************************************************************/
/* support functions                                                      */
/**************************************************************************/
/* report any errors */
int reporterrors()
{
    char s[7];

    if (errorcount) {
        itoa(errorcount, s, 10);
        fputs("\n\nNUMBER OF ERRORS = ", stderr);
        fputs(s, stderr);
        fputs("\n\n", stderr);
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}

/* abnormal termination */
void terminate(void)
{
    putln();
    puts(" ### PREMATURE END-OF-FILE ###");
    errorcount++;
    exit(reporterrors());
}

/* wrapper for yylex */
int lex(void)
{
int result;         /* return result */
static int count=0; /* count number of times yylex returns 0 */
result = yylex();
if (!result) {
	if (count==1) {
	    terminate();
	} else {    /* handle possible premature eof */
	    count++;
	    result = EOL;
	}
    }
return result;
}

/* indent output based on global indentlevel */
void indent(void)
{
    int i;

    for (i=0; i<indentlevel; i++) puttab();
}

/* put token back to input stream */
void putbacktoken(void)
{
      yyless(0);
}

/* translate character in string s */
char *tr(char *s, int oldch, int newch)
{
    char *sp = s;

    do {
        if (*sp == oldch) *sp = newch;
    } while (*sp++);
    return s;
}

/* convert replaceable parameter, e.g. %1 -> $1 */
char *cvt_parameter(char *s)
{
    strcpy(textbuf, s);
    *textbuf='$';
    return textbuf;
}

/* convert variable, e.g. %PATH% -> ${path} */
char *cvt_variable(char *s)
{
    char *sp;

    strcpy(textbuf, "${");
    sp = s;
    sp++;
    strncat(textbuf, sp, yyleng-2);
    strcat(textbuf, "}");
    return strlwr(textbuf);
}

/* convert variable used with 'for' keyword, e.g. %%F -> ${f} */
char *cvt_for_variable(char *s)
{
    char *sp;

    strcpy(textbuf, "${");
    sp = s;
    sp += 2;
    strncat(textbuf, sp, yyleng-2);
    strcat(textbuf, "}");
    return strlwr(textbuf);
}

/* convert variable used with set keyword, e.g. ${f} -> f */ 
char *cvt_set_variable(int token)
{
    int len;

    switch(token) {
    case VARIABLE:
    case FOR_VARIABLE:
        len = strlen(textbuf)-2;
        memmove(textbuf, textbuf+2, len);
        textbuf[len-1]='\0';
        break;
    default:
	break;
    }
    return textbuf;
}

/* convert from batch format to csh format */
char *cvt_token(int token, char *s)
{
    char *sp, *tp=textbuf;

    switch(token) {
    case PARAMETER:
	if (s) cvt_parameter(s);
        else   cvt_parameter(yytext);
        break;
    case VARIABLE:
        if (s) cvt_variable(s);
        else   cvt_variable(yytext);
        break;
    case FOR_VARIABLE:
        if (s) cvt_for_variable(s);
        else   cvt_for_variable(yytext);
        break;
    case SPACE:
        if (s) strcpy(textbuf, s);
	else   strcpy(textbuf, yytext);

        /* translate delimiter if set or path */
        if (cmdtoken==INIT_SET || cmdtoken==INIT_PATH) {
            tr(textbuf, ';', ' ');
        }
        break;
    default:
	if (s) strcpy(textbuf, s);
	else   strcpy(textbuf, yytext);

        tr(textbuf, '/', '-');      /* translate options specifier */
        tr(textbuf, '\\', '/');     /* translate directory separator */
        
        /* if path contains a drive specifier, remove it */
        sp = strchr(textbuf, ':');
        if (sp && sp != tp) {
            if (isalpha(*(sp-1)) && *(sp+1) == '/') {
				memmove(sp-1, sp+1, strlen(sp));
            }
        }

        /* convert to lower case if not remark or echo, or contains path */
        if (!(cmdtoken==INIT_REM || cmdtoken==INIT_ECHO) || strchr(tp, '/')) {
            strlwr(tp);
        }
        break;
    }
    return tp;
}

/* print text associated with remaining tokens on line */
void puttokln(int token, char *start, char *end)
{
   char *tp;

   BEGIN(TEXT);
   ckeol(token);
   if (start) {
        tp = cvt_token(token, start);
        /* translate names of common commands */
        if (!strcmp(tp, "attrib")) strcpy(tp, "chmod");
	else if (!strcmp(tp, "chdir")) strcpy(tp, "cd");
	else if (!strcmp(tp, "cls")) strcpy(tp, "clear");
        else if (!strcmp(tp, "command")) strcpy(tp, "csh");
        else if (!strcmp(tp, "copy")) strcpy(tp, "cp");
        else if (!strcmp(tp, "del")) strcpy(tp, "rm");
        else if (!strcmp(tp, "dir")) strcpy(tp, "ls");
        else if (!strcmp(tp, "erase")) strcpy(tp, "rm");
        else if (!strcmp(tp, "md")) strcpy(tp, "mkdir");
        else if (!strcmp(tp, "move")) strcpy(tp, "mv");
        else if (!strcmp(tp, "print")) strcpy(tp, "pr");
	else if (!strcmp(tp, "rd")) strcpy(tp, "rmdir");
        else if (!strcmp(tp, "ren")) strcpy(tp, "mv");
        else if (!strcmp(tp, "rename")) strcpy(tp, "mv");
	else if (!strcmp(tp, "time")) strcpy(tp, "date");
        else if (!strcmp(tp, "type")) strcpy(tp, "cat");
        else if (!strcmp(tp, "xcopy /s")) strcpy(tp, "cp -r");
        else if (!strcmp(tp, "xcopy")) strcpy(tp, "cp");
        putstr(tp);
   }
   while ((token=lex())!=EOL) {
       putstr(cvt_token(token, NULL));
   }
   if (end) {
       putstr(end);
   }
   putln();
}

/* eat remainder of line */
void eattokens(void)
{
   BEGIN(TEXT);
   while (lex()!=EOL) ;
}

/**************************************************************************/
/* batch keyword functions                                                */
/**************************************************************************/
void kw_call(void)
{
    errorlevelflag=0;
    indent();
    puttokln(INIT_CALL, "csh ", NULL);
}

void kw_command(void)
{
    int token;

    errorlevelflag=0;
    putbacktoken();
    BEGIN(TEXT);
    token = lex();
    indent();
    puttokln(token, yytext, NULL);
}

void kw_echo(void)
{
    int token;

    BEGIN(ECHOS);
    token = lex();
    switch(token) {
    case ECHO_ON:
        eattokens();
        break;
    case ECHO_OFF:
	eattokens();
	break;
    case ECHO_DOT:
        indent();
        puts("echo ''");
        eattokens();
        break;
    case EOL:
        break;
    default:
	indent();
        putstr("echo ");
        putbacktoken();
	puttokln(INIT_ECHO, NULL, NULL);
        break;
    }
}

void kw_for(void)
{
    int token;
    
    BEGIN(FOR);
    indent();
    putstr("foreach ");

    /* get variable */
    token = lex();
    ckeol(token);
    cktok(token, FOR_VARIABLE);
    if (yyleng>2) putstr(yytext+2);

    /* check for "in" keyword */
    token = lex();
    ckeol(token);
    cktok(token, FOR_IN);
    putstr(" ");

    /* get wordlist */
    token = lex();
    ckeol(token);
    cktok(token, FOR_WORDLIST);
    putstr(yytext);

    /* check for "do" keyword */
    token = lex();
    ckeol(token);
    cktok(token, FOR_DO);
    putln();

    /* process command */
    indentlevel++;
    if (dispatch()==EOF) terminate();
    indentlevel--;

    /* end foreach */
    indent();
    puts("end");
}

void kw_goto(void)
{
    indent();
    puttokln(INIT_GOTO, yytext, NULL);
}

void kw_if(void)
{
    int token;
    int not = 0;
    char *sp, strbuf[STRBUFSIZE];

    BEGIN(TEXT);
    for (;;) {
        while ((token=lex())==SPACE) ;
        ckeol(token);
        switch (token) {
        case IF_NOT:
	    not = !not;
            continue;
        case IF_ERRORLEVEL:
	    if (errorlevelflag==0) {
                errorlevelflag=1;
                indent();
                puts("set errorlevel=$status");
            }
            while ((token=lex())==SPACE) ;
            ckeol(token);
            indent();
            if (not) {
                putstr("if (${errorlevel} < ");
            } else {
                putstr("if (${errorlevel} >= ");
            }
	    do {
                putstr(cvt_token(token, NULL));
            } while (!((token=lex())==SPACE||token==EOL));
            break;
        case IF_EXIST:
            while ((token=lex())==SPACE) ;
            indent();
            if (not) {
		putstr("if (! ");
	    } else {
                putstr("if (");
            }
            ckeol(token);

            /* get file or directory name */
            strcpy(strbuf, "");
            do {
                strcat(strbuf, cvt_token(token, NULL));
	    } while (!((token=lex())==SPACE||token==EOL));
            sp = strstr(strbuf, "/nul");
            if (sp && sp==strbuf+strlen(strbuf)-4) { /* directory */
		putstr("-d \"");
                *sp = '\0';
            } else {       /* file */
                putstr("-f \"");
            }

            /* print file or directory name */
            putstr(strbuf);
            putstr("\"");
            break;
        default:    /* must be string comparison */
            indent();
            putstr("if (");
	    do {
                putstr(cvt_token(token, NULL));
            } while (!((token=lex())==SPACE||token==EOL));
            if (not) {
                putstr(" != ");
            } else {
                putstr(" == ");
            }
	    ckeol(token);
	    while ((token=lex())==SPACE) ;
            ckeol(token);
            do {
                putstr(cvt_token(token, NULL));
            } while (!((token=lex())==SPACE||token==EOL));
            break;
        }
    break;
    }
    putstr(")");
    ckeol(token);
    puts(" then");

    /* process command */
    indentlevel++;
    if (dispatch()==EOF) terminate();
    indentlevel--;

    /* end if */
    indent();
    puts("endif");
}

void kw_label(void)
{
    strcpy(textbuf, yytext+1);
    strcat(textbuf, ":");
    puts(strlwr(textbuf));
    eattokens();
}

void kw_ln(void)
{
    putln();
}

void kw_path(void)
{
    int token;

    BEGIN(TEXT);
    while ((token=lex())==SPACE) ;
    indent();
    if (token==EOL) {
        putstr("unset path");
        putln();
    } else {
        putstr("set path=(");
        puttokln(token, yytext, ")");
    }
    indent();
    puts("rehash");
}

void kw_pause(void)
{
    indent();
    puts("echo -n 'Press the Enter key to continue...'");
    indent();
    puts("echo -n $?");
    eattokens();
}

void kw_remark(void)
{
    puttokln(INIT_REM, "#", NULL);
}

void kw_set(void)
{
    int token;

    BEGIN(TEXT);
    while ((token=lex())==SPACE) ;
    if (token==EOL) { 
       indent();
       puts("set"); 
       return;
    }
    cvt_token(token, NULL);
    cvt_set_variable(token);
    if (!stricmp(textbuf, "path")) {
        kw_path();
        return;
    }

    /* variable name in textbuf, variable contents in yytext */
    while ((token=lex())==SPACE) ;
    indent();
    if (token==EOL) {
        putstr("unset ");
        putstr(textbuf);
        putln();
    } else {
        putstr("set ");
        putstr(textbuf);
        putstr("=\"");
        puttokln(token, yytext, "\"");
    }
}

void kw_shift(void)
{
    indent();
    puttokln(INIT_SHIFT, "shift ", NULL);
}

/**************************************************************************/
/* keyword function table                                                 */
/**************************************************************************/
FNTBL fntbl[] =
{
        {token(INIT_CALL),	kw_call},
        {token(INIT_COMMAND),	kw_command},
	{token(INIT_ECHO),	kw_echo},
        {token(INIT_FOR),	kw_for},
        {token(INIT_GOTO),	kw_goto},
        {token(INIT_IF),	kw_if},
        {token(INIT_LABEL),	kw_label},
        {token(EOL),		kw_ln},
        {token(INIT_PATH),	kw_path},
        {token(INIT_PAUSE),	kw_pause},
        {token(INIT_REM),	kw_remark},
        {token(INIT_SET),	kw_set},
        {token(INIT_SHIFT),	kw_shift}
};
#define N_FNTBL sizeof(fntbl)/sizeof(fntbl[0])


/**************************************************************************/
/* function dispatcher                                                    */
/**************************************************************************/
int dispatch(void) /* returns 0=success; EOF=end of file */
{
int i, token;
BEGIN(INITIAL);
token = yylex();
if (token) {
	for (i = 0; i < N_FNTBL; i++) {
	    if (token == fntbl[i].token) {
		cmdtoken = token;
		fntbl[i].fn();
		return 0;
	    }
	}

	/* no match, call kw_command() */
	cmdtoken = INIT_COMMAND;
	kw_command();
	return 0;
    }
    return EOF;
}


int main(int argc,char *argv[]) {
//*******************************************************************
// RETURN:  0  Ok
//          1  Bad arguments
//*******************************************************************
// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
  if ((argv[noarg][0])=='/' || (argv[noarg][0])=='-') {
    switch (argv[noarg][1] | 0x20) {
      case 'a':accent=-1;break;
      case '?':
	  case 'h': help=-1;break;
      default: invalide=-1;
      }
    }
  else strcpy(argument,argv[noarg]);
  }

/* Affiche en-tˆte */
if (help) {	
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage:  %s  <source_file>	destination_file\n\n",PROG);
	printf("Bat2csh reads Dos shell command lines from stdin, translates them for the \n");
	printf("C-shell and sends them to the stdout.\n");
	exit(0);
	}
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Error:  Bad command line\n");
	exit(1);
	}

while (dispatch()!=EOF) ;
return reporterrors();
}
