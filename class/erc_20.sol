// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ICO is ERC20,Ownable{

    constructor() ERC20("IneuronCoin","INC"){
        _mint(msg.sender,1000000*(10**uint256(decimals()))); // mint new tokens = 100000 tokens with decimals
    }

    // // the the mint owner can add more supplies (values)
    // // adding onlyOwner modifier so that only owner of the sc can mint the token

    // function mint(address account,uint256 amount) public onlyOwner returns(bool){
    //     require(account !=address(this) && amount != uint256(0), "ERC20: function mint invalid input");
    //     _mint(account,amount);
    //     return true;
    // }
    
    // // the the burn owner can remove supplies (values)
    // // adding onlyOwner modifier so that only owner of the sc can burn the token
    // function burn(address account,uint256 amount) public onlyOwner returns(bool){
    //     require(account !=address(this) && amount != uint256(0), "ERC20: function burn invalid input");
    //     _burn(account,amount);
    //      return true;
    // }

   
    // function buy() public payable returns (bool) {
    //   require(msg.sender.balance >= msg.value && msg.value != 0 ether, "ICO: function buy invalid input");
    //   uint256 amount = msg.value * 1000;
    //   _transfer(owner(), _msgSender(), amount);
    //   return true;
    // }

    // function withdraw(uint256 amount) public onlyOwner returns (bool) {
    //   require(amount <= address(this).balance, "ICO: function withdraw invalid input");
    //   payable(_msgSender()).transfer(amount);
    //   return true;
    // }
}


//  out contract -. ERC 20 -> context


//  owner : 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// spender : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// person 3 : 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db


contract ICO2 is ERC20{

    constructor() ERC20("IneuronCoin","INC"){
        _mint(msg.sender,1000000*(10**uint256(decimals()))); // mint new tokens = 100000 tokens with decimals
    }

}