/********************************************************************/
/*                                                                  */
/*                 Pure LZW Compression Library                     */
/*                                                                  */
/*                          ACrazzi, 1999                           */
/*                                                                  */
/********************************************************************/

#include <windows.h>
#include <stdio.h>

#define LZ_RESET 256
#define LZ_END 257


//prototype of callback-function for compressing/decompressing
typedef void (*LPLZWFLUSH)(char*,int);


//////////////////////////////////////////////////////////////////////
//                            compress
//////////////////////////////////////////////////////////////////////

//----------------junction of binary tree-------------------------------
class CBTree;

class CBTree
{
	int number;        //number of chain
	int size;          //size (length) of chain
	char* chain;       //the chain itself
	CBTree *left, *right;//left/rught descendant
	static int count;
		
	CBTree(char*,int);     //create chain
public:
	void SetCount(int n) {count = n;};
	int GetCount(void) {return count;};
	int Add(char*,int);   //add chain
	
	CBTree(void);          //create first tree 0..255
	~CBTree();             //delete
};


//---------------------------create chain-----------------------------
CBTree::CBTree(char* Str, int Length)
{
	chain = new char[Length];
	memcpy(chain,Str,Length);
	size = Length;
	left = NULL;
	right = NULL;
	count++;
	number = count;
};

//---------------------------create tree------------------------------
CBTree::CBTree(void)
{
	chain = new char[1];
	*chain = 0x7F;
	size = 1;
	left = NULL;
	right = NULL;
	number = 0x7F;
	count = 257;
};

//------------------destruct chain and its descendants----------------
CBTree::~CBTree()
{
	delete chain;
	if (left) delete left;
	if (right) delete right;
};

//----------------------search and create new chain-------------------
int CBTree::Add(char* Str,int Length)
{	
int i;
	
	if (Length == 1) return (BYTE)Str[0];
	
	if (size < Length) {//this chain is smaller than quered
		
		i = memcmp(chain,Str,size);
		if (( !i ) || (i < 0)) {
			//first bytes are equal or quered chain is bigger than this
			if (right) return right->Add(Str,Length); else {
				//chain is not present - create 
				right = new CBTree(Str,Length);
				return -count;
			};
		} else {
			//quered chain is smaller than this
			if (left) return left->Add(Str,Length); else {
				//chain is not present - create 
				left = new CBTree(Str,Length);
				return -count;
			};
		};
	} else {//length of this chain is more than quered
		i = memcmp(chain,Str,Length);
		if (!i) { //first bytes are equal
			if (size == Length) return number; else {
				if (left) return left->Add(Str,Length); else {
					//chain is not present - create 
					left = new CBTree(Str,Length);
					return -count;
				};
			};
		} else {
			if (i > 0) {//This > Str
				if (left) return left->Add(Str,Length); else {
					//chain is not present - create 
					left = new CBTree(Str,Length);
					return -count;	
				};
			} else {//This < Str
				if (right) return right->Add(Str,Length); else {
					//chain is not present - create 
					right = new CBTree(Str,Length);
					return -count;
				};
			};
		};		
	};
};

int CBTree::count = 0;

//-------------------this is compressing-function---------------------
void LZWPack(char* data,int dsize,LPLZWFLUSH LZWFlush,int maxlines = 16383)
{
#define ADD_TOKEN(token) \
	{\
		m = (cbits + curbit) >> 3;\
		lastbyte |= ( (token) << curbit );\
		curbit = (cbits + curbit) & 7;\
		*((int*)&lzbuf[lzframe]) = lastbyte;\
		lzframe += m;\
		lastbyte >>= (m<<3);\
		if (lzframe > (sizeof(lzbuf) - 4)) {\
			LZWFlush(lzbuf,lzframe);\
			lzframe = 0;\
		};\
	}
	
char lzbuf[0x1000], *chain = new char[0x100], *p1;
int i,j,k,m,clength,csize = 0x100;
int curbit, lastbyte, cbits, lzframe = 0;
CBTree* btree;
	
	btree = new CBTree();
	clength = 0;
	cbits = 9;
	curbit = 0;
	lastbyte = 0;

	for (i=0;i < dsize;i++) {
		//add current symbol to chain
		if (clength >= csize) {
			p1 = chain;
			chain = new char[csize + 0x100];
			memcpy(chain,p1,csize);
			csize += 0x100;
			delete p1;
		};
		chain[clength] = data[i];
		clength++;
		//search for chain in table and add if not present
		k = btree->Add(chain,clength);
		if (k < 0) {
			//this chain is not present in table - flush
			ADD_TOKEN(j);
			if (btree->GetCount() >= maxlines) {
				//write flush
				ADD_TOKEN(LZ_RESET);
				//flush
				delete btree;
				btree = new CBTree;
				cbits = 9;
			} else {
				if (btree->GetCount() >= (1 << cbits)) cbits++;
			};
			chain[0] = data[i];
			clength = 1;
			j = (BYTE)chain[0];
		} else j = k;
	};
	
	ADD_TOKEN(j);
	ADD_TOKEN(LZ_END);
	
	delete btree;
	
	if (curbit > 0) {
		//last flush
		*((int*)&lzbuf[lzframe]) = lastbyte;
		LZWFlush(lzbuf,lzframe + 1);
	} else {
		if (lzframe) LZWFlush(lzbuf,lzframe);
	};
};





//////////////////////////////////////////////////////////////////////
//                           decompress
//////////////////////////////////////////////////////////////////////

struct _Chain {  //one chain
	char* d;
	int s;
};

void LZWUnpack(char* data,LPLZWFLUSH LZWFlush)
{

#define GET_TOKEN(where) \
	{\
		(where) = ((*( (int*)&data[lzframe] )) >> curb) & ((1 << bits) - 1);\
		lzframe += (curb + bits) >> 3;\
		curb = (curb + bits) & 7;\
	}

#define ADD_LINE(line)\
	{\
		if ((outframe + chains[(line)].s) > sizeof(outbuf)) {\
			j = sizeof(outbuf) - outframe;\
			memcpy(&outbuf[outframe],chains[(line)].d,j);\
			for(;;) {\
				LZWFlush(outbuf,sizeof(outbuf));\
				if ( (chains[(line)].s - j) > sizeof(outbuf)) {\
					memcpy(outbuf,&chains[(line)].d[j],sizeof(outbuf));\
					j += sizeof(outbuf);\
				} else {\
					outframe = chains[(line)].s - j;\
					memcpy(outbuf,&chains[(line)].d[j],outframe);\
					break;\
				};\
			};\
		} else {\
			memcpy(&outbuf[outframe],chains[(line)].d,chains[(line)].s);\
			outframe += chains[(line)].s;\
		};\
	}

char outbuf[0x1000];
int i,j,curb,bits,lzframe,outframe,curchain,prevchain;
_Chain chains[0x4000];

	//initialize table
	for (i=0;i < 256;i++) {
		chains[i].d = new char[1];
		chains[i].s = 1;
		*chains[i].d = i;
	};

	chains[256].d = NULL;
	chains[257].d = NULL;

	lzframe = 0;
	outframe = 0;
	bits = 9;
	curb = 0;
	curchain = 258;
	
	GET_TOKEN(prevchain);
	if (prevchain == LZ_END) goto exit_proc;
	ADD_LINE(prevchain);

	for (;;) {
		GET_TOKEN(i);
		switch (i) {
			
			case LZ_RESET:
				for (i=258;i<curchain;i++) delete chains[i].d;
				curchain = 258;
				bits = 9;
				GET_TOKEN(prevchain);
				if (prevchain == LZ_END) goto exit_proc;
				ADD_LINE(prevchain);
			break;
			
			case LZ_END:
				goto exit_proc;
			break;
			
			default:
				chains[curchain].d = new char[chains[prevchain].s + 1];
				memcpy(chains[curchain].d,chains[prevchain].d,chains[prevchain].s);
				chains[curchain].s = chains[prevchain].s + 1;
				if (i < curchain) {
					chains[curchain].d[chains[prevchain].s] = chains[i].d[0];
				} else {
					chains[curchain].d[chains[prevchain].s] = chains[prevchain].d[0];
				};
				curchain++;
				prevchain = i;
				ADD_LINE(i);
				if (curchain >= (1 << bits)) bits++;
			break;

		};
	};
exit_proc:
	if (outframe) LZWFlush(outbuf,outframe);
	for (i=0;i<curchain;i++) if (chains[i].d) delete chains[i].d;
};

