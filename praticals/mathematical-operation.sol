//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract MathematicalOperation {
    function Operation() public pure returns(uint aMod, uint mMod) {
        uint256 x = 3;

        aMod = addmod(++x, ++x, x);
        mMod = mulmod(++x, ++x, x);

    }
}