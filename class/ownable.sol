//SPDX-License-Identifier:MIT
pragma solidity 0.8.8;
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyContract is Ownable {

    function normalFunction() external pure returns(string memory) {
        return("anyone can access");
    }

    function specialFunction() external view onlyOwner returns(string memory) {
        return("owner can access ");
    }

}