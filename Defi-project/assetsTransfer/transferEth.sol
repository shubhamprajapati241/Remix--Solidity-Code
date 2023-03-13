// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract Transfer {

    address payable public owner;

    mapping(address => uint) public lenderBalance;


    constructor()  payable {
        owner = payable(msg.sender);
    }
    
    // function depositEth() external payable {
    // }

    function depositEth() public payable {

        address lender = msg.sender;
        (bool success, ) = address(this).call{value : msg.value}("");
        require(success, "Deposit failed");

        lenderBalance[lender] += msg.value;
    }

    receive() external payable {}

    function transferEth(address payable addr) public payable{ 
        addr.transfer(msg.value);
    }

    // function sendEtherTransfer(address payable _to) public payable {
    //     _to.transfer(msg.value); // this is not recommended
    // }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawEth() public {
        uint amount = address(this).balance;
        (bool success, ) = owner.call{value : amount }("");
        require(success, "Withdraw failed");
    }




}