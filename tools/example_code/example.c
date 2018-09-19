#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ERROR 0
#define SUCCESS 1
void Log(char *msg);

int bad1(char *fileName){
    char buffer[100] = "";
    FILE *pFile;

    // 1. missing paramter validation, resulting null_ptr_def
    pFile = fopen(fileName, "r");
    if (pFile == NULL){
        Log("Error open file");
        // 2. incorrect error propagation
        return SUCCESS;
    }

    // 3. incorrect error code status checking
    if (fgets(buffer, 100, pFile) < 0){
        Log("Error read file");
        // 4. incorrect causal calling, resulting memory_leak
       return ERROR;
    }
    // do something
    fclose(pFile);
    return SUCCESS;
}

int bad2() {
    char buffer[100] = "";
    // 5. incorrect error code status checking
    if (fgets(buffer, 100, stdin) < 0){
        Log("Error read file");
        return ERROR;
    }
    // do something
    return SUCCESS;
}

int good1(char* fileName){
    char buffer[100] = "";
    FILE *pFile;

    // checking parameter
    if (fileName == NULL){
        Log("Error file");
        return ERROR;
    }
    pFile = fopen(fileName, "r");

    if (pFile == NULL){
        Log("Error open file");
        return ERROR;
    }

    if (fgets(buffer, 100, pFile) == NULL){
        Log("Error read file");
        fclose(pFile);
        return ERROR;
    }
    // do something
    fclose(pFile);
    return SUCCESS;
}

int good2(){
    char buffer[100] = "";
    if (fgets(buffer, 100, stdin) == NULL){
        Log("Error read file");
        return ERROR;
    }
    // do something
    return SUCCESS;
}

int main(){
    char *fileName = "example.c";
    bad1(fileName);
    bad2();
    good1(fileName);
    good2();
}

/*
int bad(char *fileName){
    char *buffer[100] = "";
    FILE *pFile;

    // missing checking parameter, resulting null_ptr_def
    if (fileName == NULL){
        Log("Error file")
        return -1;
    }
    pFile = fopen(fileName, "r");

    if (pFile == NULL){
        Log("Error open file");
        return -1;
    }

    // missing/incorrect error code status checking
-   if (fgets(buffer, 100, pFile) < 0){
+   if (fgets(buffer, 100, pFile) == NULL){
        Log("Error read file");
        // incorrect causal calling, resulting memory_leak
+       fclose(pFile);
        // incorrect error propagation
-       return 0;
+       return -1;
    }
    // processing
    fclose(pFile);
    return 0;
}
*/
