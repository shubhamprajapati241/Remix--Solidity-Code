// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


// Mappings are useful for associations, like associating a unique Ethereum address to a specific balance


contract MappingDemo {
    //  mapping of address to int

    // mapping is a user defined data structure 
    mapping(address => uint) public myMap; 

    function getter(address _addr) public view returns(uint) {
        return myMap[_addr]; // It gives the value on the specified key
    }

    function setter(address _addr, uint _i) public {
        myMap[_addr] = _i;
    }

    // function mapSize() public view returns(uint) {
    //     return myMap.length;
    // } 


    //  How to return the complete map

    // how to iterate on the map

    //  how to delete data from map

    function deleteKey(address _addr) public {
        delete myMap[_addr];
    }

    function iteration() public {

        for(uint i=0; i < 2; i++) {
            
        }
    }
 }
