// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract GlobalVar {
    // Defining a state variable
    address public owner; // To store the address of owner of smart contract

    // creating a constructor
    constructor() {
        owner = msg.sender; // Assigning msg.sender value to the owner
    }

}


//  Local Variable
// creating the contract
contract VarTest {

    function getResult() public pure returns(uint) {
        // initializing local variable
        uint local_var1 = 1;
        uint local_var2 = 2;
        uint result = local_var1 + local_var2;
        return result; // returning the local variable
    }
}




// State variables

// Creating a contract
contract Solidity_var_Test {

    // Declaring a state variable
    uint8 public state_var;      
  
    // Defining a constructor
    constructor()  {
        state_var = 16;   
    }
}


