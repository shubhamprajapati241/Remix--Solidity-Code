// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


contract CallFunction {
    string public str = "Blockchain";

    // If 1 ether is send in msg.value, then update the string
    function updateString(string memory _string ) public payable returns(uint, uint) {
        uint startGas1 = gasleft();
        require(msg.value == 1 ether);
        str = _string;
        address payable owner = payable(msg.sender);
        (bool success, ) = owner.call{value : msg.value}("");
        require(success, "failure");
        return(startGas1, startGas1-gasleft()); // 6000 gas write function definition taking
 
        // "0": "uint256: 20317",
	    // "1": "uint256: 14613"
    }


    
}

// 42386 - 20317 = 22069 base gas to have a transaction on the ethereum blockchain


