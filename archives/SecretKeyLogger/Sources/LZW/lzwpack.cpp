
#include "lzw.h"
#include <windows.h>
#include <stdio.h>


FILE* my;

void CompFlush (char* data,int size)
{	
	fwrite(data,1,size,my);
};


void main (int argc, char* argv[])
{
char* mem1;
int i,j;
	if (argc != 4) {
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
	
	if (!sscanf(argv[3],"%u",&j)) {
		printf("Error in 3rd parameter\n");
		return;
	};
	
	LZWPack(mem1,i,CompFlush,j);
	
	fclose(my);
	
};
