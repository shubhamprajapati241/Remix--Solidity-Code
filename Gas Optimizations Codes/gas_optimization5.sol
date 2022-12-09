// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

contract Test {

    // function not_optimized() public pure {
    //     uint a = 10;
    //     uint b = 10;
    //     uint c = a + b;
    //     require(c== 20, "C must be 20");
    //     c = 100;
    // }

    // // 21444 

    // function optimized() public pure {
    //     uint a = 10;
    //     uint b = 10;
    //     uint c = a + b;
    //     require(c== 20);
    //     c = 100;
    // }

    // // 21466  


    function callingPublic() public {
        uint a = 10;
        uint b = 20;
    }

    // 21212 

    // 24420 

    function callingExternal() external {
        uint a = 10;
        uint b = 20;
    }

    // 24394 
    // 21234 
}

