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
int yyended = 1;

int c, i, j, k;
long long ll;
char fstr[128];
%}

%token NUMBER EXIT END LINEEND LPAREN RPAREN COMMA
%token PLUS MINUS MULTIPLY DIVIDE EXPONENT MODULO EXPONENTIAL

%token PI E
%token SIN COS TAN ASIN ACOS ATAN ATAN2
%token SQRT CBRT
%token LOG2 LOG10 LOG LN

/* associativity */
%left PLUS MINUS
%left MODULO
%left MULTIPLY DIVIDE
%left EXPONENT
%left EXPONENTIAL
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
	fprintf(stdout, "  = %s\n", fstr);
	if (yyended)
		fputc('\n', stdout);
	/* kill the parser because we only want to parse one line at a time */
	YYACCEPT;
               }
    ;

equation: expr END { $$ = $1; yyended = 1; }
        | expr LINEEND { $$ = $1; yyended = 0; }
        | expr LINEEND END { $$ = $1; yyended = 1; }
        | expr { $$ = $1; yyended = 0; }
        | EXIT { yyrunning = 0; yyended = 0; YYACCEPT; }
        | END { yyrunning = 0; yyended = 1; YYACCEPT; }
        | LINEEND { yyrunning = 0; yyended = 1; YYACCEPT; }
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

unary_expr: exp_expr { $$ = $1; }
          | MINUS exp_expr { $$ = -$2; }
		  ;

exp_expr: func_expr { $$ = $1; }
        | func_expr EXPONENTIAL {
	i = ll = (int) $1;
	while (--i > 1)
		ll *= i;
	$$ = ll;
                                }
		;

func_expr: primary { $$ = $1; }
         | SIN primary { $$ = sin($2); }
		 | COS primary { $$ = cos($2); }
		 | TAN primary { $$ = tan($2); }
         | ASIN primary { $$ = asin($2); }
		 | ACOS primary { $$ = acos($2); }
		 | ATAN primary { $$ = atan($2); }
		 | SQRT primary { $$ = sqrt($2); }
		 | CBRT primary { $$ = cbrt($2); }
		 | LOG2 primary { $$ = log2($2); }
		 | LOG10 primary { $$ = log10($2); }
		 | LN primary { $$ = log($2); }
		 | func_expr_2 { $$ = $1; }
		 ;

func_expr_2: LOG primary COMMA primary { $$ = log($2) / log($4); }
           | LOG LPAREN primary COMMA primary RPAREN { $$ = log($3) / log($5); }
           | ATAN2 primary COMMA primary { $$ = atan2($2, $4); }
           | ATAN2 LPAREN primary COMMA primary RPAREN { $$ = atan2($3, $5); }
		   ;

primary: NUMBER { $$ = $1; }
       | PI { $$ = V_PI; }
	   | E { $$ = V_E; }
       | LPAREN expr RPAREN { $$ = $2; }
       ;

%%


