/*
 * This file is licensed under BSD 3-Clause.
 * All license information is available in the included COPYING file.
 */

/*
 * main.c
 *
 * Author       : Finn Rayment <finn@rayment.fr>
 * Date created : 21/07/2022
 */

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "y.tab.h"

extern int yyended;
extern int yyrunning;
extern char *argv_parse_redirect(int, char **);
extern void argv_parse_cleanup(void);

void
help(void)
{
	fprintf(stdout, "Usage: calc [OPTION]... [EQUATION]\n");
	fprintf(stdout, "Lightweight command-line calculator.\n\n");
	fprintf(stdout, "    -h               show this help message and exit\n");
	fprintf(stdout, "    -v               print the proram version and exit\n");
	fprintf(stdout, "\n");
	fprintf(stdout, "If no equation is given, then the program will be opened\n"
	                "in interactive mode.\n");
	fprintf(stdout, "\n");
	fprintf(stdout, "Copyright (c) 2022, Finn Rayment\n");
	fprintf(stdout, "This software is licensed under BSD 3-clause.\n");
}

void
version(void)
{
	fprintf(stdout, "calc-%s\n", VERSION);
}

int
main(int argc,
     char **argv)
{
	int c, redirect;
	char *argv_buf;

	while ((c = getopt(argc, argv, "hv")) != -1)
	{
		switch (c)
		{
		case 'h':
			help();
			return EXIT_SUCCESS;
		case 'v':
			version();
			return EXIT_SUCCESS;
		case '?':
			if (isprint(optopt))
				fprintf(stderr, "Unknown option '-%c'.\n", optopt);
			else
				fprintf(stderr, "Unknown option character '\\x%x'.\n", optopt);
			return EXIT_FAILURE;
		default:
			abort();
		}
	}

	redirect = optind < argc;

	if (redirect)
	{
		argv_buf = argv_parse_redirect(argc, argv);
		fprintf(stdout, "> %s\n", argv_buf);
	}

	while (yyrunning)
	{
		if (!redirect && yyended)
			fprintf(stdout, "> ");
		yyparse();
	}

	if (redirect)
		argv_parse_cleanup();

	return EXIT_SUCCESS;
}

