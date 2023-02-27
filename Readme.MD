# QuillCFT solution

My Solutions for QuillCTF Challenges

## Gate

Objective of CTF was

1. You need to set the opened flag to true via the open function
2. You need to handwrite the bytecode opcode by opcode and stay within the size of less than 33 bytes

Get Contract code is as below -

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IGuardian {
    function f00000000_bvvvdlt() external view returns (address);

    function f00000001_grffjzz() external view returns (address);
}

contract Gate {
    bool public opened;

    function open(address guardian) external {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(guardian)
        }
        require(codeSize < 33, "bad code size");

        require(
            IGuardian(guardian).f00000000_bvvvdlt() == address(this),
            "invalid pass"
        );
        require(
            IGuardian(guardian).f00000001_grffjzz() == tx.origin,
            "invalid pass"
        );

        (bool success, ) = guardian.call(abi.encodeWithSignature("fail()"));
        require(!success);

        opened = true;
    }
}
```

Basically need to pass three 4 hurdles to open the gate -

1. Code size to be less than 33.
2. Output of the function f00000000_bvvvdlt() of contract must return msg.sender
3. Output of the function f00000001_grffjzz() of contract must return tx.origin
4. Calling unimplemented function "fail" must not be success.

Only if above conditions are fulfilled, gate can be opened.

I used huff to create contract as below -

```solidity
#define macro MAIN() = takes(0) returns (1) {
caller 0x00 mstore // Step 1 - caller is stored in memory at 0x00

    origin 0x20 mstore               // Step 2 - origin is stored in memory at 0x20

    0x20                             // push 0x20 into stack  for number of bytes to be returned later by "return". Stack will look like [0x20]

    0x00 calldataload 0xE0 shr       // push func sel from calldata load into stack. Stack looks like [0x00, 0x20] when
                                     // when f00000000_bvvvdlt() is called becauese abi.encodeWithSignature("f00000000_bvvvdlt()") is 0x00
                                     // and stack looks like [0x01,0x20] when f00000001_grffjzz() is called becauese abi.encodeWithSignature("f00000001_bvvvdlt()") is 0x01

    0x20                             // push 0x20 into stack . Stack will look like [0x20,0x00,0x20] for  f00000000_bvvvdlt() and [0x20,0x01,0x20] for f00000001_grffjzz()

    mul                              // perform a multiplication operation on upper most elements of stack. Stack will look like [0x00,0x20] for  f00000000_bvvvdlt()
                                     // and [0x20,0x20] for f00000001_grffjzz()

    return                           // caller will be returned for [0x00,0x20] see step 1. origin will be returned for [0x20,0x20] see step 2.

                                     // For call to "fail()" i.e 0xa9cc4718, invalid val will be returned,

}
```

code size is less than 33.
