// SPDX-License-Identifier : MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Percentage{

    using SafeMath for uint;
    uint256 public basePercent = 100;

    function onePercent(uint256 _value) public view returns (uint256)  {
        uint256 roundValue = SafeMath.ceil(_value, basePercent);
        uint256 onePercent = SafeMath.div(SafeMath.mul(roundValue, basePercent), 10000);
        return onePercent;
    }
}