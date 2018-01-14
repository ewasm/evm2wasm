#ifndef __EVM2WAST_H
#define __EVM2WAST_H
#include <stdlib.h>
#ifdef __cplusplus
extern "C" int evm2wast(char *evm_code, size_t len, char **wast_code, size_t *wast_size);
#endif
#endif
