// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.8;

contract CallSendTransfer {

    function sendEtherTransfer(address payable _to) public payable {
        _to.transfer(msg.value); // this is not recommended
    }

    function sendEtherSend(address payable _to) public payable {
        bool sent = _to.send(msg.value); 
        require(sent, "Failed to send ether");
    }

    function sendEtherCall(address payable _to) public payable {
        (bool success, ) = _to.call{gas : 10000, value: msg.value}("");
        require(success, "Failed to send ether");
    }
}   