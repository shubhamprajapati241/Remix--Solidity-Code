// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

// C2 Cold access vs warm access (70 saved gas)
contract GasOptmization2 {

    uint256 a = 100;

    function not_optimized() external {
        uint b = a;
        uint c = a;
    }

   // Gas Total : 26924  

    // function optimized() external {
    //     uint temp = a;
    //     uint b = temp;
    //     uint c = temp;
    // }

    // Gas Total : 26824  



}