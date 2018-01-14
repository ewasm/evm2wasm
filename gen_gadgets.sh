#!/bin/bash
cstr () { 
sed '$!s/$/\\n\\/' $1 2>/dev/null | sed 's/"/\\"/g'
}
fill () {
	for i in {0..$1}
	do
		echo "\"\"," >> gadgets.c
	done
}
#0x00
opcodes=("STOP" "ADD" "MUL" "SUB" "DIV" "SDIV" "MOD" 
"ADDMOD" "MULMOD" "EXP" "SIGNEXTEND" 0 0 0 0 
"LT" "GT" "SLT" "SGT" "EQ" "ISZERO" "AND" "OR" "XOR" 
"NOT" "BYTE" 0 0 0 0 0 "SHA3" 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 "ADDRESS" "BALANCE" "ORIGIN" "CALLER" 
"CALLVALUE" "CALLDATALOAD" "CALLDATASIZE" 
"CALLDATACOPY" "CODESIZE" "CODECOPY" "GASPRICE" 
"EXTCODZISE" "EXTCODECOPY" "RETURNDATASIZE"
"RETURNDATACOPY" 0 "BLOCKHASH" "COINBASE" "TIMESTAMP" 
"NUMBER" "DIFFICULTY" "GASLIMIT" 0 0 0 0 0 0 0 0 0 0 
"POP" "MLOAD" "MSTORE" "MSTORE8" "SLOAD" "SLOAD" "SSTORE" 
"JUMP" "JUMPI" "PC" "MSIZE" "GAS" "JUMPDEST" 0 0 0 0 0 
"SELFDESTRUCT" 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
"CALL" "CALLCODE" "RETURN" "DELEGATECALL" "STATICCALL" 
"REVERT" 0 0 0 0 0 0 0 "bswap_i32" "bswap_i64" 
"bswap_m128" "bswap_m160" "bswap_m256" "callback_128" 
"callback_160" "callback_256" "callback_32" "callback" 
"check_overflow_i64" "check_overflow" "gte_256" 
"gte_320" "gte_512" "iszero_256" "iszero_320" "iszero_512" 
"keccak" "memcpy" "memset" "memusegas" "mod_320" 
"mod_512" "mul_256")

cat <<EOF > gadgets.c
#ifndef __EVM2WASM_GADGETS_H
#define __EVM2WASM_GADGETS_H
#pragma GCC diagnostic ignored "-Woverlength-strings"
#include "gadgets.h"
EOF
echo "const int gadget_count = ${#opcodes[@]};" >> gadgets.c
echo "const char *gadgets[${#opcodes[@]}+1] = {" >> gadgets.c
for i in ${opcodes[@]}
do
	if [[ $i == 0 ]]
	then
		echo "\"\"," >> gadgets.c
		continue
	fi
	echo "\"$(cstr wasm/$i.wast)\"," >> gadgets.c
done
echo "\"\"};" >> gadgets.c
echo '#endif' >> gadgets.c
exit 0
