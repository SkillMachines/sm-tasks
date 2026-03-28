#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUF_SIZE 1024

int main()
{
    FILE *f;
    FILE *f2;
    char buf[BUF_SIZE];

    f = fopen("./config.yaml", "r");
    if (f)
    {
        printf("Reading config.yaml...\n");
        fread(buf, 1, BUF_SIZE, f);
        fclose(f);
    }
    else
    {
        perror("config.yaml");
    }

    f2 = fopen("/etc/config.yaml", "r");
    if (f2)
    {
        printf("Reading config.yaml...\n");
        fread(buf, 1, BUF_SIZE, f2);
        if (strstr(buf, "port: 8080") == NULL)
        {
            printf("Port 8080 not found in config.yaml\n");
            exit(3);
        }
        fclose(f2);
    }
    else
    {
        perror("config.yaml");
    }

    printf("Config content:\n%s\n", buf);

    return 0;
}