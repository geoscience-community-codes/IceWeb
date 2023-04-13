#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "engine.h"
#include "stock.h"

void main(int argc, char **argv)
{
/* Usage:
	start_matlab_engine m-file [PATH] [arg]
   e.g.
	start_matlab_engine iceweb /home/iceweb/REAL_TIME_CODE
   starts a matlab engine, changes to the /home/iceweb/REAL_TIME_CODE
   directory, then runs the function 'iceweb' with no arguments
   Glenn Thompson, October 1999					 */


	/* declare variables */
	Engine 	*ep;
	char	cmd[30];

	/* display off */
	putenv( "DISPLAY=" );

	switch(argc) {

		case 2:
		/* start Matlab engine */
		ep=engOpen("/usr/local/bin/matlab");
		/* send commands */
		sprintf(cmd,"%s",argv[1]);
		printf("%s\n",cmd);
		engEvalString(ep,cmd);
		/* close Matlab engine */
		engClose(ep);
		break;



		case 3:
		printf("chdir %s\n",argv[2]);
		chdir(argv[2]);
		/* start Matlab engine */
		ep=engOpen("/usr/local/bin/matlab");
		/* send commands */
		sprintf(cmd,"%s",argv[1]);
		printf("%s\n",cmd);
		engEvalString(ep,cmd);	
		/* close Matlab engine */
		engClose(ep);
		break;

		case 4:
		/* change directory, then run function with argument */
		printf("chdir %s\n",argv[2]);
		chdir(argv[2]);
		/* start Matlab engine */
		ep=engOpen("/usr/local/bin/matlab");
		/* send commands */
		sprintf(cmd,"%s( %s )",argv[1],argv[3]);
		printf("%s\n",cmd);
		engEvalString(ep,cmd);	
		/* close Matlab engine */
		engClose(ep);
		break;

		default:
		printf("no of arguments received = %d\n",argc);
		printf("Usage: %s m-file-name [path] [argument]\n",argv[0]);
		break;			

	}

}

	/*	sprintf(cmd,"cd %s",argv[2]);
		printf("%s\n",cmd);
		engEvalString(ep,cmd);*/	
