// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract IndianRupeesToken is ERC20 {

    // constructor will initialize the smart contract

    // Here with ERC20("Indian Rupees", "INRT") we also providing the value for the parent sc ERC
    constructor(uint256 initialSupply) ERC20("Indian Rupees", "INRT") {
        
        // _mint is used to create new tokens 
        _mint(msg.sender, initialSupply);

        // here we give sc deployer as the owner. 
        // msg.sender => balance = initialSupply
    }
}


