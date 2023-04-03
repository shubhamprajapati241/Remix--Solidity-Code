//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract local {
    uint age  = 10;

    function getter() public view returns(uint) {
        return age;
    }
    
    function setter() public {
        age = age + 1;
    }
}