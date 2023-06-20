// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// require("hardhat/console");

contract FundCreators {
    address public owner;
    struct Creator {
        string name; // personal details
        string description;
        string photo;
        string location;
        string[] tags;
        string website; // social details
    }

    struct User {
        address walletAddress;
        bool isCreator; 
        bool isDisable; // to disable user
        // for user => contributor
        uint256 totalFundedContributorsCount; // user => funded to => contributor => count
        uint256 totalFundsSentAmount; // amount user => sent to => contributor
        // for contributor => user
        uint256 totalCreatorsFundedCount; // contributor => send to user => count
        uint256 totalFundsReceivedAmount; // amount contributor => send to user
        uint256 withdrawableBalance; // amount to withdraw
    }

    // for storing all the creatos & user address
    address[] public totalCreatorsList;
    address[] public totalUserList;

    // for storing user and creator details
    mapping(address => User) users;
    mapping(address => Creator) creators;

    // to track user and contributors funded amouunt details 
    // user => (creator => amount)
    mapping(address => mapping(address => uint256)) sentFundAmount;
    // creator => (user => amount)
    mapping(address => mapping(address => uint256)) receivedFundAmount;

    // declare events
    event UserCreated(address);
    event Donate(address user, address creator, uint256 amount);
    event CreateOrUpdateCreator(address creator);

    constructor() {
        owner = msg.sender;
    }

    // start functionalities
    function createUser() external returns(bool) {
        require(users[msg.sender].walletAddress == address(0), "User already exits");
        // users[msg.sender] = User(msg.sender, false, false,0,0,0,0,0);
         users[msg.sender] = User(msg.sender, false, false, 0, 0, 0, 0, 0);
        totalUserList.push(msg.sender);
        emit UserCreated(msg.sender);
        return true;
    }

    function createOrUpdateCreator(string calldata _name, string calldata _description, string calldata _photo, string calldata _location, string[] memory _tags, string memory _website ) external returns(bool){
        User storage u = users[msg.sender];
        if(u.isCreator == false) totalCreatorsList.push(msg.sender);
        u.isCreator = true;
        creators[msg.sender] = Creator(_name, _description, _photo, _location, _tags,_website);
        emit CreateOrUpdateCreator(msg.sender);
        return true;
    }

    // user => donate => creator
    function donate(address _creator, uint256 _amount) external returns(bool) {
        // require(users[_creator].isCreator == true, "User is not a creator");
        require(users[msg.sender].isDisable == false, "User is disable");
        require(_amount > 0, "Amount can't be below zero");

        // user => send to => _creator 
        // updating on user side
        if(sentFundAmount[msg.sender][_creator] == 0) users[msg.sender].totalFundedContributorsCount++;
        users[msg.sender].totalFundsSentAmount += _amount;
        sentFundAmount[msg.sender][_creator] += _amount;

        // updating on creator side
        if(receivedFundAmount[_creator][msg.sender] == 0) users[_creator].totalCreatorsFundedCount++;

        users[_creator].totalFundsReceivedAmount += _amount;
        users[_creator].withdrawableBalance += _amount;

        // (bool succuss,) = address(this).call{value : _amount}("");
        // require(succuss);
        emit Donate(msg.sender, _creator, _amount);
        return true;
    }

    function withdraw(uint256 _amount) external {
        require(users[msg.sender].withdrawableBalance > _amount, "Requested amount is higher than balance");
        User storage user = users[msg.sender];
        user.withdrawableBalance -= _amount;
        (bool succuess, ) = msg.sender.call{value : _amount}("");
        require(succuess);
    }

   function getCreatorDetails(address _address)
    public
    view
    returns (
      string memory,
      string memory,
      string memory,
      string memory,
      string memory,
      string[] memory
    )
  {

    require(users[_address].walletAddress != address(0), "No User Found");
    require(users[_address].isCreator == true, "User is not a Creator");
    Creator memory myCreator = creators[_address];
    return (
      myCreator.name,
      myCreator.description,
      myCreator.photo,
      myCreator.location,
      myCreator.website,
      myCreator.tags
     
    );
  }

  function getUserDetails(address _address)
    public
    view
    returns (
      address,
      bool,
      bool,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    require(users[_address].walletAddress != address(0), "No User Found");
    User memory myUser = users[_address];
    return (
      myUser.walletAddress,
      myUser.isDisable,
      myUser.isCreator,
      myUser.totalFundedContributorsCount,
      myUser.totalFundsSentAmount,
      myUser.totalCreatorsFundedCount,
      myUser.totalFundsReceivedAmount,
      myUser.withdrawableBalance
    );
  }

  function disableUser(address _creator) public returns (bool) {
    users[_creator].isDisable = true;
    return true;
  }

  function getAllCreatorsList() public view returns (address[] memory) {
    return totalCreatorsList;
  }
}
