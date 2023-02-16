// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LendingPoolCore is ReentrancyGuard {

    //* 1. Declaring the Variables
    address public owner;
    uint256 immutable LEND_RATE = 350;
    uint256 immutable BORROW_RATE = 450;

    // asset token => reserve qty in the lending pool
    mapping(address => uint) public reserves;

    // asset exit - to check asset exist in the lending pool or not
    mapping(address => bool) assetInPool;

    // asset address => tokenSymbol
    mapping(address => string) tokenMap;

    using SafeMath for uint;

    // Lender Side
    // user address => asset address
    mapping(address => address) public lenderAssets;
    // user address => asset address => lend asset amount
    mapping(address => mapping(address => uint)) public lenderAssetList;
    // user address => asset address => lend timestamp
    mapping(address => mapping(address => uint)) public lenderTimeStamp;

    // Borrower Side
    // user address => asset address
    mapping(address => address)  borrowerAssets;
    // user address => asset address => borrow asset amount
    mapping(address => mapping(address => uint))  borrowedAssets;
    // user address => asset address => borrow timestamp
    mapping(address => mapping(address => uint))  borrowerTimestamp;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner, cannot perform operation");
        _;
    }

    // modifier onlyActiveReserve(address _token) {
    //     require(reserves[_token] > 0, "No Reserve for Asset");
    //     _;
    // }

    /****************** Lender Functionality **************/

    function lend(address _token, uint256 _amount) public onlyOwner {
        // Add assets in lender
        lenderAssets[msg.sender] = _token;
        lenderAssetList[msg.sender][_token] = _amount;

        // Adding into lending Pool
        reserves[_token] = _amount;
    } 
    









}



// Asset Address:
// ETH : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// USDC : 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
// DAI : 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB

// Lender Address : 

// Lender1 : 0xdD870fA1b7C4700F2BD7f44238821C26f7392148
// Lender2 :  0xdD870fA1b7C4700F2BD7f44238821C26f7392148