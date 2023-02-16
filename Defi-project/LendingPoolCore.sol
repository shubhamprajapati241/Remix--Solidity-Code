// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LendingPoolCore is ReentrancyGuard {

    address deployer;
    uint256 public interestRate=350;
    uint256 public borrowRate=450;

    // asset token => reserve qty
    mapping (address => uint) public reserves;
    // asset exits - to check if an asset exists in the reserve Pool
    mapping (address => bool) public assetInPool;
    // user address => asset token address
    mapping(address => address) public lenderAssetList;
    // user address => asset token address => lent asset qty
    mapping(address => mapping(address => uint)) public lenderAssets;
    // user address => asset token address => borrowed asset qty
    mapping(address => mapping(address => uint)) public borrowedAssets;
    // user address => addresss of token lent => lent timestamp
    mapping(address => mapping(address => uint)) public lenderTimestamp;
    // user address => addresss of token borrowed => borrwed timestamp
    mapping(address => mapping(address => uint)) public borrowerTimestamp;
    // Token address => tokensymbol
    mapping(address => string) tokenMap;

    using SafeMath for uint;

    constructor() {
        deployer = msg.sender;
    }
    

    // Declaring Modifier 
    modifier onlyOwner() {
        require(msg.sender == deployer, "Not owner, cannot perform operation");
        _;
    }

    /*
    * @dev : This function must only be called by the owner to update the interst Rate
    * @param _amount : Interest Rate in Basis Points, so divide it by 100
    */
    function updateInterestRate(uint _interestRate) external onlyOwner{
        // If interest rate is 3.5, pass 350, it will be converted to 3.5
        interestRate = _interestRate;
    }

    /*
    * @dev : This function must only be called by the owner to update the borrow fee
    * @param _borrowFee : upadate borrowRate 
    */
    function updateBorrowFee(uint _borrowRate) external onlyOwner{
        // The fee levied when someone borrows, pass 100, it will be converted to 1%
            borrowRate = _borrowRate;
    }
    

} 