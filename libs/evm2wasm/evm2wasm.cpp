#include <cmath>

#include <set>
#include <string>
#include <vector>
#include <sstream>

#include <fmt/format.h>

#include <wasm-binary.h>
#include <wasm-s-parser.h>
#include <wasm-validator.h>

#include "evm2wasm.h"
#include "wast-async.h"
#include "wast.h"

using namespace std;

using namespace fmt::literals;

namespace {

bool nibble2value(unsigned input, unsigned& output) {
  if (input >= '0' && input <= '9') {
    output = input - '0';
    return true;
  } else if (input >= 'a' && input <= 'f') {
    output = input - 'a' + 10;
    return true;
  } else if (input >= 'A' && input <= 'F') {
    output = input - 'A' + 10;
    return true;
  }
  return false;
}

// Hand rolled hex parser, because cross platform error handling is
// more reliable than with strtol() and any of the built std function.
//
// Returns an empty vector if input is invalid (odd number of characters or invalid nibbles).
// Assumes input is whitespace free, therefore if input is non-zero long an empty output
// signals an error.
vector<uint8_t> hexstring2vector(const string& input) {
  size_t len = input.length();
  if (len % 2 != 0)
    return vector<uint8_t>{};
  vector<uint8_t> ret;
  for (size_t i = 0; i <= len - 2; i += 2) {
    unsigned lo, hi;
    if (!nibble2value(unsigned(input[i]), hi) || !nibble2value(unsigned(input[i + 1]), lo))
      return vector<uint8_t>{};
    ret.push_back(static_cast<uint8_t>((hi << 4) | lo));
  }
  return ret;
}

}

namespace evm2wasm {

string wast2wasm(const string& input, bool debug) {
  wasm::Module module;

  try {
    if (debug) std::cerr << "s-parsing..." << std::endl;
    // FIXME: binaryen 1.37.28 actually modifies the input...
    //        as a workaround make a copy here
    string tmp = input;
    wasm::SExpressionParser parser(const_cast<char*>(tmp.c_str()));
    wasm::Element& root = *parser.root;
    if (debug) std::cerr << "w-parsing..." << std::endl;
    wasm::SExpressionWasmBuilder builder(module, *root[0]);
  } catch (wasm::ParseException& p) {
    if (debug) {
      std::cerr << "error in parsing input" << std::endl;
      p.dump(std::cerr);
    }
    return string();
  }

  if (!wasm::WasmValidator().validate(module)) {
    if (debug) std::cerr << "module is invalid" << std::endl;
    return string();
  }

  if (debug) std::cerr << "binarification..." << std::endl;
  wasm::BufferWithRandomAccess buffer(debug);
  wasm::WasmBinaryWriter writer(&module, buffer, debug);
  writer.setNamesSection(false);
  writer.write();

  if (debug) std::cerr << "writing to output..." << std::endl;

  ostringstream output;
  buffer.writeTo(output);

  if (debug) std::cerr << "Done." << std::endl;
  
  return output.str();
}

string evm2wast(const vector<uint8_t>& evmCode, bool stackTrace, bool useAsyncAPI, bool inlineOps, bool chargePerOp)
{
    // this keep track of the opcode we have found so far. This will be used to
    // to figure out what .wast files to include
    std::set<opcodeEnum> opcodesUsed;
    std::set<opcodeEnum> ignoredOps = {opcodeEnum::JUMP, opcodeEnum::JUMPI, opcodeEnum::JUMPDEST,
        opcodeEnum::POP, opcodeEnum::STOP, opcodeEnum::INVALID};
    std::vector<std::string> callbackTable;

    // an array of found segments
    std::vector<JumpSegment> jumpSegments;

    // the transcompiled EVM code
    fmt::MemoryWriter wast;
    fmt::MemoryWriter segment;
    //
    // keeps track of the gas that each section uses
    int gasCount = 0;

    // used for pruning dead code
    bool jumpFound = false;

    // the accumulative stack difference for the current segment
    int segmentStackDelta = 0;
    int segmentStackHigh = 0;
    int segmentStackLow = 0;

    // adds stack height checks to the beginning of a segment
    auto addStackCheck = [&segment, &segmentStackHigh, &segmentStackLow, &segmentStackDelta]() {
        fmt::MemoryWriter check;
        if (segmentStackHigh != 0)
        {
            check << "(if (i32.gt_s (get_global $sp) (i32.const {check}))\n\
                        (then (unreachable)))"_format("check"_a = ((1023 - segmentStackHigh) * 32));
        }

        if (segmentStackLow != 0)
        {
            check << "(if (i32.lt_s (get_global $sp) (i32.const {check}))\n\
                        (then (unreachable)))"_format("check"_a = (-segmentStackLow * 32 - 32));
        }

        check << segment.str();
        segment = std::move(check);
        segmentStackHigh = 0;
        segmentStackLow = 0;
        segmentStackDelta = 0;
    };

    // add a metering statment at the beginning of a segment
    auto addMetering = [&segment, &wast, &gasCount, &chargePerOp]() {
        if (!chargePerOp) {
            if (gasCount != 0)
                wast << "(call $useGas (i64.const {gasCount}))"_format("gasCount"_a = gasCount);
        }
        wast << segment.str();
        segment.clear();
        gasCount = 0;
    };

    // finishes off a segment
    auto endSegment = [&segment, &addStackCheck, &addMetering]() {
        segment << ")";
        addStackCheck();
        addMetering();
    };

    for (size_t pc = 0; pc < evmCode.size(); pc++)
    {
        uint8_t opint = evmCode[pc];
        auto op = opcodes(opint);

        // creates a stack trace
        if (stackTrace)
        {
            segment << "(call $stackTrace (i32.const {pc}) (i32.const {opint}) \
                        (i32.const {gasCount}) (get_global $sp))\n"_format(
                "pc"_a = pc, "opint"_a = opint, "gasCount"_a = op.fee);
        }

        if (chargePerOp) {
            if (op.fee != 0)
                segment << "(call $useGas (i64.const {fee}))"_format("fee"_a = op.fee);
        }

        // do not charge gas for interface methods
        // TODO: implement proper gas charging and enable this here
        if (opint < 0x30 || (opint > 0x45 && opint < 0xa0)) {
            gasCount += op.fee;
        }

        segmentStackDelta += op.on;
        if (segmentStackDelta > segmentStackHigh)
        {
            segmentStackHigh = segmentStackDelta;
        }

        segmentStackDelta -= op.off;
        if (segmentStackDelta < segmentStackLow)
        {
            segmentStackLow = segmentStackDelta;
        }

        switch (op.name)
        {
        case opcodeEnum::JUMP:
            jumpFound = true;
            segment << "\
                ;; jump\n\
                   (set_local $jump_dest (call $check_overflow \n\
                                          (i64.load (get_global $sp))\n\
                                          (i64.load (i32.add (get_global $sp) (i32.const 8)))\n\
                                          (i64.load (i32.add (get_global $sp) (i32.const 16)))\n\
                                          (i64.load (i32.add (get_global $sp) (i32.const 24)))))\n\
                   (set_global $sp (i32.sub (get_global $sp) (i32.const 32)))\n\
                       (br $loop)";
            opcodesUsed.insert(opcodeEnum::check_overflow);
            pc = findNextJumpDest(evmCode, pc);
            break;
        case opcodeEnum::JUMPI:
            jumpFound = true;
            segment << "set_local $jump_dest (call $check_overflow \n\
                          (i64.load (get_global $sp))\n\
                          (i64.load (i32.add (get_global $sp) (i32.const 8)))\n\
                          (i64.load (i32.add (get_global $sp) (i32.const 16)))\n\
                          (i64.load (i32.add (get_global $sp) (i32.const 24)))))\n\n\
                         (set_global $sp (i32.sub (get_global $sp) (i32.const 64)))\n\
                         (br_if $loop (i32.eqz (i64.eqz (i64.or\n\
                           (i64.load (i32.add (get_global $sp) (i32.const 32)))\n\
                           (i64.or\n\
                             (i64.load (i32.add (get_global $sp) (i32.const 40)))\n\
                             (i64.or\n\
                               (i64.load (i32.add (get_global $sp) (i32.const 48)))\n\
                               (i64.load (i32.add (get_global $sp) (i32.const 56)))\n\
                             )\
                           )\
                        ))))\n";
            opcodesUsed.insert(opcodeEnum::check_overflow);
            addStackCheck();
            addMetering();
            break;
        case opcodeEnum::JUMPDEST:
            endSegment();
            jumpSegments.push_back({.number = pc, .type = "jump_dest"});
            gasCount = 1;
            break;
        case opcodeEnum::GAS:
            segment << "(call $GAS)\n";
            //addMetering(); // this causes an unreachable error in stackOverflowM1 -d 14
            break;
        case opcodeEnum::LOG:
            segment << "(call $LOG (i32.const " << op.number << "))\n";
            break;
        case opcodeEnum::DUP:
        case opcodeEnum::SWAP:
            // adds the number on the stack to SWAP
            segment << "(call ${opname} (i32.const {opnumber}))\n"_format(
                "opname"_a = opcodeToString(op.name), "opnumber"_a = (op.number - 1));
            break;
        case opcodeEnum::PC:
            segment << "(call $PC (i32.const {pc}))\n"_format("pc"_a = pc);
            break;
        case opcodeEnum::PUSH:
        {
            pc++;
            size_t sliceSize = std::min(op.number, 32ul);
            auto begin = evmCode.begin() + static_cast<ptrdiff_t>(pc);
            std::vector<uint8_t> bytes(begin, begin + static_cast<ptrdiff_t>(sliceSize));

            pc += op.number;
            if (op.number < 32)
            {
                bytes.insert(bytes.begin(), 32 - op.number, 0);
            }

            // op.number is an 8bit number, casting to ptrdiff_t should be safe here
            ptrdiff_t bytesRounded = ptrdiff_t(ceil(double(op.number) / 8.0));
            fmt::MemoryWriter push;
            ptrdiff_t q = 0;

            // pad the remaining of the word with 0
            for (; q < 4 - bytesRounded; q++)
            {
                fmt::MemoryWriter pad;
                pad << "(i64.const 0)";
                pad << push.str();
                push = std::move(pad);
            }

            for (; q < 4; q++)
            {
                //TODO clean this disgusting mess up

                std::reverse(bytes.begin() + q * 8, bytes.begin() + q * 8 + 8);

                int64_t int64 = 0;
                memcpy(&int64, &bytes[static_cast<size_t>(q * 8)], sizeof(int64));

                push << "(i64.const {int64})"_format("int64"_a = int64);
            }

            segment << fmt::format("(call $PUSH {push})", "push"_a = push.str());
            pc--;
            break;
        }
        case opcodeEnum::POP:
            // do nothing
            break;
        case opcodeEnum::STOP:
            segment << "(br $done)";
            if (jumpFound)
            {
                pc = findNextJumpDest(evmCode, pc);
            }
            else
            {
                // the rest is dead code;
                pc = evmCode.size();
            }
            break;
        case opcodeEnum::SELFDESTRUCT:
        case opcodeEnum::RETURN:
        case opcodeEnum::REVERT:
            segment << "(call $" << opcodeToString(op.name) << ") (br $done)\n";
            if (jumpFound)
            {
                pc = findNextJumpDest(evmCode, pc);
            }
            else
            {
                // the rest is dead code
                pc = evmCode.size();
            }
            break;
        case opcodeEnum::INVALID:
            segment.clear();
            segment << "(unreachable)";
            pc = findNextJumpDest(evmCode, pc);
            break;

        default:
            if (useAsyncAPI && callbackFuncs.find(op.name) != callbackFuncs.end())
            {
                std::string cbFunc = (*callbackFuncs.find(op.name)).second;
                auto result = std::find(std::begin(callbackTable), std::end(callbackTable), cbFunc);
                size_t index;
                if (result == std::end(callbackTable))
                {
                    callbackTable.push_back(cbFunc);
                    index = callbackFuncs.size();
                }
                else
                {
                    index = static_cast<size_t>(std::distance(callbackTable.begin(), result));
                }
                segment << "(call ${opname} (i32.const {index}))\n"_format("opname"_a = opcodeToString(op.name), "index"_a = index);
            }
            else
            {
                // use synchronous API
                segment << "(call ${opname})\n"_format("opname"_a = opcodeToString(op.name));
            }
            break;
        }

        if (ignoredOps.find(op.name) == std::end(ignoredOps))
        {
            opcodesUsed.insert(op.name);
        }

        auto stackDelta = op.on - op.off;
        // update the stack pointer
        if (stackDelta != 0)
        {
            segment << "(set_global $sp (i32.add (get_global $sp) (i32.const {stackDelta})))\n"_format(
                "stackDelta"_a = stackDelta * 32);
        }

        // adds the logic to save the stack pointer before exiting to wiat to for a callback
        // note, this must be done before the sp is updated above^
        if (useAsyncAPI && callbackFuncs.find(op.name) != std::end(callbackFuncs))
        {
            segment << "(set_global $cb_dest (i32.const {jumpSegmentsLength})) \
                            (br $done))"_format("jumpSegmentsLength"_a = jumpSegments.size() + 1);
            jumpSegments.push_back({.number = 0, .type = "cb_dest"});
        }
    }

    endSegment();

    std::string wastStr = wast.str();
    wast.clear();
    wast << assembleSegments(jumpSegments) << wastStr << "))";

    auto wastFiles = wastSyncInterface;  // default to synchronous interface
    if (useAsyncAPI)
    {
        wastFiles = wastAsyncInterface;
    }

    std::vector<std::string> imports;
    std::vector<std::string> funcs;
    // inline EVM opcode implemention
    if (inlineOps)
    {
        std::tie(funcs, imports) = resolveFunctions(opcodesUsed, wastFiles);
    }

    // import stack trace function
    if (stackTrace)
    {
        imports.push_back("(import \"debug\" \"printMemHex\" (func $printMem (param i32 i32)))");
        imports.push_back("(import \"debug\" \"print\" (func $print (param i32)))");
        imports.push_back(
            "(import \"debug\" \"evmTrace\" (func $stackTrace (param i32 i32 i32 i32)))");
    }
    imports.push_back("(import \"ethereum\" \"useGas\" (func $useGas (param i64)))");

    wastStr = wast.str();
    funcs.push_back(wastStr);
    wastStr = buildModule(funcs, imports, callbackTable);
    return wastStr;
}

string evmhex2wast(const string& input, bool tracing) {
  vector<uint8_t> tmp = hexstring2vector(input);
  if ((input.length() / 2) != tmp.size())
    return string{};
  return evm2wast(tmp, tracing);
}

string evm2wasm(const vector<uint8_t>& input, bool tracing) {
  return wast2wasm(evm2wast(input, tracing));
}

string evmhex2wasm(const string& input, bool tracing) {
  vector<uint8_t> tmp = hexstring2vector(input);
  if ((input.length() / 2) != tmp.size())
    return string{};
  return evm2wasm(tmp, tracing);
}

// given an array for segments builds a wasm module from those segments
// @param {Array} segments
// @return {String}
std::string assembleSegments(const std::vector<JumpSegment>& segments)
{
    auto wasm = buildJumpMap(segments);

    for (size_t index = 0; index < segments.size(); ++index)
    {
        wasm = "(block ${index} {wasm}"_format("index"_a = index + 1, "wasm"_a = wasm);
    }

    std::string result =
        "\
  (func $main\
    (export \"main\")\
    (local $jump_dest i32) (local $jump_map_switch i32)\
    (set_local $jump_dest (i32.const -1))\
\
    (block $done\
      (loop $loop\
        {wasm}"_format("wasm"_a = wasm);
    return result;
}

std::string opcodeToString(opcodeEnum opcode)
{
    switch (opcode)
    {
    case opcodeEnum::STOP:
        return "STOP";
    case opcodeEnum::ADD:
        return "ADD";
    case opcodeEnum::MUL:
        return "MUL";
    case opcodeEnum::SUB:
        return "SUB";
    case opcodeEnum::DIV:
        return "DIV";
    case opcodeEnum::SDIV:
        return "SDIV";
    case opcodeEnum::MOD:
        return "MOD";
    case opcodeEnum::SMOD:
        return "SMOD";
    case opcodeEnum::ADDMOD:
        return "ADDMOD";
    case opcodeEnum::MULMOD:
        return "MULMOD";
    case opcodeEnum::EXP:
        return "EXP";
    case opcodeEnum::SIGNEXTEND:
        return "SIGNEXTEND";
    case opcodeEnum::LT:
        return "LT";
    case opcodeEnum::GT:
        return "GT";
    case opcodeEnum::SLT:
        return "SLT";
    case opcodeEnum::SGT:
        return "SGT";
    case opcodeEnum::EQ:
        return "EQ";
    case opcodeEnum::ISZERO:
        return "ISZERO";
    case opcodeEnum::AND:
        return "AND";
    case opcodeEnum::OR:
        return "OR";
    case opcodeEnum::XOR:
        return "XOR";
    case opcodeEnum::NOT:
        return "NOT";
    case opcodeEnum::BYTE:
        return "BYTE";
    case opcodeEnum::SHA3:
        return "SHA3";
    case opcodeEnum::ADDRESS:
        return "ADDRESS";
    case opcodeEnum::BALANCE:
        return "BALANCE";
    case opcodeEnum::ORIGIN:
        return "ORIGIN";
    case opcodeEnum::CALLER:
        return "CALLER";
    case opcodeEnum::CALLVALUE:
        return "CALLVALUE";
    case opcodeEnum::CALLDATALOAD:
        return "CALLDATALOAD";
    case opcodeEnum::CALLDATASIZE:
        return "CALLDATASIZE";
    case opcodeEnum::CALLDATACOPY:
        return "CALLDATACOPY";
    case opcodeEnum::CODESIZE:
        return "CODESIZE";
    case opcodeEnum::CODECOPY:
        return "CODECOPY";
    case opcodeEnum::GASPRICE:
        return "GASPRICE";
    case opcodeEnum::EXTCODESIZE:
        return "EXTCODESIZE";
    case opcodeEnum::EXTCODECOPY:
        return "EXTCODECOPY";
    case opcodeEnum::BLOCKHASH:
        return "BLOCKHASH";
    case opcodeEnum::COINBASE:
        return "COINBASE";
    case opcodeEnum::TIMESTAMP:
        return "TIMESTAMP";
    case opcodeEnum::NUMBER:
        return "NUMBER";
    case opcodeEnum::DIFFICULTY:
        return "DIFFICULTY";
    case opcodeEnum::GASLIMIT:
        return "GASLIMIT";
    case opcodeEnum::POP:
        return "POP";
    case opcodeEnum::MLOAD:
        return "MLOAD";
    case opcodeEnum::MSTORE:
        return "MSTORE";
    case opcodeEnum::MSTORE8:
        return "MSTORE8";
    case opcodeEnum::SLOAD:
        return "SLOAD";
    case opcodeEnum::SSTORE:
        return "SSTORE";
    case opcodeEnum::JUMP:
        return "JUMP";
    case opcodeEnum::JUMPI:
        return "JUMPI";
    case opcodeEnum::PC:
        return "PC";
    case opcodeEnum::MSIZE:
        return "MSIZE";
    case opcodeEnum::GAS:
        return "GAS";
    case opcodeEnum::JUMPDEST:
        return "JUMPDEST";
    case opcodeEnum::PUSH:
        return "PUSH";
    case opcodeEnum::DUP:
        return "DUP";
    case opcodeEnum::SWAP:
        return "SWAP";
    case opcodeEnum::LOG:
        return "LOG";
    case opcodeEnum::CREATE:
        return "CREATE";
    case opcodeEnum::CALL:
        return "CALL";
    case opcodeEnum::CALLCODE:
        return "CALLCODE";
    case opcodeEnum::RETURN:
        return "RETURN";
    case opcodeEnum::DELEGATECALL:
        return "DELEGATECALL";
    case opcodeEnum::SELFDESTRUCT:
        return "SELFDESTRUCT";
    default:
        abort();
    }
}

Op opcodes(uint8_t op)
{
    auto result = codes.find(op);
    std::tuple<opcodeEnum, int, int, int> code;
    if (result == std::end(codes))
    {
        code = std::make_tuple(opcodeEnum::INVALID, 0, 0, 0);
    }
    else
    {
        code = (*result).second;
    };
    auto opcode = std::get<0>(code);
    size_t number;

    switch (opcode)
    {
    case opcodeEnum::LOG:
        number = static_cast<size_t>(op - 0xa0);
        break;

    case opcodeEnum::PUSH:
        number = static_cast<size_t>(op - 0x5f);
        break;

    case opcodeEnum::DUP:
        number = static_cast<size_t>(op - 0x7f);
        break;

    case opcodeEnum::SWAP:
        number = static_cast<size_t>(op - 0x8f);
        break;

    default:
        number = 0;
        break;
    }

    return {opcode, std::get<1>(code), std::get<2>(code), std::get<3>(code), number};
}

// returns the index of the next jump destination opcode in given EVM code in an
// array and a starting index
// @param {Array} evmCode
// @param {Integer} index
// @return {Integer}
size_t findNextJumpDest(const std::vector<uint8_t>& evmCode, size_t i)
{
    for (; i < evmCode.size(); i++)
    {
        auto opint = evmCode[i];
        auto op = opcodes(opint);
        switch (op.name)
        {
        case opcodeEnum::PUSH:
            // skip add how many bytes where pushed
            i += op.number;
            break;
        case opcodeEnum::JUMPDEST:
            return --i;
        default:
            break;
        }
    }
    return --i;
}

// Ensure that dependencies are only imported once (use the Set)
// @param {Set} funcSet a set of wasm function that need to be linked to their dependencies
// @return {Set}
std::set<opcodeEnum> resolveFunctionDeps(const std::set<opcodeEnum>& funcSet)
{
    std::set<opcodeEnum> funcs = funcSet;
    for (auto&& func : funcs)
    {
        auto deps = depMap.find(func);
        if (deps != depMap.end())
        {
            for (auto&& dep : (*deps).second)
            {
                funcs.insert(dep);
            }
        }
    }
    return funcs;
}

/**
 * given a Set of wasm function this return an array for wasm equivalents
 * @param {Set} funcSet
 * @return {Array}
 */
std::tuple<std::vector<std::string>, std::vector<std::string>> resolveFunctions(
    const std::set<opcodeEnum>& funcSet, std::map<opcodeEnum, WastCode> wastFiles)
{
    std::vector<std::string> funcs;
    std::vector<std::string> imports;
    for (auto&& func : resolveFunctionDeps(funcSet))
    {
        funcs.push_back(wastFiles[func].wast);
        imports.push_back(wastFiles[func].imports);
    }
    return std::tuple<std::vector<std::string>, std::vector<std::string>>{funcs, imports};
}

/**
 * builds a wasm module
 * @param {Array} funcs the function to include in the module
 * @param {Array} imports the imports for the module's import table
 * @return {string}
 */
std::string buildModule(const std::vector<std::string>& funcs,
    const std::vector<std::string>& imports, const std::vector<std::string>& callbacks)
{
    fmt::MemoryWriter funcBuf;
    for (auto&& func : funcs)
    {
        funcBuf << func;
    }

    fmt::MemoryWriter callbackTableBuf;
    if (callbacks.size() > 0)
    {
        fmt::MemoryWriter callbacksBuf;
        callbacksBuf.write(callbacks[0]);
        for (size_t i = 1; i < callbacks.size(); ++i)
        {
            callbacksBuf << " " << callbacks[i];
        }
        callbackTableBuf << "\
    (table\n\
      (export \"callback\") ;; name of table\n\
        anyfunc\n\
        (elem {callbacksStr}) ;; elements will have indexes in order\n\
      )"_format("callbacksStr"_a = callbacksBuf.str());
    }

    fmt::MemoryWriter importsBuf;
    if (imports.size() > 0)
    {
        importsBuf << imports[0];
        for (size_t i = 1; i < imports.size(); ++i)
        {
            importsBuf << "\n" << imports[i];
        }
    }

    return "\
(module\n\
  {importsStr}\n\
  (global $cb_dest (mut i32) (i32.const 0))\n\
  (global $sp (mut i32) (i32.const -32))\n\
  (global $init (mut i32) (i32.const 0))\n\
\n\
  ;; memory related global\n\
  (global $memstart i32  (i32.const 33832))\n\
  ;; the number of 256 words stored in memory\n\
  (global $wordCount (mut i64) (i64.const 0))\n\
  ;; what was charged for the last memory allocation\n\
  (global $prevMemCost (mut i64) (i64.const 0))\n\
\n\
  ;; TODO: memory should only be 1, but can\'t resize right now\n\
  (memory 500)\n\
  (export \"memory\" (memory 0))\n\
\n\
  {callbackTableStr}\n\
\n\
  {funcStr}\n\
)"_format("importsStr"_a = importsBuf.str(), "callbackTableStr"_a = callbackTableBuf.str(),
        "funcStr"_a = funcBuf.str());
}

// Builds the Jump map, which maps EVM jump location to a block label
// @param {Array} segments
// @return {String}
std::string buildJumpMap(const std::vector<JumpSegment>& segments)
{
    fmt::MemoryWriter wasmBuf;
    wasmBuf << "(unreachable)";

    fmt::MemoryWriter brTableBuf;
    for (size_t index = 0; index < segments.size(); ++index)
    {
        auto&& seg = segments[index];
        brTableBuf << " $" << (index + 1);
        if (seg.type == "jump_dest")
        {
            std::string wasmStr = wasmBuf.str();
            wasmBuf.clear();
            wasmBuf << "(if (i32.eq (get_local $jump_dest) (i32.const {segnumber}))\
                (then (br {index}))\
                (else {wasm}))"_format(
                "segnumber"_a = seg.number, "index"_a = index + 1, "wasm"_a = wasmBuf.str());
        }
    }

    std::string wasmStr = wasmBuf.str();
    wasmBuf.clear();
    wasmBuf << "\
  (block $0\n\
    (if\n\
      (i32.eqz (get_global $init))\n\
      (then\n\
        (set_global $init (i32.const 1))\n\
        (br $0))\n\
      (else\n\
        ;; the callback dest can never be in the first block\n\
        (if (i32.eq (get_global $cb_dest) (i32.const 0)) \n\
          (then\n\
            {wasm}\n\
          )\n\
          (else \n\
            ;; return callback destination and zero out $cb_dest \n\
            (set_local $jump_map_switch (get_global $cb_dest)) \n\
            (set_global $cb_dest (i32.const 0))\n\
            (br_table $0 {brTable} (get_local $jump_map_switch))\n\
          )))))"_format("wasm"_a = wasmStr, "brTable"_a = brTableBuf.str());

    return wasmBuf.str();
}
};
