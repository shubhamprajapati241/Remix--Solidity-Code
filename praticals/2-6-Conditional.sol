// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;
contract SolidityTest{

	// Defining function to demonstrate conditional operator
	function sub(uint a, uint b) public view returns(uint){
        uint result = (a > b? a-b : b-a);
        return result;
    }
}
