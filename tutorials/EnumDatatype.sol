// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract EnumDemo {
    
    enum FreshJuice{small, medium, large}
    FreshJuice choice;
    FreshJuice constant defaultChoice = FreshJuice.medium;

    function getChoice() public view returns(FreshJuice) {
        return choice;
    }

    function getDefaultChoice() public pure returns(FreshJuice) {
        return defaultChoice;
    }

    function setLarge() public {
        choice = FreshJuice.large;
    }

    function setSmall() public {
        choice = FreshJuice.small;
    }
}