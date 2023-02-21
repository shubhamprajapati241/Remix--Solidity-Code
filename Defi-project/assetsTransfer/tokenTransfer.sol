// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";


contract TokenTransfer {
    IERC20 _token;
    address public tokenAddress;


    // token = MyToken's contract address
    constructor(address token) {
        _token = IERC20(token);
        tokenAddress = token;
    }

    // Modifier to check token allowance
    modifier checkAllowance(uint amount) {
        require(_token.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }

    // // In your case, Account A must to call this function and then deposit an amount of tokens 
    // function depositTokens(uint _amount) public checkAllowance(_amount) {
    //     _token.approve(address(this), _amount);
    //     _token.transferFrom(msg.sender, address(this), _amount);
    // }

    
    // to = Account B's address
    function stake(address to, uint amount) public {
        _token.transfer(to, amount);
    }

    // Allow you to show how many tokens owns this smart contract
    function getSmartContractBalance() external view returns(uint) {
        return _token.balanceOf(address(this));
    }

    // Allow you to show how many tokens owns this smart contract
    function getSmartContractBalanceSC() external view returns(uint) {
        return _token.balanceOf(msg.sender);
    }
}


// DAI 0xBa8DCeD3512925e52FE67b1b5329187589072A55
//  USDC : 0x65aFADD39029741B3b8f0756952C74678c9cEC93

//  Account 2 : 0x021edEFA528293eB8ad9A2d9e0d71011f6297601