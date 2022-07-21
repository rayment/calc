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
"("					{ return LPAREN; }
")"					{ return RPAREN; }

	/* symbols */
"+"					{ return PLUS; }
"-"					{ return MINUS; }
"*"					{ return MULTIPLY; }
"/"					{ return DIVIDE; }
"^"					{ return EXPONENT; }
"%"					{ return MODULO; }

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

