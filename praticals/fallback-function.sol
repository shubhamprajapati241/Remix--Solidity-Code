//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract Fallback {
    event Log(string functionName, address sender, uint value, bytes data);

    fallback() external payable {
        emit Log("Fallback", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Log("Receive", msg.sender, msg.value, "");
    }
}

