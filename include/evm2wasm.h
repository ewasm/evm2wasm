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
    SELFDESTRUCT,
    INVALID,
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

static std::map<int, std::tuple<opcodeEnum, int, int, int>> codes = {
    {0x00, {opcodeEnum::STOP, 0, 0, 0}},
    {0x01, {opcodeEnum::ADD, 3, 2, 1}},
    {0x02, {opcodeEnum::MUL, 5, 2, 1}},
    {0x03, {opcodeEnum::SUB, 3, 2, 1}},
    {0x04, {opcodeEnum::DIV, 5, 2, 1}},
    {0x05, {opcodeEnum::SDIV, 5, 2, 1}},
    {0x06, {opcodeEnum::MOD, 5, 2, 1}},
    {0x07, {opcodeEnum::SMOD, 5, 2, 1}},
    {0x08, {opcodeEnum::ADDMOD, 8, 3, 1}},
    {0x09, {opcodeEnum::MULMOD, 8, 3, 1}},
    {0x0a, {opcodeEnum::EXP, 10, 2, 1}},
    {0x0b, {opcodeEnum::SIGNEXTEND, 5, 2, 1}},

    // 0x10 range - bit ops
    {0x10, {opcodeEnum::LT, 3, 2, 1}},
    {0x11, {opcodeEnum::GT, 3, 2, 1}},
    {0x12, {opcodeEnum::SLT, 3, 2, 1}},
    {0x13, {opcodeEnum::SGT, 3, 2, 1}},
    {0x14, {opcodeEnum::EQ, 3, 2, 1}},
    {0x15, {opcodeEnum::ISZERO, 3, 1, 1}},
    {0x16, {opcodeEnum::AND, 3, 2, 1}},
    {0x17, {opcodeEnum::OR, 3, 2, 1}},
    {0x18, {opcodeEnum::XOR, 3, 2, 1}},
    {0x19, {opcodeEnum::NOT, 3, 1, 1}},
    {0x1a, {opcodeEnum::BYTE, 3, 2, 1}},

    // 0x20 range - crypto
    {0x20, {opcodeEnum::SHA3, 30, 2, 1}},

    // 0x30 range - closure state
    {0x30, {opcodeEnum::ADDRESS, 0, 0, 1}},
    {0x31, {opcodeEnum::BALANCE, 0, 1, 1}},
    {0x32, {opcodeEnum::ORIGIN, 0, 0, 1}},
    {0x33, {opcodeEnum::CALLER, 0, 0, 1}},
    {0x34, {opcodeEnum::CALLVALUE, 0, 0, 1}},
    {0x35, {opcodeEnum::CALLDATALOAD, 0, 1, 1}},
    {0x36, {opcodeEnum::CALLDATASIZE, 0, 0, 1}},
    {0x37, {opcodeEnum::CALLDATACOPY, 0, 3, 0}},
    {0x38, {opcodeEnum::CODESIZE, 0, 0, 1}},
    {0x39, {opcodeEnum::CODECOPY, 0, 3, 0}},
    {0x3a, {opcodeEnum::GASPRICE, 0, 0, 1}},
    {0x3b, {opcodeEnum::EXTCODESIZE, 0, 1, 1}},
    {0x3c, {opcodeEnum::EXTCODECOPY, 0, 4, 0}},

    // "0x40" range - block operations
    {0x40, {opcodeEnum::BLOCKHASH, 0, 1, 1}},
    {0x41, {opcodeEnum::COINBASE, 0, 0, 1}},
    {0x42, {opcodeEnum::TIMESTAMP, 0, 0, 1}},
    {0x43, {opcodeEnum::NUMBER, 0, 0, 1}},
    {0x44, {opcodeEnum::DIFFICULTY, 0, 0, 1}},
    {0x45, {opcodeEnum::GASLIMIT, 0, 0, 1}},

    // 0x50 range - "storage" and execution
    {0x50, {opcodeEnum::POP, 2, 1, 0}},
    {0x51, {opcodeEnum::MLOAD, 3, 1, 1}},
    {0x52, {opcodeEnum::MSTORE, 3, 2, 0}},
    {0x53, {opcodeEnum::MSTORE8, 3, 2, 0}},
    {0x54, {opcodeEnum::SLOAD, 0, 1, 1}},
    {0x55, {opcodeEnum::SSTORE, 0, 2, 0}},
    {0x56, {opcodeEnum::JUMP, 8, 0, 0}},
    {0x57, {opcodeEnum::JUMPI, 10, 0, 0}},
    {0x58, {opcodeEnum::PC, 2, 0, 1}},
    {0x59, {opcodeEnum::MSIZE, 2, 0, 1}},
    {0x5a, {opcodeEnum::GAS, 0, 0, 1}},
    {0x5b, {opcodeEnum::JUMPDEST, 0, 0, 0}},

    // 0x60, range
    {0x60, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x61, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x62, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x63, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x64, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x65, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x66, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x67, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x68, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x69, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x6a, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x6b, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x6c, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x6d, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x6e, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x6f, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x70, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x71, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x72, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x73, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x74, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x75, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x76, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x77, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x78, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x79, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x7a, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x7b, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x7c, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x7d, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x7e, {opcodeEnum::PUSH, 3, 0, 1}},
    {0x7f, {opcodeEnum::PUSH, 3, 0, 1}},

    {0x80, {opcodeEnum::DUP, 3, 0, 1}},
    {0x81, {opcodeEnum::DUP, 3, 0, 1}},
    {0x82, {opcodeEnum::DUP, 3, 0, 1}},
    {0x83, {opcodeEnum::DUP, 3, 0, 1}},
    {0x84, {opcodeEnum::DUP, 3, 0, 1}},
    {0x85, {opcodeEnum::DUP, 3, 0, 1}},
    {0x86, {opcodeEnum::DUP, 3, 0, 1}},
    {0x87, {opcodeEnum::DUP, 3, 0, 1}},
    {0x88, {opcodeEnum::DUP, 3, 0, 1}},
    {0x89, {opcodeEnum::DUP, 3, 0, 1}},
    {0x8a, {opcodeEnum::DUP, 3, 0, 1}},
    {0x8b, {opcodeEnum::DUP, 3, 0, 1}},
    {0x8c, {opcodeEnum::DUP, 3, 0, 1}},
    {0x8d, {opcodeEnum::DUP, 3, 0, 1}},
    {0x8e, {opcodeEnum::DUP, 3, 0, 1}},
    {0x8f, {opcodeEnum::DUP, 3, 0, 1}},

    {0x90, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x91, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x92, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x93, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x94, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x95, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x96, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x97, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x98, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x99, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x9a, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x9b, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x9c, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x9d, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x9e, {opcodeEnum::SWAP, 3, 0, 0}},
    {0x9f, {opcodeEnum::SWAP, 3, 0, 0}},

    {0xa0, {opcodeEnum::LOG, 0, 2, 0}},
    {0xa1, {opcodeEnum::LOG, 0, 3, 0}},
    {0xa2, {opcodeEnum::LOG, 0, 4, 0}},
    {0xa3, {opcodeEnum::LOG, 0, 5, 0}},
    {0xa4, {opcodeEnum::LOG, 0, 6, 0}},

    // "0xf0" range - closures
    {0xf0, {opcodeEnum::CREATE, 0, 3, 1}},
    {0xf1, {opcodeEnum::CALL, 0, 7, 1}},
    {0xf2, {opcodeEnum::CALLCODE, 0, 7, 1}},
    {0xf3, {opcodeEnum::RETURN, 0, 2, 0}},
    {0xf4, {opcodeEnum::DELEGATECALL, 0, 6, 1}},

    // "0x70", range - other
    {0xff, {opcodeEnum::SELFDESTRUCT, 0, 1, 0}}};

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
    {opcodeEnum::ADDMOD, {opcodeEnum::MOD, opcodeEnum::ADD, opcodeEnum::mod_320}},
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
    {opcodeEnum::EXTCODECOPY, {opcodeEnum::bswap_m256, opcodeEnum::callback, opcodeEnum::memusegas,
                                  opcodeEnum::check_overflow, opcodeEnum::memset}},
    {opcodeEnum::EXTCODESIZE, {opcodeEnum::callback_32, opcodeEnum::bswap_m256}},
    {opcodeEnum::LOG, {opcodeEnum::memusegas, opcodeEnum::check_overflow}},
    {opcodeEnum::BLOCKHASH, {opcodeEnum::check_overflow, opcodeEnum::callback_256}},
    {opcodeEnum::SHA3, {opcodeEnum::memusegas, opcodeEnum::bswap_m256, opcodeEnum::check_overflow,
                           opcodeEnum::keccak}},
    {opcodeEnum::CALL,
        {opcodeEnum::bswap_m256, opcodeEnum::memusegas, opcodeEnum::check_overflow_i64,
            opcodeEnum::check_overflow, opcodeEnum::memset, opcodeEnum::callback_32}},
    {opcodeEnum::DELEGATECALL, {opcodeEnum::callback, opcodeEnum::memusegas,
                                   opcodeEnum::check_overflow, opcodeEnum::memset}},
    {opcodeEnum::CALLCODE,
        {opcodeEnum::bswap_m256, opcodeEnum::callback, opcodeEnum::memusegas,
            opcodeEnum::check_overflow, opcodeEnum::memset, opcodeEnum::callback_32,
                           opcodeEnum::check_overflow_i64}},
    {opcodeEnum::CREATE, {opcodeEnum::bswap_m256, opcodeEnum::bswap_m160, opcodeEnum::callback_160,
                             opcodeEnum::memusegas, opcodeEnum::check_overflow}},
    {opcodeEnum::RETURN, {opcodeEnum::memusegas, opcodeEnum::check_overflow}},
    {opcodeEnum::BALANCE, {opcodeEnum::bswap_m256, opcodeEnum::callback_128}},
    {opcodeEnum::SELFDESTRUCT, {opcodeEnum::bswap_m256}},
    {opcodeEnum::SSTORE, {opcodeEnum::bswap_m256, opcodeEnum::callback}},
    {opcodeEnum::SLOAD, {opcodeEnum::callback_256}},
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
std::string evm2wast(const std::vector<uint8_t>& input, bool tracing = false, bool useAsyncAPI = false, bool inlineOps = true);
std::string evmhex2wast(const std::string& input, bool tracing = false);
std::string evm2wasm(const std::vector<uint8_t>& input, bool tracing = false);
std::string evmhex2wasm(const std::string& input, bool tracing = false);

std::string assembleSegments(const std::vector<JumpSegment>& segments);

std::string opcodeToString(opcodeEnum opcode);

Op opcodes(int op);

size_t findNextJumpDest(const std::string& evmCode, size_t i);

std::set<opcodeEnum> resolveFunctionDeps(const std::set<opcodeEnum>& funcSet);

std::tuple<std::vector<std::string>, std::vector<std::string>> resolveFunctions(
    const std::set<opcodeEnum>& funcSet, std::map<opcodeEnum, WastCode> wastFiles);

std::string buildModule(const std::vector<std::string>& funcs,
    const std::vector<std::string>& imports, const std::vector<std::string>& callbacks);

std::string buildJumpMap(const std::vector<JumpSegment>& segments);

}
