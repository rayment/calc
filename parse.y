%{
/*
 * parse.y
 *
 * Author       : Finn Rayment <finn@rayment.fr>
 * Date created : 21/07/2022
 */

#include <math.h>
#include <stdlib.h>
#include <stdio.h>

#include "incl.h"

#define EQ_INTEGER  1
#define EQ_POINT    2
#define EQ_FRACTION 3

#define V_PI 3.14159265358979323846
#define V_E  2.71828182845904523536

int yylex(void);
void yyerror(char *, ...);

int yyrunning = 1;

int c, i, j, k;
char fstr[128];
%}

%token NUMBER EXIT END LPAREN RPAREN
%token PLUS MINUS MULTIPLY DIVIDE EXPONENT MODULO

%token PI E
%token SIN COS TAN

/* associativity */
%left PLUS MINUS
%left MULTIPLY DIVIDE
%left EXPONENT
%%

unit: equation {
	/* a simple 3-state machine to find the last significant digit
	   and crop anything that remains -- */
	i = 0;
	j = EQ_INTEGER;
	k = -1;
	snprintf(fstr, 128, "%f", $1);
	while ((c = *(fstr+i)) && i < 128)
	{
		if (c == '.')
			j = EQ_POINT;
		else if (j == EQ_POINT && c >= '0' && c <= '9')
			j = EQ_FRACTION;
		else if (j == EQ_INTEGER)
			k = i;
		/* advance the significant digit */
		if (j == EQ_FRACTION && c > '0' && c <= '9')
			k = i;
		++i;
	}
	/* perform the crop */
	if (k >= 0)
		*(fstr+k+1) = '\0';
	/* now print the answer */
	fprintf(stdout, "= %s\n\n", fstr);
	/* kill the parser because we only want to parse one line at a time */
	YYACCEPT;
               }
    ;

equation:
    | EXIT { yyrunning = 0; YYACCEPT; }
    | END { yyrunning = 0; YYACCEPT; }
    | expr END { $$ = $1; }
	| expr { $$ = $1; }
    ;

expr: add_expr
    ;

add_expr: mul_expr { $$ = $1; }
        | add_expr PLUS mul_expr { $$ = $1 + $3; }
        | add_expr MINUS mul_expr { $$ = $1 - $3; }
        ;

mul_expr: pow_expr { $$ = $1; }
        | mul_expr MULTIPLY pow_expr { $$ = $1 * $3; }
        | mul_expr DIVIDE pow_expr { $$ = $1 / $3; }
		;

pow_expr: mod_expr { $$ = $1; }
        | pow_expr EXPONENT mod_expr { $$ = pow($1, $3); }
        ;

mod_expr: unary_expr { $$ = $1; }
        | mod_expr MODULO unary_expr { $$ = (int) $1 % (int) $3; }
        ;

unary_expr: func_expr { $$ = $1; }
          | MINUS func_expr { $$ = -$2; }
		  ;

func_expr: primary { $$ = $1; }
         | SIN primary { $$ = sin($2); }
		 | COS primary { $$ = cos($2); }
		 | TAN primary { $$ = tan($2); }

primary: NUMBER { $$ = $1; }
       | PI { $$ = V_PI; }
	   | E { $$ = V_E; }
       | LPAREN expr RPAREN { $$ = $2; }
       ;

%%


