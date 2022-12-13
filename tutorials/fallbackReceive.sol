// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.8;

contract FallbackReceive {

    string public called = "";
    uint public amount = 0;
    bytes public data;

    // receive function is only used to receive the amount 
    // or ether from the other contacts into the contact
    receive() external payable {
        called = "Received";
        amount = msg.value;  // value is the amount transfered when this function is called
    }

    // fallback can be use as the backup plan for the receive function 
    // With fallback we can send data with some ether 
    fallback() external payable {
        called = "fallback";
        data = msg.data;
        amount = msg.value;
    }

}