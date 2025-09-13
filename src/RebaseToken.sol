// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzepplin/token/ERC20/ERC20.sol";

contract RebaseToken is ERC20 {
    uint256 private constant PRECISION = 1e18;

    uint256 private s_interestRate;
    mapping(address user => uint256 interestRate) private s_interestRates;
    mapping(address user => uint256 timestamp) private s_userLastUpdatedTimestamp;

    constructor() ERC20("Rebase Token", "RBT") {
        s_interestRate = 5e10;
    }

    function mint(address _to, uint256 _amount) external {
        //calculate interest and mint the outstanding tokens to the user
        _mintAccruedInterest(_to);
        s_interestRates[_to] = s_interestRate;
        _mint(_to, _amount);
    }

    function balanceOf(address to) public view override returns (uint256) {
        uint256 currentBalance = super.balanceOf(to);
        if (currentBalance == 0) {
            return 0;
        }

        return (currentBalance * _calculateAccruedInterest(to)) / PRECISION;
    }

    //////////////////////////////////
    // Internal functions ////////////
    /////////////////////////////////
    function _mintAccruedInterest(address to) internal {
        //calculate the balance of function
        uint256 principalBalance = super.balanceOf(to);

        uint256 currentBalance = balanceOf(to);

        uint256 tokensToMint = principalBalance - currentBalance;
        _mint(to, tokensToMint);
        s_userLastUpdatedTimestamp[to] = block.timestamp;
    }

    function _calculateAccruedInterest(address to) internal view returns (uint256) {
        uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimestamp[to];

        return (s_interestRates[to] * timeElapsed) + PRECISION;
    }
}
