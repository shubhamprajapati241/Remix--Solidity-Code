//SPDX-License-Identifier:MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {
    constructor() ERC20("Reward","RT"){
        _mint(msg.sender,1000000*10**18);
    }
}



//  DAI - 0xBa8DCeD3512925e52FE67b1b5329187589072A55
//  owner : 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// spender : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// person 3 : 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db


// Shubham 5000 => Sashi 2000 allowance

// Sashi => user3 1000 => allowance 1000 => Shubham 4000 transferFrom

// SC => chain // metamask => connect with chain to EOA user

// SC => transfer from => deloy Metamask 

//  Your call in our hold