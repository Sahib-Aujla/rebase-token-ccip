// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzepplin/token/ERC20/ERC20.sol";

contract RebaseToken is ERC20 {
    uint256 private s_interestRate;

    constructor() ERC20("Rebase Token", "RBT") {
        s_interestRate = 5e10;
    }

    function mint(address _to,uint256 _amount)external{

        _mint(_to,_amount);
    }
}
