// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract WhileDemo {

    uint[3] public arr; // Creating fixed array

    uint public count; // create count variable => By default value is 0

    function loop() public {
       
        while(count < arr.length) {
            arr[count] = count;
            count++;
        }
    }

}