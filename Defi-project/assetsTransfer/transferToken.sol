// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface ERC20 {

  function balanceOf(address owner) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);
  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool); 

}

contract Bank {

    function transferToMe(address _owner, address _token, uint _amount) public {
        ERC20(_token).allowance(_owner, address(this));
        ERC20(_token).approve(_owner, _amount);
        ERC20(_token).transferFrom(_owner, address(this), _amount);
    }
}