// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC20 {
    
    function transferFrom(address sender, address recipient, uint256 amount) external;
    function transfer(address recipient, uint256 amount) external;
    function approve(address sender, uint256 amount) external returns (bool);
    function balanceOf(address sender) external returns (uint);
    function allowance(address owner, address spender) external returns(uint );
}

contract TransferAsset {

    mapping (address => mapping (address => uint)) public lenderAssets;

    // receive() external payable {}

    IERC20 public token;
    address public tokenAddress;

    constructor(address _token) {
        token = IERC20(_token);
        tokenAddress = _token;
    }

    function allowanceToken() public returns(uint noOfToken) {
        return token.allowance(msg.sender, address(this));
    }

    function approveToken(uint _amount) public returns(bool) {
        return token.approve(address(this), _amount);
    }

    function transferToken(uint256 amount) public {
        token.transferFrom(msg.sender, address(this), amount);
    }


    // Allow you to show how many tokens owns this smart contract
    function getSmartContractBalance() external view returns(uint) {
        return token.balanceOf(address(this));
    }

    // Allow you to show how many tokens owns this smart contract
    function getSmartContractBalanceSC() external view returns(uint) {
        return token.balanceOf(msg.sender);
    }

    // function approve(address _token, address sc, uint256 _amount) public {
    //     IERC20(_token).approve(sc, _amount);
    // }


    // function transfer(address _token, address sc, uint _amount) public payable{
    //     IERC20 token = IERC20(_token);
    //     require(token.balanceOf(msg.sender) >= _amount, "Not sufficient balance to transfer");
    //     token.transferFrom(msg.sender,sc,_amount);
    //     lenderAssets[msg.sender][_token] += _amount;
    // }
 

    // function transferETH() public payable{
    //     (bool success, ) = payable(address(this)).call{value: msg.value}("");
    //     require(success);
    // }

    // function withdraw() public payable{
    //     (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    //     require(success);
    // }

}

// DAI - 0xBa8DCeD3512925e52FE67b1b5329187589072A55



//  Goerli => ether SC address =