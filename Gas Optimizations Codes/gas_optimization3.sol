// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// C6 use i++ instead of i = i+1 (62 gas saved on each call)
contract GasOptmization3 {

    function not_optimized() public pure {
        uint i = 10;
        i = i + 1;
    }

    // Gas Total : 21395     
  
    // function optimized() public pure {
    //     uint i = 10;
    //     i++;
    // } 
    // Gas Total : 21338     
   
}