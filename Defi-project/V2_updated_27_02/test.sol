// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

contract TEST {

    uint public MIN_BORROW_TIMSTRAMP = 30 days;
    function getUpatedTimestrmp() public view returns(uint) {
        uint256 time = block.timestamp + MIN_BORROW_TIMSTRAMP;
        return time;
    }
}