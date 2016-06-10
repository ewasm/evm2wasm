// TODO
//  generate code loc -> jumpdest map
//  can i haz streams?
//    would be postfix order
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "instructions.h"
// see QUEUE(3); this is equivalant to sys/queue.h
#include "../deps/cqueue/queue.h"
#include "../deps/hexString/hexString.h"

struct Segment{
  const uint8_t *value;
  size_t len;
  SLIST_ENTRY(Segment) next;
};

SLIST_HEAD(SegmentHead, Segment);

// Instuction stack
struct Stack{
  Instuction op;
  SLIST_ENTRY(Stack) next;
};

SLIST_HEAD(StackHead, Stack);

void start_module(){
  fputs ("(module ", stdout);
}

void end_module(){
  fputs (")", stdout);
}


// EVM -> WASM
// get segments of EVM code split by JUMPDESTs
// generate a map of code locations to JUMPDESTs
struct SegmentHead get_segments (const uint8_t* code, const size_t len) {

  struct SegmentHead segment_head;
  SLIST_INIT(&segment_head);

  for (size_t i = 0, last_i = 0; i < len; i++, last_i++) {
    uint8_t op = code[i];
    if (op == JUMPDEST) {
      // save segment in a link list
      printf("found jump dest\n");

      struct Segment * seg_pointer = malloc(sizeof(struct Segment));
      seg_pointer->value = code + i;
      seg_pointer->len = last_i;
      last_i = 0; 
      
      SLIST_INSERT_HEAD(&segment_head, seg_pointer, next);
    } 
  }
  return segment_head;
}

// counts a segments gas
// adds gas counting statments before  GAS, CALLs, SSTOREs 
// must inject in the beigning
void compile_segments(struct SegmentHead head){
  // create a bufffer to store the compiled segments
  char* buffer = NULL;
  size_t bufferSize = 0;
  FILE* myStream = open_memstream(&buffer, &bufferSize);
  struct Segment * seg;
  // the current gas count for a segment
  uint64_t gas_count = 0;

  // iterate the through the segment
  SLIST_FOREACH(seg, &head, next) {
    for(size_t i = 0; i < seg->len; i++) {
      uint8_t op = seg->value[i];
      /* fprintf(stdout, "%d", op); */
      switch(op) {
        case STOP:
          break; 
        case ADD:
          break;
        case MUL:
          break;
        case SUB:
          break;
        case DIV:
          break;
        case SDIV:
          break;
        case MOD:
          break;
        case SMOD:
          break;
        case ADDMOD:
          break;
        case MULMOD:
          break;
        case EXP:
          break;
        case SIGNEXTEND:
          break;
        case LT:
          break;
        case GT:
          break;
        case SLT:
          break;
        case SGT:
          break;
        case EQ:
          break;
        case ISZERO:
          break;
        case AND:
          break;
        case OR:
          break;
        case XOR:
          break;
        case NOT:
          break;
        case BYTE:
          break;
        case SHA3:
          break;
        case ADDRESS:
          break;
        case BALANCE:
          break;
        case ORIGIN:
          break;  
        case CALLER:
          break;
        case CALLVALUE:
          break;
        case CALLDATALOAD:
          break;
        case CALLDATASIZE:
          break;
        case CALLDATACOPY:
          break;
        case CODESIZE:
          break;
        case CODECOPY:
          break;
        case GASPRICE:
          break;
        case EXTCODESIZE:
          break;
        case EXTCODECOPY:
          break;
        case BLOCKHASH:
          break;
        case COINBASE:
          break;
        case TIMESTAMP:
          break;
        case NUMBER:
          break;
        case DIFFICULTY:
          break;
        case GASLIMIT:
          break;
        case POP:
          break;
        case MLOAD:
          break;
        case MSTORE:
          break;
        case MSTORE8:
          break;
        case SLOAD:
          break;
        case SSTORE:
          break;
        case JUMP:
          break;
        case JUMPI:
          break;
        case PC:
          break;
        case MSIZE:
          break;
        case GAS:
          break;
        case JUMPDEST:
          break;
        case  CREATE:
          break;
        case CALL:
          break;
        case CALLCODE:
          break;
        case RETURN:
          break;
        case DELEGATECALL: 
          break;
        default :
          if(PUSH1 <= op <= PUSH32) {
          
          } else if (DUP1 <= op <= DUP16) {
          
          } else if (SWAP1 <= op <= SWAP16) {
          
          } else if (LOG0 <= op <= LOG4) {
          
          } else {
            // invalid opcode
          }
      }
    }
  }

}

int main() {
  // test code
  char *code_hex_str = "60606040525B60006020604051908101604052806000815260200150602060405190810160405280600081526020015060206040519081016040528060008152602001506000600060006103e8965086870260405180591061005e5750595b908082528060200260200182016040525095508687026040518059106100815750595b908082528060200260200182016040525094508687026040518059106100a45750595b908082528060200260200182016040525093506000925082505b8683101561013b576000915081505b8682101561012d5781830286838986020181518110156100025790602001906020020190908181526020015050818302858389860201815181101561000257906020019060200201909081815260200150505b81806001019250506100cd565b5b82806001019350506100be565b6000925082505b868310156101cc576000915081505b868210156101be578482888502018151811015610002579060200190602002015186838986020181518110156100025790602001906020020151880201848389860201815181101561000257906020019060200201909081815260200150505b8180600101925050610151565b5b8280600101935050610142565b5b50505050505050600a806101e16000396000f360606040526008565b00";

  // convert hex string to byte array
  const size_t len  = strlen(code_hex_str) / 2;
  const uint8_t *code = hexStringToBytes(code_hex_str);

  start_module();
  struct SegmentHead segments = get_segments(code, len);
  compile_segments(segments);
  return 0;
}
