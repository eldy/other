#ifndef _CRYPT_H_
#define _CRYPT_H_

#ifdef __cplusplus
extern "C" {  // only need to export C interface if used by C++ source code
#endif

int base64_encode(const void *data, int size, char **str);
int base64_decode(const char *str, void *data);
int quoted_decode(const char *str, void *data);

#ifdef __cplusplus
}
#endif

#endif

