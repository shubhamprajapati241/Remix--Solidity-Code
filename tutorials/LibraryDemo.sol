// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// Deleting the element at the particular index in an array

library RemoveIndex{
    // libraries don't use state variable
    function remove(uint[] storage arr, uint index) public {
        require(arr.length > 0, "Cant remove from empty array");
        arr[index] = arr[arr.length-1];
        arr.pop();
    }

    function checkValue() public {

    }

}

contract arrDemo {
    uint[] public arr;
    using RemoveIndex for uint[]; // importing the library

    function TestArrayRemoval() public returns(uint[] memory){
        for(uint i =0; i < 4; i++) {
            arr.push(i);
        }
        arr.remove(1); // using library function
        return arr;
    }



}



