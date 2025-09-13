// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

contract Vault {
    error Vault__RedeemTransferFailed();

    event Deposit(address to, uint256 amount);
    event Redeem(address from, uint256 amount);

    IRebaseToken private immutable i_rebaseToken;

    constructor(address rebaseTokenAddress) {
        i_rebaseToken = IRebaseToken(rebaseTokenAddress);
    }

    function deposit() external payable {
        i_rebaseToken.mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    receive() external payable {}

    function redeem(uint256 amount) external {
        if (amount == type(uint256).max) {
            amount = i_rebaseToken.balanceOf(msg.sender);
        }
        i_rebaseToken.burn(msg.sender, amount);
        emit Redeem(msg.sender, amount);
        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert Vault__RedeemTransferFailed();
        }
    }
}
