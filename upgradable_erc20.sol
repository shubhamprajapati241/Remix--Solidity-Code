// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface ERC20Interface {
    function totalSupply() external view returns (uint); 
    // function balanceOf(address tokenOwner) external view returns (uint balance); 
    // function transfer(address to, uint tokens) external returns (bool success);
    // function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    // function approve(address spender, uint tokens) external returns (bool success);
    // function transferFrom(address from, address to, uint tokens) external returns (bool success);
    // event Transfer(address indexed from, address indexed to, uint tokens);
    // event Approval(address indexed tokenOwner, address indexed spender, uint tokens); 
}


contract TokenV1 is ERC20Interface {

    string public name= "DAI Token";
    string public symbol = "DAI";
    uint public decimal = 18;
    uint public override totalSupply;
    uint public intializerCount;
    address public owner;

    mapping (address => uint) public balances;
    mapping(address => mapping(address=> uint)) public allowance;

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can perform this operation");
        _;
    }

    function initializer(uint _amount) public {
        require(intializerCount < 1, "Already initialized");
        owner = msg.sender;
        totalSupply = _amount;
        balances[owner] = _amount;
        intializerCount ++;
    }

   
}