// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";
import {Vault} from "../src/Vault.sol";

contract DeployVault is Script {
    function run(address rebaseToken) external returns (Vault vault) {
        vm.startBroadcast();
        vault = new Vault(rebaseToken);
        IRebaseToken(rebaseToken).grantMintAndBurnRole(address(vault));
        vm.stopBroadcast();
    }
}
