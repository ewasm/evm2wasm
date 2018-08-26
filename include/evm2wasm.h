#pragma once

#include <map>
#include <set>
#include <string>
#include <tuple>
#include <vector>

namespace evm2wasm
{
enum class opcodeEnum
{
    STOP,
    ADD,
    MUL,
    SUB,
    DIV,
    SDIV,
    MOD,
    SMOD,
    ADDMOD,
    MULMOD,
    EXP,
    SIGNEXTEND,
    LT,
    GT,
    SLT,
    SGT,
    EQ,
    ISZERO,
    AND,
    OR,
    XOR,
    NOT,
    BYTE,
    SHA3,
    ADDRESS,
    BALANCE,
    ORIGIN,
    CALLER,
    CALLVALUE,
    CALLDATALOAD,
    CALLDATASIZE,
    CALLDATACOPY,
    CODESIZE,
    CODECOPY,
    GASPRICE,
    EXTCODESIZE,
    EXTCODECOPY,
    RETURNDATASIZE,
    RETURNDATACOPY,
    BLOCKHASH,
    COINBASE,
    TIMESTAMP,
    NUMBER,
    DIFFICULTY,
    GASLIMIT,
    POP,
    MLOAD,
    MSTORE,
    MSTORE8,
    SLOAD,
    SSTORE,
    JUMP,
    JUMPI,
    PC,
    MSIZE,
    GAS,
    JUMPDEST,
    PUSH,
    DUP,
    SWAP,
    LOG,
    CREATE,
    CALL,
    CALLCODE,
    RETURN,
    DELEGATECALL,
    STATICCALL,
    REVERT,
    INVALID,
    SELFDESTRUCT,
    bswap_i32,
    bswap_i64,
    bswap_m128,
    bswap_m160,
    bswap_m256,
    callback,
    callback_128,
    callback_160,
    callback_256,
    callback_32,
    check_overflow,
    check_overflow_i64,
    gte_256,
    gte_320,
    gte_512,
    iszero_256,
    iszero_320,
    iszero_512,
    keccak,
    memcpy,
    memset,
    memusegas,
    mod_320,
    mod_512,
    mul_256
};

// maps the async ops to their call back function
static std::map<opcodeEnum, std::string> callbackFuncs = {
    {opcodeEnum::SSTORE, "$callback"},
    {opcodeEnum::SLOAD, "$callback_256"},
    {opcodeEnum::CREATE, "$callback_160"},
    {opcodeEnum::CALL, "$callback_32"},
    {opcodeEnum::DELEGATECALL, "$callback"},
    {opcodeEnum::CALLCODE, "$callback_32"},
    {opcodeEnum::EXTCODECOPY, "$callback"},
    {opcodeEnum::EXTCODESIZE, "$callback_32"},
    {opcodeEnum::CODECOPY, "$callback"},
    {opcodeEnum::CODESIZE, "$callback_32"},
    {opcodeEnum::BALANCE, "$callback_128"},
    {opcodeEnum::BLOCKHASH, "$callback_256"}};

typedef std::tuple<opcodeEnum, int, int, int> Opcode;
static std::map<int, std::tuple<opcodeEnum, int, int, int>> codes = {
    {0x00, Opcode{opcodeEnum::STOP, 0, 0, 0}},
    {0x01, Opcode{opcodeEnum::ADD, 3, 2, 1}},
    {0x02, Opcode{opcodeEnum::MUL, 5, 2, 1}},
    {0x03, Opcode{opcodeEnum::SUB, 3, 2, 1}},
    {0x04, Opcode{opcodeEnum::DIV, 5, 2, 1}},
    {0x05, Opcode{opcodeEnum::SDIV, 5, 2, 1}},
    {0x06, Opcode{opcodeEnum::MOD, 5, 2, 1}},
    {0x07, Opcode{opcodeEnum::SMOD, 5, 2, 1}},
    {0x08, Opcode{opcodeEnum::ADDMOD, 8, 3, 1}},
    {0x09, Opcode{opcodeEnum::MULMOD, 8, 3, 1}},
    {0x0a, Opcode{opcodeEnum::EXP, 10, 2, 1}},
    {0x0b, Opcode{opcodeEnum::SIGNEXTEND, 5, 2, 1}},

    // 0x10 range - bit ops
    {0x10, Opcode{opcodeEnum::LT, 3, 2, 1}},
    {0x11, Opcode{opcodeEnum::GT, 3, 2, 1}},
    {0x12, Opcode{opcodeEnum::SLT, 3, 2, 1}},
    {0x13, Opcode{opcodeEnum::SGT, 3, 2, 1}},
    {0x14, Opcode{opcodeEnum::EQ, 3, 2, 1}},
    {0x15, Opcode{opcodeEnum::ISZERO, 3, 1, 1}},
    {0x16, Opcode{opcodeEnum::AND, 3, 2, 1}},
    {0x17, Opcode{opcodeEnum::OR, 3, 2, 1}},
    {0x18, Opcode{opcodeEnum::XOR, 3, 2, 1}},
    {0x19, Opcode{opcodeEnum::NOT, 3, 1, 1}},
    {0x1a, Opcode{opcodeEnum::BYTE, 3, 2, 1}},

    // 0x20 range - crypto
    {0x20, Opcode{opcodeEnum::SHA3, 30, 2, 1}},

    // 0x30 range - closure state
    {0x30, Opcode{opcodeEnum::ADDRESS, 0, 0, 1}},
    {0x31, Opcode{opcodeEnum::BALANCE, 0, 1, 1}},
    {0x32, Opcode{opcodeEnum::ORIGIN, 0, 0, 1}},
    {0x33, Opcode{opcodeEnum::CALLER, 0, 0, 1}},
    {0x34, Opcode{opcodeEnum::CALLVALUE, 0, 0, 1}},
    {0x35, Opcode{opcodeEnum::CALLDATALOAD, 0, 1, 1}},
    {0x36, Opcode{opcodeEnum::CALLDATASIZE, 0, 0, 1}},
    {0x37, Opcode{opcodeEnum::CALLDATACOPY, 0, 3, 0}},
    {0x38, Opcode{opcodeEnum::CODESIZE, 0, 0, 1}},
    {0x39, Opcode{opcodeEnum::CODECOPY, 0, 3, 0}},
    {0x3a, Opcode{opcodeEnum::GASPRICE, 0, 0, 1}},
    {0x3b, Opcode{opcodeEnum::EXTCODESIZE, 0, 1, 1}},
    {0x3c, Opcode{opcodeEnum::EXTCODECOPY, 0, 4, 0}},
    {0x3d, Opcode{opcodeEnum::RETURNDATASIZE, 0, 0, 1}},
    {0x3e, Opcode{opcodeEnum::RETURNDATACOPY, 0, 3, 0}},

    // "0x40" range - block operations
    {0x40, Opcode{opcodeEnum::BLOCKHASH, 0, 1, 1}},
    {0x41, Opcode{opcodeEnum::COINBASE, 0, 0, 1}},
    {0x42, Opcode{opcodeEnum::TIMESTAMP, 0, 0, 1}},
    {0x43, Opcode{opcodeEnum::NUMBER, 0, 0, 1}},
    {0x44, Opcode{opcodeEnum::DIFFICULTY, 0, 0, 1}},
    {0x45, Opcode{opcodeEnum::GASLIMIT, 0, 0, 1}},

    // 0x50 range - "storage" and execution
    {0x50, Opcode{opcodeEnum::POP, 2, 1, 0}},
    {0x51, Opcode{opcodeEnum::MLOAD, 3, 1, 1}},
    {0x52, Opcode{opcodeEnum::MSTORE, 3, 2, 0}},
    {0x53, Opcode{opcodeEnum::MSTORE8, 3, 2, 0}},
    {0x54, Opcode{opcodeEnum::SLOAD, 0, 1, 1}},
    {0x55, Opcode{opcodeEnum::SSTORE, 0, 2, 0}},
    {0x56, Opcode{opcodeEnum::JUMP, 8, 0, 0}},
    {0x57, Opcode{opcodeEnum::JUMPI, 10, 0, 0}},
    {0x58, Opcode{opcodeEnum::PC, 2, 0, 1}},
    {0x59, Opcode{opcodeEnum::MSIZE, 2, 0, 1}},
    {0x5a, Opcode{opcodeEnum::GAS, 0, 0, 1}},
    {0x5b, Opcode{opcodeEnum::JUMPDEST, 0, 0, 0}},

    // 0x60, range
    {0x60, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x61, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x62, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x63, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x64, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x65, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x66, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x67, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x68, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x69, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x6a, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x6b, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x6c, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x6d, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x6e, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x6f, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x70, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x71, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x72, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x73, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x74, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x75, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x76, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x77, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x78, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x79, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x7a, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x7b, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x7c, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x7d, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x7e, Opcode{opcodeEnum::PUSH, 3, 0, 1}},
    {0x7f, Opcode{opcodeEnum::PUSH, 3, 0, 1}},

    {0x80, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x81, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x82, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x83, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x84, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x85, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x86, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x87, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x88, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x89, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x8a, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x8b, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x8c, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x8d, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x8e, Opcode{opcodeEnum::DUP, 3, 0, 1}},
    {0x8f, Opcode{opcodeEnum::DUP, 3, 0, 1}},

    {0x90, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x91, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x92, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x93, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x94, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x95, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x96, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x97, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x98, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x99, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x9a, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x9b, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x9c, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x9d, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x9e, Opcode{opcodeEnum::SWAP, 3, 0, 0}},
    {0x9f, Opcode{opcodeEnum::SWAP, 3, 0, 0}},

    {0xa0, Opcode{opcodeEnum::LOG, 0, 2, 0}},
    {0xa1, Opcode{opcodeEnum::LOG, 0, 3, 0}},
    {0xa2, Opcode{opcodeEnum::LOG, 0, 4, 0}},
    {0xa3, Opcode{opcodeEnum::LOG, 0, 5, 0}},
    {0xa4, Opcode{opcodeEnum::LOG, 0, 6, 0}},

    // "0xf0" range - closures
    {0xf0, Opcode{opcodeEnum::CREATE, 0, 3, 1}},
    {0xf1, Opcode{opcodeEnum::CALL, 0, 7, 1}},
    {0xf2, Opcode{opcodeEnum::CALLCODE, 0, 7, 1}},
    {0xf3, Opcode{opcodeEnum::RETURN, 0, 2, 0}},
    {0xf4, Opcode{opcodeEnum::DELEGATECALL, 0, 6, 1}},
    {0xfa, Opcode{opcodeEnum::STATICCALL, 0, 6, 1}},

    // "0x70", range - other
    {0xfd, Opcode{opcodeEnum::REVERT, 0, 2, 0}},
    {0xfe, Opcode{opcodeEnum::INVALID, 0, 0, 0}},
    {0xff, Opcode{opcodeEnum::SELFDESTRUCT, 0, 1, 0}}};

static std::map<opcodeEnum, std::vector<opcodeEnum>> depMap = {
    {opcodeEnum::callback_256, {opcodeEnum::bswap_m256}},
    {opcodeEnum::callback_160, {opcodeEnum::bswap_m160}},
    {opcodeEnum::callback_128, {opcodeEnum::bswap_m128}},
    {opcodeEnum::bswap_m256, {opcodeEnum::bswap_i64}},
    {opcodeEnum::bswap_m128, {opcodeEnum::bswap_i64}},
    {opcodeEnum::bswap_m160, {opcodeEnum::bswap_i64, opcodeEnum::bswap_i32}},
    {opcodeEnum::keccak, {opcodeEnum::memcpy, opcodeEnum::memset}},
    {opcodeEnum::mod_320, {opcodeEnum::iszero_320, opcodeEnum::gte_320}},
    {opcodeEnum::mod_512, {opcodeEnum::iszero_512, opcodeEnum::gte_512}},
    {opcodeEnum::MOD, {opcodeEnum::iszero_256, opcodeEnum::gte_256}},
    {opcodeEnum::ADDMOD, {opcodeEnum::mod_320}},
    {opcodeEnum::MULMOD, {opcodeEnum::mod_512}},
    {opcodeEnum::SDIV, {opcodeEnum::iszero_256, opcodeEnum::gte_256}},
    {opcodeEnum::SMOD, {opcodeEnum::iszero_256, opcodeEnum::gte_256}},
    {opcodeEnum::DIV, {opcodeEnum::iszero_256, opcodeEnum::gte_256}},
    {opcodeEnum::EXP, {opcodeEnum::iszero_256, opcodeEnum::mul_256}},
    {opcodeEnum::MUL, {opcodeEnum::mul_256}},
    {opcodeEnum::ISZERO, {opcodeEnum::iszero_256}},
    {opcodeEnum::MSTORE,
        {opcodeEnum::memusegas, opcodeEnum::bswap_m256, opcodeEnum::check_overflow}},
    {opcodeEnum::MLOAD,
        {opcodeEnum::memusegas, opcodeEnum::bswap_m256, opcodeEnum::check_overflow}},
    {opcodeEnum::MSTORE8, {opcodeEnum::memusegas, opcodeEnum::check_overflow}},
    {opcodeEnum::CODECOPY, {opcodeEnum::callback, opcodeEnum::memusegas, opcodeEnum::check_overflow,
                               opcodeEnum::memset}},
    {opcodeEnum::CALLDATALOAD,
        {opcodeEnum::bswap_m256, opcodeEnum::bswap_i64, opcodeEnum::check_overflow}},
    {opcodeEnum::CALLDATACOPY,
        {opcodeEnum::memusegas, opcodeEnum::check_overflow, opcodeEnum::memset}},
    {opcodeEnum::CALLVALUE, {opcodeEnum::bswap_m128}},
    {opcodeEnum::EXTCODECOPY, {opcodeEnum::bswap_m160, opcodeEnum::callback, opcodeEnum::memusegas,
                                  opcodeEnum::check_overflow, opcodeEnum::memset}},
    {opcodeEnum::EXTCODESIZE, {opcodeEnum::bswap_m160, opcodeEnum::callback_32}},
    {opcodeEnum::RETURNDATACOPY, {opcodeEnum::memusegas, opcodeEnum::check_overflow, opcodeEnum::memset}},
    {opcodeEnum::LOG, {opcodeEnum::memusegas, opcodeEnum::check_overflow}},
    {opcodeEnum::BLOCKHASH, {opcodeEnum::check_overflow, opcodeEnum::callback_256}},
    {opcodeEnum::SHA3, {opcodeEnum::memusegas, opcodeEnum::bswap_m256, opcodeEnum::check_overflow,
                           opcodeEnum::keccak}},
    {opcodeEnum::CALL,
        {opcodeEnum::bswap_m160, opcodeEnum::bswap_m256, opcodeEnum::memusegas, opcodeEnum::check_overflow_i64,
            opcodeEnum::check_overflow, opcodeEnum::memset, opcodeEnum::callback_32}},
    {opcodeEnum::DELEGATECALL, {opcodeEnum::bswap_m160, opcodeEnum::callback, opcodeEnum::memusegas,
                                   opcodeEnum::check_overflow, opcodeEnum::memset,
                                       opcodeEnum::check_overflow_i64, opcodeEnum::callback_32}},
    {opcodeEnum::CALLCODE,
        {opcodeEnum::bswap_m160, opcodeEnum::bswap_m256, opcodeEnum::callback, opcodeEnum::memusegas,
            opcodeEnum::check_overflow, opcodeEnum::memset, opcodeEnum::callback_32,
                           opcodeEnum::check_overflow_i64}},
    {opcodeEnum::STATICCALL, {opcodeEnum::bswap_m160, opcodeEnum::callback, opcodeEnum::memusegas,
                                   opcodeEnum::check_overflow, opcodeEnum::memset,
                                       opcodeEnum::check_overflow_i64, opcodeEnum::callback_32}},
    {opcodeEnum::CREATE, {opcodeEnum::bswap_m256, opcodeEnum::bswap_m160, opcodeEnum::callback_160,
                             opcodeEnum::memusegas, opcodeEnum::check_overflow}},
    {opcodeEnum::RETURN, {opcodeEnum::memusegas, opcodeEnum::check_overflow}},
    {opcodeEnum::REVERT, {opcodeEnum::memusegas, opcodeEnum::check_overflow}},
    {opcodeEnum::BALANCE, {opcodeEnum::bswap_m160, opcodeEnum::callback_128}},
    {opcodeEnum::SELFDESTRUCT, {opcodeEnum::bswap_m160}},
    {opcodeEnum::SSTORE, {opcodeEnum::bswap_m256, opcodeEnum::callback}},
    {opcodeEnum::SLOAD, {opcodeEnum::bswap_m256, opcodeEnum::callback_256}},
    {opcodeEnum::CODESIZE, {opcodeEnum::callback_32}},
    {opcodeEnum::DIFFICULTY, {opcodeEnum::bswap_m256}},
    {opcodeEnum::COINBASE, {opcodeEnum::bswap_m160}},
    {opcodeEnum::ORIGIN, {opcodeEnum::bswap_m160}},
    {opcodeEnum::ADDRESS, {opcodeEnum::bswap_m160}},
    {opcodeEnum::CALLER, {opcodeEnum::bswap_m160}}};

struct Op
{
    opcodeEnum name;
    int fee;
    int off;
    int on;
    size_t number;
};

struct JumpSegment
{
    size_t number;
    std::string type;
};

struct WastCode
{
    std::string wast;
    std::string imports;
};

std::string wast2wasm(const std::string& input, bool debug = false);
std::string evm2wast(const std::vector<uint8_t>& input, bool tracing = false, bool useAsyncAPI = false, bool inlineOps = true, bool chargePerOp = true);
std::string evmhex2wast(const std::string& input, bool tracing = false);
std::string evm2wasm(const std::vector<uint8_t>& input, bool tracing = false);
std::string evmhex2wasm(const std::string& input, bool tracing = false);

std::string assembleSegments(const std::vector<JumpSegment>& segments);

std::string opcodeToString(opcodeEnum opcode);

Op opcodes(uint8_t op);

size_t findNextJumpDest(const std::vector<uint8_t>& evmCode, size_t i);

std::set<opcodeEnum> resolveFunctionDeps(const std::set<opcodeEnum>& funcSet);

std::tuple<std::vector<std::string>, std::vector<std::string>> resolveFunctions(
    const std::set<opcodeEnum>& funcSet, std::map<opcodeEnum, WastCode> wastFiles);

std::string buildModule(const std::vector<std::string>& funcs,
    const std::vector<std::string>& imports, const std::vector<std::string>& callbacks);

std::string buildJumpMap(const std::vector<JumpSegment>& segments);

}
