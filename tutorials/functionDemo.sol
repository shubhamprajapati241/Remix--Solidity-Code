// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;


// contract FunctionDemo {

//     function returnMultiple() public pure returns(uint, string memory, bool) {
//         return(1, "Blockchain", true);
//     }

//     function returnNamed() public pure returns(uint x, string memory y, bool z) {
//         return(1, "Blockchain", true);
//     }

//     // function for assigning values 
//     function assigningValues() public pure returns(uint x, string memory y, bool z) {
//         x = 10;
//         y = "Blockchain";
//         z= true;
//         return(x, y, z);
//     } 

//     function destructing() public pure returns(uint, string memory, bool, uint, bool) {
//         (uint i, string memory y, bool z) = returnNamed(); 
//         (uint a, ,bool b) = (10, 20, true);
//         return(i, y, z, a, b);
//     }

// }


contract SecondContract {

    function A(uint i, string memory j , bool k, address l) public pure returns(uint) {
        return(10);
    }

    function callingA() public view returns(uint) {
        return A(10, "Shubham", true, msg.sender);
    }

    function fuctionWithKeyValues() public view returns(uint) {
        
    }


}
