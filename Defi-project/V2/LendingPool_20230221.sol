// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

// import "./LendingConfig.sol";

contract LendingPoolV2 is ReentrancyGuard {
    using SafeMath for uint;

    //* 1. Declaring the variables
    address deployer;
    uint256 immutable INTEREST_RATE = 3;
    uint256 immutable BORROW_RATE = 4;
    uint256 borrowThreshold = 80;

    //* 2. Declaring the mapping

    // asset token => reserve qty
    mapping (address => uint) public reserves;
    // For iteration - Do we need this?
    address[] reverseAssets; 

    // lenderAddress => tokenAddress => tokenQty
    // mapping(address => UserAsset) lenderAssets;
    mapping(address => mapping(address => uint)) lenderAssets;


    //* 3. Declaring the structs

    struct UserAsset {
        address user;
        address token;
        uint256 lentQty;
        uint256 borrowQty;
        uint256 interestRate;
        uint256 borrowRate;
        uint256 lendStartTimeStamp;
        uint256 borrowStartTimeStamp;
    }

    UserAsset[] public userAssets; // array of Struct UserAsset

    struct ReservePool {
        address token;
        uint amount;
        bool isfrozen;
        bool isActive;
    }
    ReservePool[] reservePool; // array of ReversePool struct

    //* 4. Creating constructor
    constructor() {
        deployer = msg.sender;
        // INTEREST_RATE  = _interestRate; // Use logic like REWARDS staking
        // BORROW_RATE = _borrowRate; // If interest rate is 3.5, pass 350, it will be converted to 3.5
    }

    function isTokenOwner(address _user, address _token) internal view returns(bool) {
        uint256 userAssetLength = userAssets.length;
        for (uint i = 0; i < userAssetLength; i++) {
            if (userAssets[i].user == _user && userAssets[i].token == _token){
                return true;
            }
        }
        return false;
    }

   /************* Lender functions ************************/

    function lend(address _token, uint256 _amount) public payable {
        // IERC20 token = IERC20(_token); 
        // Asset storage asset = Asset({
        address lender = msg.sender;

        // transfer from the lender's wallet to DeFi app or SC 
        // IERC20(_token).transferFrom(lender,address(this),_amount);

        // Add to lenders assets with amount - Add to userAssets struct

        uint amount = lenderAssets[lender][_token] + _amount;
        UserAsset memory userAsset = UserAsset({
            user: lender,
            token: _token,
            lentQty: amount,
            borrowQty: 0,
            interestRate: INTEREST_RATE,
            borrowRate: 0,
            lendStartTimeStamp: block.timestamp,
            borrowStartTimeStamp:0
        });

      
        userAssets.push(userAsset);   // Push to the struct array
        // add to lender asset list
        lenderAssets[lender][_token] = amount; //Is this really necessary?
        // Add to Lending Pool a.k.a reserves
        // If using a struct, use a function getCurrentReserve() and add to the struct, that increases gas cost
        reserves[_token] += _amount; //TODO: to use a struct or a mapping?
        // Add to reserve assets for enabling iteration
        reverseAssets.push(_token);
    }


}

// for (uint i = 0; i < lenderAssetList[msg.sender].length; i++) {
//     if (lenderAssetList[msg.sender][i] == _token){
//         return true;
//     }
// }

// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4  - owner

// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 - lender

// Chainlink - https://docs.chain.link/data-feeds/price-feeds/addresses/

// 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e - ETH - 3
// 0x0d79df66BE487753B02D015Fb622DED7f0E9798d - DAI - 33
// 0xAb5c49580294Aff77670F839ea425f5b78ab3Ae7 - USDC - 13
// 0x48731cF7e84dc94C5f84577882c14Be11a5B7456 - LINK - 23

/*
BTC / USD 0xA39434A63A52E749F02807ae27335515BA4b07F7 - 8
DAI / USD 0x0d79df66BE487753B02D015Fb622DED7f0E9798d- 8
ETH / USD 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e- 8
LINK / USD 0x48731cF7e84dc94C5f84577882c14Be11a5B7456 - 8
USDC / USD 0xAb5c49580294Aff77670F839ea425f5b78ab3Ae7- 8
*/