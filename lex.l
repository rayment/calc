%{
/*
 * lex.l
 *
 * Author       : Finn Rayment <finn@rayment.fr>
 * Date created : 21/07/2022
 */

#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>

#include "incl.h"
#include "y.tab.h"

extern void yyerror(char *, ...);
extern int yyrunning;

char errmsg[256];
%}
%option noyywrap
%option yylineno
%%
	/* whitespace and control characters */
<<EOF>>				{ yyrunning = 0; return END; }
[eE][xX][iI][tT]	{ yyrunning = 0; return EXIT; }
[qQ][uU][iI][tT]	{ yyrunning = 0; return EXIT; }
[ \t\r\f]			{ /* ignore whitespace */ }
"\n"				{ return END; }
";"					{ return LINEEND; }
"("					{ return LPAREN; }
")"					{ return RPAREN; }
","					{ return COMMA; }

	/* symbols */
"+"					{ return PLUS; }
"-"					{ return MINUS; }
"*"					{ return MULTIPLY; }
"/"					{ return DIVIDE; }
"^"					{ return EXPONENT; }
"%"					{ return MODULO; }
"!"					{ return EXPONENTIAL; }

	/* numbers */
[0-9]+				{ yylval = atof(yytext); return NUMBER; }
[0-9]*\.[0-9]+		{ yylval = atof(yytext); return NUMBER; }
[0-9]+\.[0-9]*		{ yylval = atof(yytext); return NUMBER; }

	/* words */
[pP][iI]			{ return PI; }
[eE]				{ return E; }
[sS][iI][nN]		{ return SIN; }
[cC][oO][sS]		{ return COS; }
[tT][aA][nN]		{ return TAN; }
[aA][sS][iI][nN]	{ return ASIN; }
[aA][cC][oO][sS]	{ return ACOS; }
[aA][tT][aA][nN]	{ return ATAN; }
[aA][tT][aA][nN]2	{ return ATAN2; }
[sS][qQ][rR][tT]	{ return SQRT; }
[cC][bB][rR][tT]	{ return CBRT; }
[lL][oO][gG]2		{ return LOG2; }
[lL][oO][gG]10		{ return LOG10; }
[lL][oO][gG]		{ return LOG; }
[lL][nN]			{ return LN; }

	/* other */
.					{ yyerror("unrecognized symbol \"%s\"", yytext); }
%%

void
yyerror(char *fmt,
        ...)
{
	va_list va;
	va_start(va, fmt);
	fprintf(stderr, "Error at line %d: ", yylineno);
	vfprintf(stderr, fmt, va);
	fputc('\n', stderr);
	va_end(va);
	exit(EXIT_FAILURE);
}

