/********************************************************************/
/*                                                                  */
/*                 Pure LZW Compression Library                     */
/*                                                                  */
/*                          ACrazzi, 1999                           */
/*                                                                  */
/********************************************************************/


#ifndef LZW_H_

#define LZW_H_

//callback function for pack/unpack.
//It has two params: data (compressed/uncompressed) and length of one
typedef void (*LPLZWFLUSH)(char*,int);


//data : data for compression
//dsize : data length
//LZWFlush : callback function, which is called during compression
//maxlines : the number of chains in lzw table 511..16383
void LZWPack(char* data,int dsize,LPLZWFLUSH LZWFlush,int maxlines = 16383);

                  
//data : data for uncompression
//LZWFlush : callback function, which is called during uncompression
void LZWUnpack(char* data,LPLZWFLUSH LZWFlush);

#endif
