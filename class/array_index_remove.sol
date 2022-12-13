// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ArrayIndexRemove {
    
    uint[] public arr = [1,2,3,4,5];

    function removeIndex(uint _index) public {
        // Checking not empty array
        require(arr.length > 0, "Array can't be empty !");
        require(_index < (arr.length - 1), "Invalid Index");
        arr[_index] = arr[arr.length-1];
        arr.pop();
    }

    function getArr() public view returns(uint[] memory) {
        return arr;
    }


}
