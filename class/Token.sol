// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract Token {
    string public name=  "Block Token";
    string public symbol = "BT";
    uint public totalSupply = 1000;
    address public owner;
    mapping (address => uint) balance;

    constructor() {
        owner = msg.sender;
        balance[owner] = 1000;
    }

    function transfer(address _to, uint _amount) external {
        // require()
        balance[msg.sender] -= _amount;
        balance[_to] += _amount; 
    }

    function getBalance(address _to) external view returns(uint) {
        return balance[_to];
    }

    

}