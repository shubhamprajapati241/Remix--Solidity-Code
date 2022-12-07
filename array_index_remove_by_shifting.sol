// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

contract ArrayIndexRemoveByShifting {
    uint[] public arr = [1];
    function remove(uint _index) public {

        // Checking empty array
        require(arr.length > 0, "Array can't be empty");

        // Checking wrong index
        require(_index <= (arr.length - 1), "Invalid Index");

        // After the index => iterating the index and switching the index value
        for(uint i= _index; i < arr.length -1 ; i++) {
            arr[i] = arr[i+1];
        }

        // Remove the last element
        arr.pop();
    }

    function getArr() public view returns(uint[] memory) {
        return arr;
    }
}