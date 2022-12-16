// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract Demo {

    uint[] data;

    function loop() public returns(uint[] memory) {
        for(uint i=0; i< 10; i++) {
            data.push(i);
        }

        return data;
    } 
}