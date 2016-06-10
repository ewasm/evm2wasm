#include <stdio.h>
#include <stdint.h>

#include "instructions.h"
// see QUEUE(3); this is equivalant to sys/queue.h
#include "../deps/cqueue/queue.h"

struct node{
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
