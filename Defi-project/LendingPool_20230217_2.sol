// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LendingPool {
    address public deployer;

    using SafeMath for uint;

    uint256 public immutable INTEREST_RATE=3;
    uint256 public immutable BORROW_THRESHOLD=50;
    uint256 public immutable LIQUIDATION_THRESHOLD=10;
    // uint256 public immutable borrowRate=450;
    
    uint constant SECONDS_IN_A_YEAR = 86400 * 365;

    mapping(address => string) public tokenMap;
    
    mapping(address => mapping(address => uint)) lenderAssets;
    mapping(address => address[]) lenderAssetList;
    mapping(address => uint) lenderTotalLandings;
    mapping(address => mapping(address => uint)) lenderTimestamp;
    mapping(address => mapping(address => uint)) lenderRewards;

    mapping(address => uint) reserves;
    address[] reserveAssets;

    mapping(address => mapping(address => uint)) borrows;
    mapping(address => address[]) borrowList;
    mapping(address => mapping(address => uint)) borrowerTimestamp;
   
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

    constructor () {
        deployer = msg.sender;
    }

    function isOwner(address _token) internal view returns(bool) {
        for (uint i = 0; i < lenderAssetList[msg.sender].length; i++) {
            if (lenderAssetList[msg.sender][i] == _token){
                return true;
            }
        }
        return false;
    }

    function addTokens(address _token, string memory _symbol) external {
        require(msg.sender == deployer, "Not Owner, Cannot add");
        tokenMap[_token] = _symbol;
    }

    /************* Lender functions ************************/

    function lend(address _token, uint256 _amount) public {
        IERC20 token = IERC20(_token); 
        address lender = msg.sender;
        // Add to lenders assets with amount
        lenderAssets[lender][_token] = _amount;
        // add to lender asset list
        lenderAssetList[lender].push(_token);
        // Add to Lending Pool a.k.a reserves

        lenderTotalLandings[msg.sender] += _amount;
        reserves[_token] += _amount;
        // Add to reserve assets for enabling iteration
        reserveAssets.push(_token);
        // set the lending timestamp 
        lenderTimestamp[lender][_token] = block.timestamp;
        // transfer from the lender's wallet to DeFi app or SC 
        // TODO: Shubham to figure out how to xfer token from wallet to SC
        bool success=token.transferFrom(lender,address(this),_amount);
        // (bool success,) = address(this).call{value: msg.value}("");
        require(success, "Transfer from Lender's wallet failed");
    }

    function getAssets(address _user) public view returns (
        address[] memory assetList, 
        string[] memory symbols, 
        uint[] memory assetQty
    ) {
        uint256 assetListLength = lenderAssetList[_user].length;  
        assetList = new address[](assetListLength);
        symbols = new string[](assetListLength);
        assetQty = new uint[](assetListLength);

        for (uint256 i = 0; i < assetListLength; i++) {
            address asset = lenderAssetList[_user][i];
            assetList[i] = asset;
            symbols[i] = tokenMap[asset];
            assetQty[i] = lenderAssets[_user][asset];
        }
    }

    function withdraw(address _token, uint256 _amount) external ownerHasReserves(_token) onlyOwner(_token) payable returns(bool) {
        IERC20 token = IERC20(_token); 
        address lender  = msg.sender;
        // we update the earned rewwards before the lender can withdraw
        updateEarned(lender, _token); //100 + 0.00001 eth , 2 
        // Lender must have lent assets > 0
        require(lenderAssets[lender][_token] > _amount, "Lender does not have this asset");
        // Reserve must have enough withdrawl qty 
        require (reserves[_token] > _amount, "Not enough qty to withdraw");
        // Remove from reserve
        reserves[_token] -= _amount;
        if(reserves[_token] == 0) {
            uint index;
            // TODO: implement a gap less array - implemented
            for (uint i = 0; i < reserveAssets.length; i++){
                if(reserveAssets[i] == _token) {
                    delete reserveAssets[i];
                    index=i;
                    break;
                }
            }
            reserveAssets[index] = reserveAssets[reserveAssets.length-1];
            reserveAssets.pop();
        }
        // Remove amount from lender assets
        lenderAssets[lender][_token] = lenderAssets[lender][_token].sub(_amount);
        // Reset lender timestamp - this might cause an error
        lenderTimestamp[lender][_token] = block.timestamp;
        // transfer from contract to lender's wallet
        // (bool success, ) = payable(lender).call{value: _amount}(""); //ETH Value
        bool success = token.transferFrom(address(this),lender,_amount);
        require (success);
        return true;
    }
    
    // TODO: make it internal
    function rewardTokensEarned(address lender,address _token) public view returns(uint256){
        return lenderAssets[lender][_token] * (((block.timestamp-lenderTimestamp[lender][_token]) * INTEREST_RATE * 12)/SECONDS_IN_A_YEAR * 100);
    }   

    function updateEarned(address lender, address _token) onlyOwner(_token) public{
        // return((lenderAssets[lender][_token]*(updateRewardTokens()-lenderRewards[lender]))/1e18)+s_rewards[lender];
            lenderAssets[lender][_token] = 
                lenderAssets[lender][_token].add(
                        rewardTokensEarned(lender, _token)
                        );
    }

    function getReserves(address _token) public view returns(uint256){
        return reserves[_token];
    }

    /************* Borrower functions ************************/

    // function hasETHCollateral(address ETHAddress) {
    //     Threshold lenderAssets[msg.sender][ETHAddress]
    //     // price oracle thing
    // }
    
    struct Borrow {
        address asset;
        uint256 availableQty;
        uint256 apy;
    }
   
    function getAssetsToBorrow() public view {
        // Go by balance  not by tokens
        // 1. require borrower Assets for ETH
        // 2. require reserves to have borrow threshold% of ETH to lend
        // 3. remove balance of existing borrows
        // 3. spread that borrow threshold amount amongst other tokens - use Price Oracle ETH/USD -> DAI/USD (ETH->DAI) 80% - that is availbale
        

        // 1. Getting lender totalAssets => 2 ETH => 3200 USD
        // uint lendingTotalAmount = lenderTotalLandings[msg.sender];
        uint lendingTotalAmount = 3200

        // 2. Getting Max borrow amount with borrow thresold. 
        //  ETH => Borrow thresold will be low => 60% => 3200 * 60% = 1920 => user can borrow in stable coin

        uint maxBorrowAmount = 3200 

        // 3. Getting Reserve assets from lending pool 
        // If lendingpool reserve assets not equal to borrow amount => remove that assets from borrow list

        // 4. Creating Borrow assets array for return


    
        
        
        // uint256 availableAssets = reserveAssets.length;
        // Borrow[] memory b = new Borrow[](availableAssets);



        
    }
    function borrow(address _token, uint256 _amount) external {
        IERC20 token = IERC20(_token); 
        address borrower = msg.sender;
        // isAvailableForBorrow
        require(reserves[_token] > _amount, "Not enough reserves to borrow");     
        // hasSufficientETHCollateral - 80% threshold logic to be implemented by Shubham
        require(lenderAssets[borrower][_token] > _amount,"Not enough ETH collateral to Borrow");     
        // Set accrual start time for charging borrow interest
        borrowerTimestamp[borrower][_token]=block.timestamp;
        // transferFromReservesToBorrower
        reserves[_token] -= _amount;
        // Add to borrowers list
        borrows[borrower][_token] += _amount;
        // (bool success,) = msg.sender.call{value: _amount}("");
        bool success = token.transferFrom(address(this),borrower,_amount);
        require(success, "Borrow Failed");
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



// 80% = contract.borrowThreshold()


// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
// 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db


    // function getLenderAssetsStruct(address _lender) public view returns () (
    //     address[] memory assetList, 
    //     string[] memory symbols, 
    //     uint[] memory assetQty
    // ) {

    //     struct Assets {
    //         address token;
    //         string symbol;
    //         uint amount;
    //     }
    //     Assets[] private assets;

    //     uint256 assetListLength = lenderAssetList[_lender].length;  
    //     for (uint256 i = 0; i < assetListLength; i++) {
    //         address asset = lenderAssetList[_lender][i];
    //         assetList.push(asset);
    //         symbols.push(tokenMap[asset]);
    //         assetQty.push(lenderAssets[_lender][asset]);
    //     }
    // }


    //     function rewardTokensEarned(address lender,address _token) public view returns(uint256){
    //     // return lenderAssets[lender][_token]+(((block.timestamp-lenderTimestamp[lender][_token])*INTEREST_RATE*1e18)/reserves[_token]);
    //     return lenderAssets[lender][_token] * (((block.timestamp-lenderTimestamp[lender][_token]) * INTEREST_RATE)/SECONDS_IN_A_YEAR * 100);
    // }   

    // function earned(address lender, address _token) public view returns(uint256){
    //     // return((lenderAssets[lender][_token]*(updateRewardTokens()-lenderRewards[lender]))/1e18)+s_rewards[lender];
    //     return((lenderAssets[lender][_token]*(updateRewardTokens(_token)-lenderRewards[lender][_token]))/1e18)+lenderRewards[lender][_token];
    // }
