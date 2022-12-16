//SPDX-License-Identifier:MIT
pragma solidity 0.8.8;

contract IFElseDemo {

    function condition(uint x) public pure returns(uint) {
        if(x > 10) {
            return 0;
        }else if(x < 10) {
            return 1;
        }else {
            return 2;
        }
    }


   

    function condition3(int x) public pure returns(uint) {
        if(x < 0)  return 5; 
            if(x >= 0 && x <= 10) return 1;
            else if(x >= 11 && x <= 20) return 2;
            else if(x >= 21 && x <= 30) return 3;
        else return 4;
    }
}