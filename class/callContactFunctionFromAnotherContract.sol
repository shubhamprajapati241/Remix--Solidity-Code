// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

// How to call functionality of one calling into another contract


// SC1 
contract contractA {
    event callEvent(address sender, address origin, address from);
    function callThis() public {
        emit callEvent(msg.sender, tx.origin, address(this));
        // address(this) : the address the smart contract
    }
}

//SC2
contract Caller {
    function makeCallsContractA(address _contractAddress) public {
        address(_contractAddress).call(abi.encodeWithSignature("callThis()"));
    }
}

// EOA  - SC1 - SC2

// **** Calling from ContactA
// "sender": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", // EOA account address
// "origin": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", // transaction origin = EOA account address
// "from": "0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8" // contract address

// **** Calling from Contact Caller
// "sender": "0xd9145CCE52D386f254917e481eB44e9943F39138", //SC2 contract address
// "origin": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",// transaction origin = EOA account address
// "from": "0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8" // contract address

