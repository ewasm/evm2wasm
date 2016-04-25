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
/* struct Stack{ */
/*   Instuction op; */
/*   SLIST_ENTRY(Stack) next; */
/* }; */

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
      
      SLIST_INSERT_HEAD(&segment_head, seg_pointer, next);
      last_i = 0; 
    } 
  }
  return segment_head;
}

void process_segments(struct SegmentHead head){

}

int main() {
  char *code_hex_str = "60606040525B60006020604051908101604052806000815260200150602060405190810160405280600081526020015060206040519081016040528060008152602001506000600060006103e8965086870260405180591061005e5750595b908082528060200260200182016040525095508687026040518059106100815750595b908082528060200260200182016040525094508687026040518059106100a45750595b908082528060200260200182016040525093506000925082505b8683101561013b576000915081505b8682101561012d5781830286838986020181518110156100025790602001906020020190908181526020015050818302858389860201815181101561000257906020019060200201909081815260200150505b81806001019250506100cd565b5b82806001019350506100be565b6000925082505b868310156101cc576000915081505b868210156101be578482888502018151811015610002579060200190602002015186838986020181518110156100025790602001906020020151880201848389860201815181101561000257906020019060200201909081815260200150505b8180600101925050610151565b5b8280600101935050610142565b5b50505050505050600a806101e16000396000f360606040526008565b00";

  // convert hex string to byte array
  const size_t len  = strlen(code_hex_str) / 2;
  const uint8_t *code = hexStringToBytes(code_hex_str);

  start_module();
  struct SegmentHead segments = get_segments(code, len);
  process_segments(segments);
  return 0;
}
