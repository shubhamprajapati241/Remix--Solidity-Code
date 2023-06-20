// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Crowdfunding {
    uint256 public constant LISTING_FEES = 1 ether;
    struct Campaign {
        address creator;
        uint256 goal;
        uint256 pledgeAmount;
        uint256 startAt;
        uint256 endAt;
        bool claimed;
    }

    uint256 public count;
    // for campaign id => campaign
    mapping(uint256 => Campaign) public campaigns;

    // for campaignId => senderAddress => amount
    mapping(uint256=>mapping(address=>uint256)) public pledgeAmount;

    // Declare events here...
    event Lunch(uint256 indexed count, address indexed creator, uint256 indexed goal, uint256 startAt, uint256 endAt);
    event Delete(uint256 indexed count, address indexed creator);

    // Declare functions here...
    function lunch() external payable {
        require(msg.value == LISTING_FEES, "Please pay 1 ether to list");
        count += 1;
        campaigns[count] = Campaign({
            creator : msg.sender,
            goal : 2 ether,
            pledgeAmount : 0,
            startAt : block.timestamp,
            endAt : block.timestamp + 5 minutes,
            claimed : false
        });
        emit Lunch(count, msg.sender, 2 ether, block.timestamp, block.timestamp + 5 minutes);

        // (bool success, ) = address(this).call{value : msg.value}("");
        // require(success, "Transfer failed");
    }

    receive() external payable {}

    // cancel()
    function cancel(uint _id) external {
        // 1. load the campaing details   
        Campaign memory c = campaigns[_id];
        // 2. check the creator => creator == msg.sender => only creator can delete his campaign
        require(msg.sender == c.creator);
        // 3. check the time => block.timestamp < endAt
        require(block.timestamp < c.endAt);
        // 4. delete the campaign
        delete  campaigns[_id];
        // 5. emit the event
        emit Delete(_id, msg.sender);

        // 6. transfer the listing fees to the creator
        (bool success, ) = payable(c.creator).call{value : LISTING_FEES}("");
        require(success, "Transfer failed");
    } 

    // pledged()
    
    // unpleged()

    // claim()
    // refund()

    // withdraw - onlyOwner
    
}