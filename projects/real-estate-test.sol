// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


// Real estate
// 1. seller -> list properties
// 2. Admin approve -> 
// to get only apporve properties

contract RealEstate {

    struct Property {
        string name;
        uint amount;
        string location;
        bool isApproved;
    }

    address public owner;
    // mapping(uint => Property) properties;

    Property[] properties;

    constructor() {
        owner = msg.sender;
    }

    function list(string calldata name, uint amount, string calldata location) external {
        properties.push(Property(name, amount, location, false));
    }

    function approve(uint id) external {
        require(properties[id].isApproved == false, "Already approved");
        require(owner == msg.sender);
        properties[id].isApproved = true;
    }

    function getProperties(uint id) external view returns(Property memory){
        return properties[id];
    }

    function getApprovedProperties() external view returns(Property[] memory) {
        uint propertiesLength = properties.length;

        uint totalApprovedCount;
        for(uint i=0; i < propertiesLength; i++) {
            if(properties[i].isApproved == true) {
                totalApprovedCount++;
            }
        }    
    }
}


