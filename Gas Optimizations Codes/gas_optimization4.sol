// SPDX-License-Identifer: MIT

pragma solidity ^0.8.15;

// C9: Exchanging 2 variables by using a tuple (a, b) = (b, a) (saves 5 gas on every call)
contract GasOptmization4 {

    // function not_optimized() public pure {
    //     uint i = 10;
    //     uint j = 20;
    //     (i, j) = (j , i);
    // }
    // Gas Total : 21238  

    function optimized() public pure {
        uint i = 10;
        uint j = 20;
        uint temp = i;
        i = j;
        j = i;
    }
    // Gas Total : 21241  
}