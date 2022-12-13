// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract ArrayDemo {

    // 1. Sevaral way to initialize the array
    uint[] public arr2;
    uint[] public arr = [1,2,3,4,5];

    // Fixed size array all the element initialie to 0
    uint[10] public myFiedArray;

    // 2. Getting the specific index value
    function gettingSpecificArrayElement(uint i) public view returns(uint) {
        return arr[i];
    }

    // 3. Returning entire array
    function getArr() public view returns(uint[] memory) {
        return arr;
    }

    // 4. Getting array length
    function getLength() public view returns(uint) {
        return arr.length;
    }

    // 5. Appending to Array
    function pushElement(uint _i) public {
        arr2.push(_i);
    }

    //  6. Removing last element of the array
    function popElement() public {
        arr2.pop();
    }

    
    // 3. Returning entire array
    function getArr2() public view returns(uint[] memory) {
        return arr2;
    }

    // 7. Deleting the specific index element
    function deleteSpecificElement(uint _index) public {
        delete arr2[_index];
        // delete doesn't change the array length
        // It reset the value at index to its dafault value as 0
    }









}



