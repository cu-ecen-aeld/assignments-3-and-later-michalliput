#include <stdio.h>
#include <stdint.h>
#include <syslog.h>

enum
{
	ARG_IDX_MY_NAME,
	ARG_IDX_FILE_PATH,
	ARG_IDX_FILE_CONTENT,
	N_OF_PARAMS
};

int main(int argc, char *argv[])
{
	uint8_t ret_val = 1U;
	char *writefile = "";
	char *writestr = "";
	FILE *writefile_ptr;

	openlog("writer", LOG_PERROR, LOG_USER);

	//printf("----ASSIGNMENT 2----\n-------WRITER-------\n--------------------\n\n");
	if (argc < N_OF_PARAMS)
	{
		/* Incorrect call - 2 arguments required */
		//printf("Writer failed: 2 parameters are required \n");
		syslog((LOG_USER | LOG_PERROR), "Writer failed: 2 parameters are required");
	}
	else
	{
		/* Sufficient number of arguments were passed */
		syslog((LOG_USER | LOG_DEBUG), "Writing %s to %s", writestr, writefile);

		writefile = argv[ARG_IDX_FILE_PATH];
		writestr = argv[ARG_IDX_FILE_CONTENT];

		/* Visualize arguments */
		//printf("You've passed path: %s\n", writefile);
		//printf("You've passed content: %s\n", writestr);

		//printf("Writing file... ");
		/* Create file */
		writefile_ptr = fopen(writefile, "w");
		
		if (0 == writefile_ptr)
		{
			syslog((LOG_USER | LOG_PERROR), "Unable to create file %s", writefile);
		}
		else
		{
			/* Write file content */
			fprintf(writefile_ptr, "%s", writestr);

			/* Close file */
			fclose(writefile_ptr);
			//printf("Done.");
			
			//printf("\n");
			ret_val = 0;
		}
	}

	closelog();

	return ret_val;
}
