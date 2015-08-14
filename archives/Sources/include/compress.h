#ifndef __COMPRESS_H
#define __COMPRESS_H


#ifdef __cplusplus
extern "C" {  // only need to export C interface if used by C++ source code
#endif


int Compression_LZW (char *fsource,char *ftarget);
int DeCompression_LZW (char *fsource,char *ftarget);
int Compression_Huffman(char *fsource,char *ftarget);
int DeCompression_Huffman(char *fsource,char *ftarget);


#ifdef __cplusplus
}
#endif


#endif /* End __COMPRESS_H */

