#ifndef __EVM2WAST_H
#define __EVM2WAST_H

#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

int evm2wast(const char *evm_code, size_t len, char **wast_code, size_t *wast_size);

#ifdef __cplusplus
}
#endif

#endif
