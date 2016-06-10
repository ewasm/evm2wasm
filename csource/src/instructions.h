// Virtual machine bytecode instructions.
typedef enum Instruction {
  STOP = 0x00,      // halts execution
  ADD,              // addition operation
  MUL,              // mulitplication operation
  SUB,              // subtraction operation
  DIV,              // integer division operation
  SDIV,             // signed integer division operation
  MOD,              // modulo remainder operation
  SMOD,             // signed modulo remainder operation
  ADDMOD,           // unsigned modular addition
  MULMOD,           // unsigned modular multiplication
  EXP,              // exponential operation
  SIGNEXTEND,       // extend length of signed integer

  LT = 0x10,        // less-than comparision
  GT,               // greater-than comparision
  SLT,              // signed less-than comparision
  SGT,              // signed greater-than comparision
  EQ,               // equality comparision
  ISZERO,           // simple not operator
  AND,              // bitwise AND operation
  OR,               // bitwise OR operation
  XOR,              // bitwise XOR operation
  NOT,              // bitwise NOT opertation
  BYTE,             // retrieve single byte from word

  SHA3 = 0x20,      // compute SHA3-256 hash

  ADDRESS = 0x30,   // get address of currently executing account
  BALANCE,          // get balance of the given account
  ORIGIN,           // get execution origination address
  CALLER,           // get caller address
  CALLVALUE,        // get deposited value by the instruction/transaction responsible for this execution
  CALLDATALOAD,     // get input data of current environment
  CALLDATASIZE,     // get size of input data in current environment
  CALLDATACOPY,     // copy input data in current environment to memory
  CODESIZE,         // get size of code running in current environment
  CODECOPY,         // copy code running in current environment to memory
  GASPRICE,         // get price of gas in current environment
  EXTCODESIZE,      // get external code size (from another contract)
  EXTCODECOPY,      // copy external code (from another contract)

  BLOCKHASH = 0x40, // get hash of most recent complete block
  COINBASE,         // get the block's coinbase address
  TIMESTAMP,        // get the block's timestamp
  NUMBER,           // get the block's number
  DIFFICULTY,       // get the block's difficulty
  GASLIMIT,         // get the block's gas limit

  POP = 0x50,       // remove item from stack
  MLOAD,            // load word from memory
  MSTORE,           // save word to memory
  MSTORE8,          // save byte to memory
  SLOAD,            // load word from storage
  SSTORE,           // save word to storage
  JUMP,             // alter the program counter
  JUMPI,            // conditionally alter the program counter
  PC,               // get the program counter
  MSIZE,            // get the size of active memory
  GAS,              // get the amount of available gas
  JUMPDEST,         // set a potential jump destination

  PUSH1 = 0x60,     // place 1  byte item on stack
  PUSH2,            // place 2  byte item on stack
  PUSH3,            // place 3  byte item on stack
  PUSH4,            // place 4  byte item on stack
  PUSH5,            // place 5  byte item on stack
  PUSH6,            // place 6  byte item on stack
  PUSH7,            // place 7  byte item on stack
  PUSH8,            // place 8  byte item on stack
  PUSH9,            // place 9  byte item on stack
  PUSH10,           // place 10 byte item on stack
  PUSH11,           // place 11 byte item on stack
  PUSH12,           // place 12 byte item on stack
  PUSH13,           // place 13 byte item on stack
  PUSH14,           // place 14 byte item on stack
  PUSH15,           // place 15 byte item on stack
  PUSH16,           // place 16 byte item on stack
  PUSH17,           // place 17 byte item on stack
  PUSH18,           // place 18 byte item on stack
  PUSH19,           // place 19 byte item on stack
  PUSH20,           // place 20 byte item on stack
  PUSH21,           // place 21 byte item on stack
  PUSH22,           // place 22 byte item on stack
  PUSH23,           // place 23 byte item on stack
  PUSH24,           // place 24 byte item on stack
  PUSH25,           // place 25 byte item on stack
  PUSH26,           // place 26 byte item on stack
  PUSH27,           // place 27 byte item on stack
  PUSH28,           // place 28 byte item on stack
  PUSH29,           // place 29 byte item on stack
  PUSH30,           // place 30 byte item on stack
  PUSH31,           // place 31 byte item on stack
  PUSH32,           // place 32 byte item on stack

  DUP1 = 0x80,      // copies the 1st  highest item in the stack to the top of the stack
  DUP2,             // copies the 2nd  highest item in the stack to the top of the stack
  DUP3,             // copies the 3rd  highest item in the stack to the top of the stack
  DUP4,             // copies the 4th  highest item in the stack to the top of the stack
  DUP5,             // copies the 5th  highest item in the stack to the top of the stack
  DUP6,             // copies the 6th  highest item in the stack to the top of the stack
  DUP7,             // copies the 7th  highest item in the stack to the top of the stack
  DUP8,             // copies the 8th  highest item in the stack to the top of the stack
  DUP9,             // copies the 9th  highest item in the stack to the top of the stack
  DUP10,            // copies the 10th highest item in the stack to the top of the stack
  DUP11,            // copies the 11th highest item in the stack to the top of the stack
  DUP12,            // copies the 12th highest item in the stack to the top of the stack
  DUP13,            // copies the 13th highest item in the stack to the top of the stack
  DUP14,            // copies the 14th highest item in the stack to the top of the stack
  DUP15,            // copies the 15th highest item in the stack to the top of the stack
  DUP16,            // copies the 16th highest item in the stack to the top of the stack

  SWAP1 = 0x90,     // swaps the highest and 1st  highest value on the stack
  SWAP2,            // swaps the highest and 2nd  highest value on the stack
  SWAP3,            // swaps the highest and 3th  highest value on the stack
  SWAP4,            // swaps the highest and 4th  highest value on the stack
  SWAP5,            // swaps the highest and 5th  highest value on the stack
  SWAP6,            // swaps the highest and 6th  highest value on the stack
  SWAP7,            // swaps the highest and 7th  highest value on the stack
  SWAP8,            // swaps the highest and 8th  highest value on the stack
  SWAP9,            // swaps the highest and 9th  highest value on the stack
  SWAP10,           // swaps the highest and 10th highest value on the stack
  SWAP11,           // swaps the highest and 11th highest value on the stack
  SWAP12,           // swaps the highest and 12th highest value on the stack
  SWAP13,           // swaps the highest and 13th highest value on the stack
  SWAP14,           // swaps the highest and 14th highest value on the stack
  SWAP15,           // swaps the highest and 15th highest value on the stack
  SWAP16,           // swaps the highest and 16th highest value on the stack

  LOG0 = 0xa0,      // Makes a log entry; 0 topics.
  LOG1,             // Makes a log entry; 1 topic.
  LOG2,             // Makes a log entry; 2 topics.
  LOG3,             // Makes a log entry; 3 topics.
  LOG4,             // Makes a log entry; 4 topics.

  CREATE = 0xf0,    // create a new account with associated code
  CALL,             // message-call into an account
  CALLCODE,         // message-call with another account's code only
  RETURN,           // halt execution returning output data
  DELEGATECALL,     // like CALLCODE but keeps caller's value and sender
  SUICIDE = 0xff    // halt execution and register account for later deletion
} Instuction;

struct instr_info {
  const char* name;
  int         baseCost;
  int         offStack;
  int         onStack;
};

struct instr_info instuctions[SUICIDE - STOP + 1] = {
  [STOP]         = {"STOP"        , 0    , 0, 0},
  [ADD]          = {"ADD"         , 3    , 2, 1},
  [MUL]          = {"MUL"         , 5    , 2, 1},
  [SUB]          = {"SUB"         , 3    , 2, 1},
  [DIV]          = {"DIV"         , 5    , 2, 1},
  [SDIV]         = {"SDIV"        , 5    , 2, 1},
  [MOD]          = {"MOD"         , 5    , 2, 1},
  [SMOD]         = {"SMOD"        , 5    , 2, 1},
  [ADDMOD]       = {"ADDMOD"      , 8    , 3, 1},
  [MULMOD]       = {"MULMOD"      , 8    , 3, 1},
  [EXP]          = {"EXP"         , 10   , 2, 1},
  [SIGNEXTEND]   = {"SIGNEXTEND"  , 5    , 1, 1},
  [LT]           = {"LT"          , 3    , 2, 1},
  [GT]           = {"GT"          , 3    , 2, 1},
  [SLT]          = {"SLT"         , 3    , 2, 1},
  [SGT]          = {"SGT"         , 3    , 2, 1},
  [EQ]           = {"EQ"          , 3    , 2, 1},
  [ISZERO]       = {"ISZERO"      , 3    , 1, 1},
  [AND]          = {"AND"         , 3    , 2, 1},
  [OR]           = {"OR"          , 3    , 2, 1},
  [XOR]          = {"XOR"         , 3    , 2, 1},
  [NOT]          = {"NOT"         , 3    , 1, 1},
  [BYTE]         = {"BYTE"        , 3    , 2, 1},
  [SHA3]         = {"SHA3"        , 30   , 2, 1},
  [ADDRESS]      = {"ADDRESS"     , 2    , 0, 1},
  [BALANCE]      = {"BALANCE"     , 20   , 1, 1},
  [ORIGIN]       = {"ORIGIN"      , 2    , 0, 1},
  [CALLER]       = {"CALLER"      , 2    , 0, 1},
  [CALLVALUE]    = {"CALLVALUE"   , 2    , 0, 1},
  [CALLDATALOAD] = {"CALLDATALOAD", 3    , 1, 1},
  [CALLDATASIZE] = {"CALLDATASIZE", 2    , 0, 1},
  [CALLDATACOPY] = {"CALLDATACOPY", 3    , 3, 0},
  [CODESIZE]     = {"CODESIZE"    , 2    , 0, 1},
  [CODECOPY]     = {"CODECOPY"    , 3    , 3, 0},
  [GASPRICE]     = {"GASPRICE"    , 2    , 0, 1},
  [EXTCODESIZE]  = {"EXTCODESIZE" , 20   , 1, 1},
  [EXTCODECOPY]  = {"EXTCODECOPY" , 20   , 4, 0},
  [BLOCKHASH]    = {"BLOCKHASH"   , 20   , 1, 1},
  [COINBASE]     = {"COINBASE"    , 2    , 0, 1},
  [TIMESTAMP]    = {"TIMESTAMP"   , 2    , 0, 1},
  [NUMBER]       = {"NUMBER"      , 2    , 0, 1},
  [DIFFICULTY]   = {"DIFFICULTY"  , 2    , 0, 1},
  [GASLIMIT]     = {"GASLIMIT"    , 2    , 0, 1},
  [POP]          = {"POP"         , 2    , 1, 0},
  [MLOAD]        = {"MLOAD"       , 3    , 1, 1},
  [MSTORE]       = {"MSTORE"      , 3    , 2, 0},
  [MSTORE8]      = {"MSTORE8"     , 3    , 2, 0},
  [SLOAD]        = {"SLOAD"       , 50   , 1, 1},
  [SSTORE]       = {"SSTORE"      , 0    , 2, 0},
  [JUMP]         = {"JUMP"        , 8    , 1, 0},
  [JUMPI]        = {"JUMPI"       , 10   , 2, 0},
  [PC]           = {"PC"          , 2    , 0, 1},
  [MSIZE]        = {"MSIZE"       , 2    , 0, 1},
  [GAS]          = {"GAS"         , 2    , 0, 1},
  [JUMPDEST]     = {"JUMPDEST"    , 1    , 0, 0},
  [PUSH1]        = {"PUSH1"       , 3    , 0, 1},
  [PUSH2]        = {"PUSH2"       , 3    , 0, 1},
  [PUSH3]        = {"PUSH3"       , 3    , 0, 1},
  [PUSH4]        = {"PUSH4"       , 3    , 0, 1},
  [PUSH5]        = {"PUSH5"       , 3    , 0, 1},
  [PUSH6]        = {"PUSH6"       , 3    , 0, 1},
  [PUSH7]        = {"PUSH7"       , 3    , 0, 1},
  [PUSH8]        = {"PUSH8"       , 3    , 0, 1},
  [PUSH9]        = {"PUSH9"       , 3    , 0, 1},
  [PUSH10]       = {"PUSH10"      , 3    , 0, 1},
  [PUSH11]       = {"PUSH11"      , 3    , 0, 1},
  [PUSH12]       = {"PUSH12"      , 3    , 0, 1},
  [PUSH13]       = {"PUSH13"      , 3    , 0, 1},
  [PUSH14]       = {"PUSH14"      , 3    , 0, 1},
  [PUSH15]       = {"PUSH15"      , 3    , 0, 1},
  [PUSH16]       = {"PUSH16"      , 3    , 0, 1},
  [PUSH17]       = {"PUSH17"      , 3    , 0, 1},
  [PUSH18]       = {"PUSH18"      , 3    , 0, 1},
  [PUSH19]       = {"PUSH19"      , 3    , 0, 1},
  [PUSH20]       = {"PUSH20"      , 3    , 0, 1},
  [PUSH21]       = {"PUSH21"      , 3    , 0, 1},
  [PUSH22]       = {"PUSH22"      , 3    , 0, 1},
  [PUSH23]       = {"PUSH23"      , 3    , 0, 1},
  [PUSH24]       = {"PUSH24"      , 3    , 0, 1},
  [PUSH25]       = {"PUSH25"      , 3    , 0, 1},
  [PUSH26]       = {"PUSH26"      , 3    , 0, 1},
  [PUSH27]       = {"PUSH27"      , 3    , 0, 1},
  [PUSH28]       = {"PUSH28"      , 3    , 0, 1},
  [PUSH29]       = {"PUSH29"      , 3    , 0, 1},
  [PUSH30]       = {"PUSH30"      , 3    , 0, 1},
  [PUSH31]       = {"PUSH31"      , 3    , 0, 1},
  [PUSH32]       = {"PUSH32"      , 3    , 0, 1},
  [DUP1]         = {"DUP1"        , 3    , 0, 1},
  [DUP2]         = {"DUP2"        , 3    , 0, 1},
  [DUP3]         = {"DUP3"        , 3    , 0, 1},
  [DUP4]         = {"DUP4"        , 3    , 0, 1},
  [DUP5]         = {"DUP5"        , 3    , 0, 1},
  [DUP6]         = {"DUP6"        , 3    , 0, 1},
  [DUP7]         = {"DUP7"        , 3    , 0, 1},
  [DUP8]         = {"DUP8"        , 3    , 0, 1},
  [DUP9]         = {"DUP9"        , 3    , 0, 1},
  [DUP10]        = {"DUP10"       , 3    , 0, 1},
  [DUP11]        = {"DUP11"       , 3    , 0, 1},
  [DUP12]        = {"DUP12"       , 3    , 0, 1},
  [DUP13]        = {"DUP13"       , 3    , 0, 1},
  [DUP14]        = {"DUP14"       , 3    , 0, 1},
  [DUP15]        = {"DUP15"       , 3    , 0, 1},
  [DUP16]        = {"DUP16"       , 3    , 0, 1},
  [SWAP1]        = {"SWAP1"       , 3    , 0, 0},
  [SWAP2]        = {"SWAP2"       , 3    , 0, 0},
  [SWAP3]        = {"SWAP3"       , 3    , 0, 0},
  [SWAP4]        = {"SWAP4"       , 3    , 0, 0},
  [SWAP5]        = {"SWAP5"       , 3    , 0, 0},
  [SWAP6]        = {"SWAP6"       , 3    , 0, 0},
  [SWAP7]        = {"SWAP7"       , 3    , 0, 0},
  [SWAP8]        = {"SWAP8"       , 3    , 0, 0},
  [SWAP9]        = {"SWAP9"       , 3    , 0, 0},
  [SWAP10]       = {"SWAP10"      , 3    , 0, 0},
  [SWAP11]       = {"SWAP11"      , 3    , 0, 0},
  [SWAP12]       = {"SWAP12"      , 3    , 0, 0},
  [SWAP13]       = {"SWAP13"      , 3    , 0, 0},
  [SWAP14]       = {"SWAP14"      , 3    , 0, 0},
  [SWAP15]       = {"SWAP15"      , 3    , 0, 0},
  [SWAP16]       = {"SWAP16"      , 3    , 0, 0},
  [LOG0]         = {"LOG0"        , 375  , 2, 0},
  [LOG1]         = {"LOG1"        , 375  , 3, 0},
  [LOG2]         = {"LOG2"        , 375  , 4, 0},
  [LOG3]         = {"LOG3"        , 375  , 5, 0},
  [LOG4]         = {"LOG4"        , 375  , 6, 0},
  [CREATE]       = {"CREATE"      , 32000, 3, 1},
  [CALL]         = {"CALL"        , 40   , 7, 1},
  [CALLCODE]     = {"CALLCODE"    , 40   , 7, 1},
  [RETURN]       = {"RETURN"      , 0    , 2, 0},
  [DELEGATECALL] = {"DELEGATECALL", 40   , 6, 1},
  [SUICIDE]      = {"SUICIDE"     , 0    , 1, 0}
};
