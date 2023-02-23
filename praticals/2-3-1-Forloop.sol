// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract ForDemo {

    uint[3] public arr; // Creating fixed array

    uint public count; // create count variable => By default value is 0

    function loop() public {
        for(uint i = count; i < arr.length; i++) {
            arr[count] = count;
            count++;
        }
    }
}