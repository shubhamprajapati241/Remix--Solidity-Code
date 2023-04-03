//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract PureDemo {
    function f(uint a, uint b) public pure returns(uint) {
        return a * (b + 42);
    }
}

contract ViewDemo {
    uint age = 10;
    function getter() public view returns(uint) {
        return age;
    }
}