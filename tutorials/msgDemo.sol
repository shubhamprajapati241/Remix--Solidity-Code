// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract MsgDemo {
    address public senderAddress;
    uint public senderBalance;

    function setAddress() public {
        senderAddress = msg.sender;
        senderBalance = msg.sender.balance;
    }

    function transfer(address payable _to) public payable {
        require(senderBalance >= msg.value, "Insuficeint Balance");
        _to.transfer(msg.value);
    }
}