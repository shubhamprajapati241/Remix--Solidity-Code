// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

contract StringTest2 { 
   
    string public str = "MumbaitoMumbai"; 
   
     enum my_enum { Mumbai_, _to, _Mumbai }

    function Enum() public pure returns( my_enum) { 
        return my_enum._Mumbai; 
    } 
    
    
} 



