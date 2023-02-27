// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./AggregatorV3Interface.sol";

contract TEST {

     // Aggregator functionality from chainlink
    function getLatestPrice(address _tokenAddress) public view returns (int) {
        AggregatorV3Interface priceFeed;
        priceFeed = AggregatorV3Interface(_tokenAddress);
        (,int price,,,) = priceFeed.latestRoundData();
        return price / 1e8; //1e8 as per 8 decimals in chainlink doc 
    }

    function getAmountInDoller(address _tokenAddress, uint256 _amount) public view returns(int) {
        int256 totalAmountInUSD = int256(getLatestPrice(_tokenAddress)) * int256(_amount);
        return totalAmountInUSD;
    }
}