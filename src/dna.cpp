#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dna.h"

using namespace std;

DNA::DNA(){
  (*this).seq_string= "";
}

// -------------------------------------------------------------------------------------------

DNA::~DNA(){}


bool DNA::read_file(char * fileName){
        FILE *f = fopen(fileName, "r");
        char *sequenceName;
        char *sequence;
        if(f == NULL) return false;
        char c[300 + 1];
        memset(c, 0, 301);
        fgets(c, 200, f);
        if(c[0] != '>') return false;
         int size = strlen(c) - 1;
        sequenceName = (char *)malloc(size);
        memset(sequenceName, 0, size);
        if(sequenceName == NULL) return false;
        for(int i = 0; i < size - 1; ++i) {
                sequenceName[i] = c[i + 1];
        }
        long current = size + 1;
        fseek(f, 0L, 2);
        long seqLength = ftell(f) - current;
	(*this).seq_length=seqLength;
        char *seq = (char *)malloc(seqLength);
        if(seq == NULL) return false;
        memset(seq, 0, seqLength);

        fseek(f, 0L, 0);
        fgets(c, 300, f);

        int i = 0;
        char base = 0;
        while(fscanf(f, "%c", &base) != EOF) {
                if(base == '\n' || base == '\r') continue;
                seq[i++] = base;
        }

        fclose(f);

        seq = (char *)realloc(seq, i + 1);
        if(seq == NULL) return false;
        sequence = seq;
        (*this).seq_string=seq;
        return true;
}
