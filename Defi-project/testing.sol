//SPDX-License-Identifier:MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Testing {
    using SafeMath for uint;
    uint public a = 1;

    function decreament() public returns(uint){
        // a = a.sub(1);
        a--;
        return a;
    }
}