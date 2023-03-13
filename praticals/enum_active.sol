// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

contract TEST {

    enum AssetStatus { ACTIVE, INACTIVE }


    function isAciveOption(AssetStatus _option) public view returns(bool) {

        if(_option == AssetStatus.ACTIVE) {
            return true;
        }

        return false;
    }

    

}