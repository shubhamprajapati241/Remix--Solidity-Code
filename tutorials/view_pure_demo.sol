//SPDX-License-Identifier:MIT
pragma solidity 0.8.7;


contract ViewPure{

    //  view function : state variable => read -> yes, write -> not
    //  Pure function : state variable => read -> not, write -> not

    uint num = 1; // internal

    function addNumber(uint num2) public view returns(uint) {
        return num+num2;
    }

    // pure is used to only deal with the local variable
    function addNumber2(uint i, uint j) public pure returns(uint) {
        return i + j;
    }




}