// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LendingPool {

    //* 1. Declaring the variable
    address public owner;
    using SafeMath for uint;

    uint256 immutable INTEREST_RATE=3; // interest rate
    // uint256 public immutable borrowRate=450;
    uint constant SECONDS_IN_A_YEAR = 86400 * 365; // time

    //* 2. Defining Mapping
    // tokenAddress => tokenSymbol
    mapping(address => string) public tokenMap;
    // tokenAddress => amount
    mapping(address => uint) public reserves;
    // lenderAddress => tokenAddress
    mapping(address => address[])  public lenderAssetList;
    // lenderAddress => tokenAddress => amount
    mapping(address => mapping(address => uint)) public lenderAssets;
    // lenderAddress => tokenAddress => time
    mapping(address => mapping(address => uint)) public lenderTimestamp;
    // lenderAddress => tokenAddress => amount
    mapping(address => mapping(address => uint)) lenderRewards;

    //* 3. Defining Modifier
    modifier onlyActiveReserve(address _token) {
        require(reserves[_token] > 0, "No Reserve for Asset");
        _;
    }

    modifier isTokenInReserves(address _token, uint256 _amount) {
        require(reserves[_token] > _amount,"Not Enough Reserves to Borrow");
        _;
    }

    modifier ownerHasReserves(address _token) {
        require(lenderAssets[msg.sender][_token] > 0, "Not owner, cannot perform operation");
        _;
    }

    modifier onlyOwner(address _token) {
        require(isOwner(_token), "Not Owner");
        _;        
    }

    //* 4. Defining Constructor
    constructor () {
        owner = msg.sender;
    }

    //* 5. Defining Functions
    function isOwner(address _token) internal view returns(bool) {
        for (uint i = 0; i < lenderAssetList[msg.sender].length; i++) {
            if (lenderAssetList[msg.sender][i] == _token){
                return true;
            }
        }
        return false;
    }

    function addTokens(address _token, string memory _symbol) external {
        require(msg.sender == owner, "Not Owner, Cannot add");
        tokenMap[_token] = _symbol;
    }

    function lend(address _token, uint256 _amount) public {
        lenderAssetList[msg.sender].push(_token);
        lenderAssets[msg.sender][_token] = _amount;
        reserves[_token] += _amount;
        lenderTimestamp[msg.sender][_token] = block.timestamp;

        //! Haven't transfer into SC ??
        
    }

      function rewardTokensEarned(address lender,address _token) public view returns(uint256){
        // return lenderAssets[lender][_token] * (((block.timestamp-lenderTimestamp[lender][_token]) * INTEREST_RATE * 12)/SECONDS_IN_A_YEAR * 100);
        
        return (((block.timestamp-lenderTimestamp[lender][_token]) * INTEREST_RATE * 12)/SECONDS_IN_A_YEAR * 100);
    }   

    // function getLenderAssets(address _lender) public view returns (
    //     address[] memory assetList, 
    //     string[] memory symbols, 
    //     uint[] memory assetQty
    // ) {
    //     uint256 assetListLength = lenderAssetList[_lender].length;  
    //     assetList = new address[](assetListLength);
    //     symbols = new string[](assetListLength);
    //     assetQty = new uint[](assetListLength);

    //     for (uint256 i = 0; i < assetListLength; i++) {
    //         address asset = lenderAssetList[_lender][i];
    //         assetList[i] = asset;
    //         symbols[i] = tokenMap[asset];
    //         assetQty[i] = lenderAssets[_lender][asset];
    //     }
    // }

    // function withdraw(address _token) external ownerHasReserves(_token) onlyOwner(_token) payable returns(bool) {
    //     updateEarned(msg.sender, _token);
    //     require (reserves[_token] > 0, "Not enough qty to withdraw");
    //     reserves[_token] -= lenderAssets[msg.sender][_token];
    //     lenderAssets[msg.sender][_token] = 0;
    //     (bool success, ) = payable(msg.sender).call{value: lenderAssets[msg.sender][_token]}("");
    //     require (success);
    //     return true;
    // }
    
  

    // function updateEarned(address lender, address _token) onlyOwner(_token) public{
    //     // return((lenderAssets[lender][_token]*(updateRewardTokens()-lenderRewards[lender]))/1e18)+s_rewards[lender];
    //         lenderAssets[lender][_token] = 
    //             lenderAssets[lender][_token].add(
    //                     rewardTokensEarned(lender, _token)
    //                     );
    // }

    // function getReserves(address _token) public view returns(uint256){
    //     return reserves[_token];
    // }
}