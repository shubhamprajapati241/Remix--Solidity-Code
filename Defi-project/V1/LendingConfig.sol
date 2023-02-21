// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Should we make it so that we can only LendingPoolV2 can add the assets when someone lends?

contract LendingPoolConfig {

    address owner;

    enum Freeze { FREEZE, UNFREEZE}
    enum AssetStatus { ACTIVE, INACTIVE }

    event AddAsset(address token, string symbol, uint borrowThreshold, uint liquidationThreshold);
    event UpdateAssetStatus(address token, AssetStatus isActive);
    event UpdateAssetFrozen(address token, Freeze isfrozen);

    modifier onlyOwner() {
        require(owner == msg.sender, "Not Owner, cannot perfrm OP");
        _;
    }
    
    constructor(){
        owner = msg.sender;
    }

    struct Asset {
        address token;
        string symbol;
        uint256 decimals;
        uint borrowThreshold;
        uint liquidationThreshold;
        uint lastUpdateTimestamp;
        bool borrowingEnabled;
        bool usageAsCollateralEnabled;
        bool isfrozen;
        bool isActive;
    }
    
    Asset[] private assets;

    function addAssets(
        address _token, 
        string memory _symbol, 
        uint256 decimals,
        uint256 borrowThreshold,
        uint256 liquidationThreshold,
        bool borrowingEnabled,
        bool usageAsCollateralEnabled,
        bool isfrozen,
        bool isActive
    ) external {


        assets.push(
            Asset({
                token: _token,
                symbol: _symbol,
                decimals: decimals,
                borrowThreshold: borrowThreshold, 
                liquidationThreshold: liquidationThreshold,
                lastUpdateTimestamp: block.timestamp,
                borrowingEnabled: borrowingEnabled,
                usageAsCollateralEnabled: usageAsCollateralEnabled,
                isfrozen: isfrozen,
                isActive: isActive
            })
        );


    }

    function makeAssetActiveInactive(address _token, AssetStatus _choice) external returns(bool){
        uint256 assetsLen = assets.length;
        for (uint i = 0; i < assetsLen; i++) {
            if (assets[i].token == _token){
                if (_choice == AssetStatus.ACTIVE){
                    assets[i].isfrozen = true;    
                }
                else {
                    assets[i].isfrozen = false;
                }
                assets[i].lastUpdateTimestamp = block.timestamp;
                return true;
            }
        }
        emit UpdateAssetStatus(_token, _choice);        
        return false;
    }

    function freezeUnFreezeAsset(address _token, Freeze _choice) public returns(bool){
        uint256 assetsLen = assets.length;
        for (uint i = 0; i < assetsLen; i++) {
            if (assets[i].token == _token){
                if (_choice == Freeze.FREEZE){
                    assets[i].isfrozen = true;    
                }
                else {
                    assets[i].isfrozen = false;
                }
                assets[i].lastUpdateTimestamp = block.timestamp;
                return true;
            }
        }
        emit UpdateAssetFrozen(_token, _choice);
        return false;
    }




}


// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4  - owner

// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 - lender

// 0xdD870fA1b7C4700F2BD7f44238821C26f7392148 - ETH - 46
// 0x583031D1113aD414F02576BD6afaBfb302140225 - MATIC - 32
// 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB - USDC - 23

//----

// 0x17F6AD8Ef982297579C203069C1DbfFE4348c372

// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 - ETH - 33
// 0x583031D1113aD414F02576BD6afaBfb302140225 - MATIC - 44
// 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB - USDC - 55


    // function makeAssetActive(address _token) public returns(bool){
    //     uint256 assetsLen = assets.length;
    //     for (uint i = 0; i < assetsLen; i++) {
    //         if (assets[i].token == _token){
    //             assets[i].isActive = true;
    //             assets[i].lastUpdateTimestamp = block.timestamp;
    //             return true;
    //         }
    //     }
    //     return false;
    // 