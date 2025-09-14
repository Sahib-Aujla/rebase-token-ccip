//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

contract CrossChain is Test {
    uint256 sepoliaFork;
    uint256 arbSepoliaFork;

    function setup() external {
        sepoliaFork = vm.createSelectFork("eth");
        arbSepoliaFork = vm.createFork("arb");
    }
}
