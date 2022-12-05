// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.8;

contract PayableDemo {
    address payable public owner; // owner's address
    
    // payable contructor can receive ether
    constructor() payable {  
        owner = payable(msg.sender); // making the deployer of the contract as the owner
    }

    // this function used to send money inside the ss 
    // can receive the ether
    function deposit() public payable {}

    // this function which cannot receive the ether
    function nonPayable() public {}

    // this function can withdraw the ether
    function withdraw() public payable {
        uint amount = address(this).balance; // here (this) points to the current smart contract
        (bool success,) = owner.call{value : amount}("amount withdraw from smart contract");
        require(success, "Failed to receive ehter");
    }

    function transfer(address payable _to, uint _amount) public {
        (bool success,) = _to.call{value : _amount*(10**18)}("Ether transferred");
        require(success, "Failed to send ether to address");
    }

}
