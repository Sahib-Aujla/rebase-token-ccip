// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzepplin/token/ERC20/ERC20.sol";
import {Ownable} from "@openzepplin/access/Ownable.sol";
import {AccessControl} from "@openzepplin/access/AccessControl.sol";

contract RebaseToken is ERC20, Ownable, AccessControl {
    /////////////////////
    // Errors ///////////
    ////////////////////
    error RebaseToken__NewInterestCanOnlyBeLower();

    ///////////////////////////
    // Events ////////////////
    //////////////////////////
    event InerestRateChange(uint256 oldInterestRate, uint256 newInterestRate);

    ///////////////////////////
    // Variables //////////////
    //////////////////////////

    uint256 private constant PRECISION = 1e18;
    bytes32 public constant MINTER_BURNER_ROLE = keccak256("MINTER_BURNER_ROLE");

    uint256 private s_interestRate;
    mapping(address user => uint256 interestRate) private s_interestRates;
    mapping(address user => uint256 timestamp) private s_userLastUpdatedTimestamp;

    constructor() ERC20("Rebase Token", "RBT") {
        s_interestRate = 5e10;
    }

    function grantRoleMintAndBurn(address account) external onlyOwner {
        _grantRole(MINTER_BURNER_ROLE, account);
    }

    function changeInterestRate(uint256 newInterestRate) external onlyOwner {
        if (newInterestRate >= s_interestRate) {
            revert RebaseToken__NewInterestCanOnlyBeLower();
        }
        emit InerestRateChange(s_interestRate, newInterestRate);
        s_interestRate = newInterestRate;
    }

    function mint(address _to, uint256 _amount) external onlyRole(MINTER_BURNER_ROLE) {
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

    function burn(address _from, uint256 _amount) external onlyRole(MINTER_BURNER_ROLE) {
        if (_amount == type(uint256).max) {
            _amount = balanceOf(_from);
        }
        _mintAccruedInterest(_from);
        _burn(_from, _amount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _mintAccruedInterest(msg.sender);
        _mintAccruedInterest(to);
        if (amount == type(uint256).max) {
            amount = balanceOf(msg.sender);
        }
        if (balanceOf(to) == 0) {
            s_interestRates[to] = s_interestRates[msg.sender];
        }
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _mintAccruedInterest(from);
        _mintAccruedInterest(to);
        if (amount == type(uint256).max) {
            amount = balanceOf(from);
        }
        if (balanceOf(to) == 0) {
            s_interestRates[to] = s_interestRates[from];
        }
        return super.transferFrom(from, to, amount);
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

    ///////////////////////////////
    // Getter functions ///////////
    ///////////////////////////////
    function getUserInterestRate(address _account) external view returns (uint256) {
        return s_interestRates[_account];
    }

    function getInterestRate() external view returns (uint256) {
        return s_interestRate;
    }

    function principalBalanceOf(address account) external view returns (uint256) {
        return super.balanceOf(account);
    }
}
