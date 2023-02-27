// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Gate.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol"; //Run this test in Foundry with Huff installed

contract MultiSigWalletTest is Test {
    Gate public gate;
    address huffContract;

    address alice = vm.addr(0x01);
    address bob = vm.addr(0x02);
    address marie = vm.addr(0x03);
    address maria = vm.addr(0x04);

    address[] owners = [alice, bob, maria];

    function setUp() public {
        gate = new Gate();
        huffContract = HuffDeployer.deploy("guardian");
    }

    /* OPEN THE GATE */
    function testOpen() public {
        gate.open(huffContract);
        assertEq(gate.opened(), true); // GATE IS OPENED
    }
}
