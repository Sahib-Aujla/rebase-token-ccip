//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {Vault} from "../src/Vault.sol";

contract CrossChain is Test {
    address owner = makeAddr("owner");
    uint256 sepoliaFork;
    uint256 arbSepoliaFork;

    CCIPLocalSimulatorFork ccipLocalSimulatorFork;

    RebaseToken sepoliaRebaseToken;
    RebaseToken arbSepoliaRebaseToken;
    Vault vault;

    function setup() external {
        sepoliaFork = vm.createSelectFork("eth");
        arbSepoliaFork = vm.createFork("arb");

        ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        vm.makePersistent(address(ccipLocalSimulatorFork));

        vm.startPrank(owner);
        sepoliaRebaseToken = new RebaseToken();
        vault = new Vault(address(sepoliaRebaseToken));
        vm.stopPrank();

        vm.selectFork(arbSepoliaFork);
        vm.startPrank(owner);
        arbSepoliaRebaseToken = new RebaseToken();
        vm.stopPrank();
    }
}
