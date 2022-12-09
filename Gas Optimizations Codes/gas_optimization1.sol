// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract GasOptmization {

    // uint8 public a;
    // uint8 public b;
    // uint8 public c;

    //transaction cost : 118843     
    //execution cost : 118843     
    //total gas : 136670 

    uint32 public a;
    uint32 public b;
    uint32 public c;

    //transaction cost : 125737    
    //execution cost : 125737    
    //total gas : 144598 

    // uint64 public a;
    // uint64 public b;
    // uint64 public c;

    //transaction cost : 129241   
    //execution cost : 129241   
    //total gas : 148628  

    // uint128 public a;
    // uint128 public b;
    // uint128 public c;

    //transaction cost : 136183  
    //execution cost : 136183  
    //total gas : 156611   


    // uint public a;
    // uint public b;
    // uint public c;

    //transaction cost : 110257 
    //execution cost : 110257 
    // total 126796 

}

