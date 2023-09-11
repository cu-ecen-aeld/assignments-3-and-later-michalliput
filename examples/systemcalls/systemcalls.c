#include "systemcalls.h"
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <errno.h>

/**
 * @param cmd the command to execute with system()
 * @return true if the command in @param cmd was executed
 *   successfully using the system() call, false if an error occurred,
 *   either in invocation of the system() call, or if a non-zero return
 *   value was returned by the command issued in @param cmd.
*/
bool do_system(const char *cmd)
{

/*
 * TODO  add your code here
 *  Call the system() function with the command set in the cmd
 *   and return a boolean true if the system() call completed with success
 *   or false() if it returned a failure
*/
    int cmd_retval = -1;
    bool retval = false;

    /* Execute a system command and get result */
    cmd_retval = system(cmd);

    /* Analyze result */
    printf("\n\ncmd_retval: %d\n\n", cmd_retval);
    if (0 == cmd_retval)
    {
        retval = true;
    }
    
    return retval;
}

/**
* @param count -The numbers of variables passed to the function. The variables are command to execute.
*   followed by arguments to pass to the command
*   Since exec() does not perform path expansion, the command to execute needs
*   to be an absolute path.
* @param ... - A list of 1 or more arguments after the @param count argument.
*   The first is always the full path to the command to execute with execv()
*   The remaining arguments are a list of arguments to pass to the command in execv()
* @return true if the command @param ... with arguments @param arguments were executed successfully
*   using the execv() call, false if an error occurred, either in invocation of the
*   fork, waitpid, or execv() command, or if a non-zero return value was returned
*   by the command issued in @param arguments with the specified arguments.
*/

bool do_exec(int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;
    // this line is to avoid a compile warning before your implementation is complete
    // and may be removed
    command[count] = command[count];

/*
 * TODO:
 *   Execute a system command by calling fork, execv(),
 *   and wait instead of system (see LSP page 161).
 *   Use the command[0] as the full path to the command to execute
 *   (first argument to execv), and use the remaining arguments
 *   as second argument to the execv() command.
 *
*/
    bool retval = false;
    int retval_child = -1;
    int fork_status = 0;
    int exec_status = -2;
    int cmd_status = -1;
    int wait_status = 0;

    printf("\n\n------------\ndo_exec()\n");
    printf("\ncount: %d \ncommands:\n",count);
    for (i = 0; i < count; i++)
    {
        printf("%s\n",command[i]);
    }

    /* Create a child process */
    fork_status = fork();
    printf("\n-->fork_status: %d   errno: %d", fork_status, errno);
    
    if (fork_status >= 0)
    {
        if (0 == fork_status)
        {
            /* Child process */
            printf("\n\nChild:\n");
            retval_child = 1U;

            printf("\nexecution of child process...\n");

            /* Execute command */
            exec_status = execv(command[0], &command[0]);
            /* Error */
            printf("\n!!! execv() error !!!: %d   errno: %d\n\n", exec_status, errno);            
            exit(retval_child);
        }
        else
        {
            /* Parent process */
            printf("\n\nParent:\n");
            printf("\n-->child PID: %d", fork_status);
            
            /* Wait for children */
            wait_status = waitpid(fork_status, &cmd_status, 0);
            printf("\n-->wait_status: %d   errno: %d", wait_status, errno);
            printf("\n-->cmd_status: %d   errno: %d", cmd_status, errno);
            if ((wait_status > 0) && (0 == cmd_status))
            {
                retval = true;
            }
            else
            {
                retval = false;
            }
            printf("\n-->parent retval: %d\n\n", retval);
        }
    }
    else
    {
        printf("\n\n!!! fork() error! !!!\n\n");
    }

    va_end(args);

    return retval;
}

/**
* @param outputfile - The full path to the file to write with command output.
*   This file will be closed at completion of the function call.
* All other parameters, see do_exec above
*/
bool do_exec_redirect(const char *outputfile, int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;
    // this line is to avoid a compile warning before your implementation is complete
    // and may be removed
    command[count] = command[count];


/*
 * TODO
 *   Call execv, but first using https://stackoverflow.com/a/13784315/1446624 as a refernce,
 *   redirect standard out to a file specified by outputfile.
 *   The rest of the behaviour is same as do_exec()
 *
*/
    bool retval = false;
    int retval_child = -1;
    int fork_status = 0;
    int exec_status = -2;
    int cmd_status = -1;
    int wait_status = 0;
    int fd = -1;

    printf("\n\n------------\ndo_exec_redirect()\n");

    /* Open/create file for output redirection */
    fd = open(outputfile, O_WRONLY|O_TRUNC|O_CREAT, 0644);

    /* Create a child process */
    fork_status = fork();
    printf("\n-->fork_status: %d   errno: %d", fork_status, errno);

    if (fork_status >= 0)
    {
        if (0 == fork_status)
        {
            /* Child process */
            printf("\n\nChild:\n");
            retval_child = 1U;

            /* Redirect */
            printf("redirection");
            fflush(stdout);
            dup2(fd, 1);
            /* Close file before command execution */
            close(fd);
            
            
            //printf("\nexecution of child process...\n");

            /* Execute command */
            exec_status = execv(command[0], &command[0]);
            
            /* Error */
            printf("\n!!! execv() error !!!: %d   errno: %d\n\n", exec_status, errno);            
            exit(retval_child);
        }
        else
        {
            /* Parent process */
            printf("\n\nParent:\n");
            printf("\n-->child PID: %d", fork_status);
            
            /* Wait for children */
            wait_status = waitpid(fork_status, &cmd_status, 0);
            printf("\n-->wait_status: %d   errno: %d", wait_status, errno);
            printf("\n-->cmd_status: %d   errno: %d", cmd_status, errno);
            if ((wait_status > 0) && (0 == cmd_status))
            {
                retval = true;
            }
            else
            {
                retval = false;
            }
            printf("\n-->parent retval: %d\n\n", retval);
        }
    }
    else
    {
        printf("\n\n!!! fork() error! !!!\n\n");
    }


    va_end(args);

    return retval;
}
