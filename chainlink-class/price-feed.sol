// SPDX-License-Identifier:MIT

pragma solidity 0.8.6;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ChainlinkPriceOracle {
    AggregatorV3Interface internal pricefeed;

    constructor() {
        pricefeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e); // adding proxy contract address
   
    }

    function getLatestPriceFeed() public view returns(int) {
        (uint80 roundId, int price, uint startedAt, uint timestamp, uint80 answerInRound) = pricefeed.latestRoundData();
        
        return price / 1e18;
    }   
}