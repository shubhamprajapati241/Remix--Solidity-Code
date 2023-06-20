// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/* REAL ESTATE CONTRACT - buying and selling p
functionlities
-  listing() 
-  buying()

*/ 

contract RealEstate {
    struct Property {
        address currentOwner;
        address prevOwner;
        string name;
        string location;
        string description;
        uint256 amount;
        bool isSold;
    }

    mapping(uint256 => Property) public properties;
    uint256[] propertyIDs;
    mapping(address => uint) balance;

    function listProperty(uint256 _propertyID, string calldata _name, string calldata _location, string calldata _description, uint256 _amount) external {
        properties[_propertyID] = Property({
            currentOwner : msg.sender,
            prevOwner : address(0),
            name : _name,
            location : _location,
            description : _description,
            amount : _amount,
            isSold : false
        });
        propertyIDs.push(_propertyID);
    }

    function buyProperty(uint256 _propertyID) external payable {
        Property storage thisProperty = properties[_propertyID];
        require(!thisProperty.isSold, "Property is sold");
        require(msg.value == thisProperty.amount, "Amount should be equal to property amount");

        thisProperty.isSold = true;
        thisProperty.prevOwner = thisProperty.currentOwner;
        thisProperty.currentOwner = msg.sender;
        balance[thisProperty.currentOwner] = msg.value;

        (bool success, ) = address(this).call{value : msg.value}("");
        require(success, "Transaction failed");
    }

    receive() external payable {}

    function withdraw() external {
        uint256 withdrawableAount = balance[msg.sender];
        require(address(this).balance >= withdrawableAount, "Amount not available");

        (bool success,) = payable(msg.sender).call{value : withdrawableAount}("");
        require(success, "Tx failed");
    }
 }