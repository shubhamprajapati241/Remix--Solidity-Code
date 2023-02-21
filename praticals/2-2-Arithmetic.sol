// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SolidityTest {

    //* Initializing variables
    uint a = 20;
    uint b = 10;

    //* Initializing a variable with sum
    uint public sum = a + b;

    //* Initializing a variable with the difference
    uint public diff = a - b;

    //* Initializing a variable with product
    uint public mul = a * b;

    //* Initializing a variable with quotient
    uint public div = a / b;

    //* Initializing a variable with modulus
    uint public mod = a % b;

    //* Initializing a variable with decrement value
    uint public dec = --b;
    
    //* Initializing a variable with increment value
    uint public inc = ++a;
}