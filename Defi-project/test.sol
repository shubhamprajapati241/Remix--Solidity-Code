// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

contract TEST {
    
    uint256 immutable INTEREST_RATE=3; // interest rate
    // uint256 public immutable borrowRate=450;
    uint constant SECONDS_IN_A_YEAR = 86400 * 365; // time

    mapping(address => mapping(address => uint)) public lenderAssets;
    // lenderAddress => tokenAddress => time
    mapping(address => mapping(address => uint)) public lenderTimestamp;

    function rewardTokensEarned() public view returns(uint256){
        // return lenderAssets[lender][_token] * (((block.timestamp-lenderTimestamp[lender][_token]) * INTEREST_RATE * 12)/SECONDS_IN_A_YEAR * 100);
        // return (((block.timestamp-lenderTimestamp[lender][_token]) * INTEREST_RATE * 12)/SECONDS_IN_A_YEAR * 100);
        
        return 500 * (((1699623927 - 1676623927) * INTEREST_RATE * 12) / SECONDS_IN_A_YEAR * 100);
    }  

}


// Asset Address:

// ETH : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 - 10 ETH
// USDC : 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
// DAI : 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB

// Lender Address : 

// Lender1 : 0x583031D1113aD414F02576BD6afaBfb302140225
// Lender2 :  0xdD870fA1b7C4700F2BD7f44238821C26f7392148
