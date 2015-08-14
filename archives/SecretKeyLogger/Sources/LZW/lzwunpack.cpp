
#include "lzw.h"
#include <windows.h>
#include <stdio.h>

FILE* my;

void callback(char* s,int length)
{
	fwrite(s,1,length,my);
};


void main(int argc, char* argv[])
{
char* mem1;
int i;

	if (argc != 3) {
		printf("Error in cmd line\n");
		return;
	};
	
	my = fopen(argv[1],"rb");
	if (!my) {
		printf("Cannot open input file\n");
		return;
	};
	fseek(my,0,SEEK_END);
	i = ftell(my);
	mem1 = new char[i];
	fseek(my,0,SEEK_SET);
	fread(mem1,1,i,my);
	fclose(my);
	my = fopen(argv[2],"w+b");
	if (!my) {
		printf("Cannot create output file\n");
		return;
	};
	
	LZWUnpack(mem1,callback);
	
	fclose(my);	
};
