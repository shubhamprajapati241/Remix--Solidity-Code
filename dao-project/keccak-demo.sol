// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract Test {
    bytes32 public immutable CONTRIBUTOR_ROLE = keccak256("CONTRIBUTOR");
    bytes32 public immutable STAKEHOLDER_ROLE = keccak256("STAKEHOLDER");

    function hello() public view returns(bytes32) {
        return CONTRIBUTOR_ROLE;
    }

     function hello2() public view returns(bytes32) {
        return STAKEHOLDER_ROLE;
    }
}