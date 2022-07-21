/*
 * main.c
 *
 * Author       : Finn Rayment <finn@rayment.fr>
 * Date created : 21/07/2022
 */

#include <stdlib.h>
#include <stdio.h>

#include "y.tab.h"

extern int yyrunning;

int
main(int argc,
     char **argv)
{
	(void) argc;
	(void) argv;

	while (yyrunning)
	{
		fprintf(stdout, "> ");
		yyparse();
	}

	return EXIT_SUCCESS;
}

