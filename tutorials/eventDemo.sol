// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract EventDemo {
    // event help us to log the msg on blockchain
    event Log(address indexed sender, string message);
    event Event2();

    function testEventWorking() public {
         emit Log(msg.sender, "Blockchain is awesome");
         emit Log(msg.sender, "User created successfully !");

         emit Event2();
    }
}