//  SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract FunctionModifier {
    // We will use these variables to demonstrate how to use
    // modifiers.address public owner;
    uint public x = 10;
    address public owner;
    bool public locked;
    
    constructor() {
        // Set the transaction sender as the owner of the 
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
        
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }
    
    function changeOwner(address _newOwner) public onlyOwner validAddress(_newOwner) {
        owner = _newOwner;
    }
    
    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }
    
    function decrement(uint i) public noReentrancy {
        x -= i;
        if (i > 1) {
            decrement(i - 1);
        }
    }
}