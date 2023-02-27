//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";


contract APIConsumer is ChainlinkClient, ConfirmedOwner{
    using Chainlink for Chainlink.Request;

    uint256 public volume;
    bytes32 private jobId;
    uint256 private fee;

    event RequestVolume(bytes32 indexed requestId,uint256 volume);

    constructor() ConfirmedOwner(msg.sender){
        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b462478);
        setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
        jobId="ca98366cc7314957b8c012c72f05aeeb";
        fee = (1* LINK_DIVISIBILITY) / 10; // 1**10**18
    }

    // create a chainlink request to retreive API responce, find the target data
    function requestData() public returns(bytes32 requestId) {

        // making the GET request
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId, 
            address(this),
            this.fulfill.selector
        );

        // adding API link - https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD
        req.add(
            "get", // request method name
            "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD" // api request
        );

        // set 

        /*  sample response format
        {
            "RAW" : 
            {
                "ETH" : 
                {
                    "USD" : 
                    {
                        "VOLUMN24HOUR" : ......
                    }
                }
            }
        }
        */

        req.add("path", "RAW,ETH,USD,VOLUMN24HOUR"); // RAW,ETH,USD,VOLUMN24HOUR => details of which what we want
        uint256 timesAmount = 10**18;
        req.addInt("times". timesAmount);
        return sendChainlinkRequest(req, fee);
    }


    // receive the response in the uint256 format
    function fulfill( bytes _requestID, uint25 _volumn) public recordChainlinkFulfillment(_requestID) {
        emit RequestVolume(_requestID, _volumn);
        volume = _volumn;
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.tranfer(msg.sender, lik.balanceOf(address(this))), "Unable to transfer tokens"); // transfer for the chainlink link token
    }

}