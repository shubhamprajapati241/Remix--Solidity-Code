    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./LendingConfig.sol";

contract LendingPoolV2 is ReentrancyGuard {
    
    using SafeMath for uint;

    //* 1. Declaring the variables
    address deployer;
    uint256 INTEREST_RATE;
    uint256 BORROW_RATE;
    uint256 constant BORROW_THRESHOLD = 80;

    //* 2. Declaring the mapping

    // asset token => reserve qty
    mapping (address => uint) public reserves;
    // For iteration - Do we need this?

    address[] public reverseAssets; 

    // mapping(address => UserAsset) lenderAssets;
    // mapping(address => mapping(address => uint)) lenderAssets;
    mapping(address => UserAsset[]) public lenderAssets;
    mapping(address => UserAsset[]) borrowerAssets;

    //* 3. Declaring the structs
    struct UserAsset {
        address user;
        address token;
        uint256 lentQty;
        uint256 borrowQty;
        uint256 apy;
        uint256 borrowRate;
        uint256 lendStartTimeStamp;
        uint256 borrowStartTimeStamp;
    }

    UserAsset[] public userAssets;

    struct ReservePool {
        address token;
        string symbol;
        uint amount;
        bool isCollateral;
        bool isfrozen;
        bool isActive;
    }

    ReservePool[] reservePool;

    //* 4. Declaring modifiers
    modifier onlyOwner(address _token) {
        require(isTokenOwner(msg.sender, _token), "Not Owner");
        _;        
    }

    //* 5. Declaring constructor
    constructor(uint256 _interestRate, uint256 _borrowRate) {
        deployer = msg.sender;
        // Use logic like REWARDS staking
        INTEREST_RATE  = _interestRate;
        // If interest rate is 3.5, pass 350, it will be converted to 3.5
        BORROW_RATE = _borrowRate;
    }

    //* Functionalities

    function isTokenOwner(address _user, address _token) internal view returns(bool) {
        uint256 userAssetLength = userAssets.length;
        for (uint i = 0; i < userAssetLength; i++) {
            if (userAssets[i].user == _user && userAssets[i].token == _token){
                return true;
            }
        }
        return false;
    }

   /***************** Lender functions ************************/
    receive() external payable {}

    function lend(address _token, uint256 _amount) public payable {
        address lender = msg.sender;

        // transfer from the lender's wallet to DeFi app or SC 
        // IERC20(_token).transferFrom(lender,address(this),_amount);
        
        // TODO : Call for ETH
        // if(lendETH(1 ether)) { // REST Functionality 
        // }        

        // Add to lenders assets with amount - Add to userAssets struct
        // can use the mapping instead of loop over struct array

        uint lenderAssetLength = lenderAssets[lender].length;
        uint256 amount = _amount;
        for (uint i = 0; i < lenderAssetLength; i++) {
            if(lenderAssets[lender][i].token == _token) {
                amount += lenderAssets[lender][i].lentQty;
            }
        }

        UserAsset memory userAsset = UserAsset({
            user: lender,
            token: _token,
            lentQty: amount,
            borrowQty: 0,
            apy: INTEREST_RATE,
            borrowRate: 0,
            lendStartTimeStamp: block.timestamp,
            borrowStartTimeStamp:0
        });

        // Push to the struct array
        userAssets.push(userAsset);
        // add to lender asset list
        lenderAssets[lender].push(userAsset);
        // Add to Lending Pool a.k.a reserves
        // If using a struct, use a function getCurrentReserve() and add to the struct, that increases gas cost
        reserves[_token] += _amount;
        // Add to reserve assets for enabling iteration
        reverseAssets.push(_token);
    }

    function lendETH(uint amount) internal returns(bool) { 
        (bool success, ) = address(this).call{value : amount}("");
        require(success, "Deposit failed");
        return true;
    } 

    function pushAssetsIntoReservePool() public {

        //  address token;
        // string symbol;
        // uint amount;
        // bool isfrozen;
        // bool isActive;

        // ETH : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 
        // USDC : 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db 
        // DAI : 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
        reservePool.push(ReservePool(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 , "ETH", 100, false, false, false));
        reservePool.push(ReservePool(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db , "DAI", 200,  true, false, false));
        reservePool.push(ReservePool(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB , "USDC", 200, true, false, false));

    }

    function getReservesInPool() public view returns(ReservePool[] memory) {
        return reservePool;
    }

    struct BorrowAsset {
        address asset;
        uint256 availableQty;
        uint256 apy;
    }


    function getAssetsToBorrow(address _lender) public view returns(BorrowAsset[] memory) {
        // function getAssetsToBorrow(address _lender) public view returns(uint) {

        // 1. Getting the Total LentAmount in USD
        // 2. Getting Max borrow amount with borrow thresold. 
        uint totalLentAmount =  getLenderBalanceUSD(_lender);
        uint maxBorrowAmount = (totalLentAmount * BORROW_THRESHOLD)/ 100; // Problem: Not getting the decimal value;
        
        // 3. Getting Reserves in the pool

        // uint totalBorrowAssetsCount = getTotalBorrowAssetsCount(); // more optimize
        BorrowAsset[] memory borrowAsset = new BorrowAsset[](reservePool.length);

        for(uint i = 0; i < reservePool.length ; i++) {
            // Removing the ETH Address 
            if(reservePool[i].isCollateral) {
                uint reserveTokenQty = reservePool[i].amount;
                address token = reservePool[i].token;

                if(reserveTokenQty >= maxBorrowAmount) {
                    borrowAsset[i] = BorrowAsset(token, maxBorrowAmount, 3);
                    // index++;
                }
            }
        }
        return borrowAsset;
    }


    // Helper function - should actually be private but making it public for now to debug
    function getLenderAssetBal(address _lender, address _token) public view returns(uint256){
        uint lenderAssetLength = lenderAssets[_lender].length;
        for (uint i = 0; i < lenderAssetLength; i++) {
            if(lenderAssets[_lender][i].token == _token) {
                return lenderAssets[_lender][i].lentQty;
            }
        }
        return 0;
    }

    // Helper function - should actually be private but making it public for now to debug
    // function getBorrowerAssetBal(address _borrower, address _token) public view returns(uint256){
    //     uint borrowerAssetLength = borrowerAssets[_borrower].length;
    //     for (uint i = 0; i < borrowerAssetLength; i++) {
    //         if(borrowerAssets[_borrower][i].token == _token) {
    //             return lenderAssets[_borrower][i].borrowQty;
    //         }
    //     }
    //     return 0;
    // }

    function getLenderBalanceUSD(address _lender) public view returns(uint256) {
        uint256 totalBalance;
        uint lenderAssetLength = lenderAssets[_lender].length;
        for (uint i = 0; i < lenderAssetLength; i++) {
            totalBalance += lenderAssets[_lender][i].lentQty;
        }
        return totalBalance;
    }

    function getLenderAssets(address _lender) public view returns (UserAsset[] memory) {
        return lenderAssets[_lender];
    }

    function getTotalBorrowAssetsCount() public view returns(uint256) {
        uint count;
        uint length = reservePool.length;
        for(uint i=0;i < length; i++) {
            if(reservePool[i].isCollateral) {
                count ++;
            }
        }
        return count;
    }

    // function getBorrowerAssets(address _borrower) public view returns (UserAsset[] memory) {
    //     return borrowerAssets[_borrower];
    // }


    // function withdraw(address _token, uint256 _amount) external onlyOwner(_token) payable returns(bool) {

    //     address lender  = msg.sender;
    //     // check if the owner has reserve
    //     require(getLenderAssetBal(lender, _token) >= _amount,"Not enough balance to withdraw");
    //     // we update the earned rewwards before the lender can withdraw
    //     //updateEarned(lender, _token); //100 + 0.00001 eth , 2 // TODO: implement 
    //     // Reserve must have enough withdrawl qty 
    //     require (reserves[_token] >= _amount, "Not enough qty in reserve pool to withdraw");
    //     // Remove from reserve
    //     reserves[_token] -= _amount;
    //     // Remove amount from lender assets
    //     uint lenderAssetLength = lenderAssets[lender].length;
    //     for (uint i = 0; i < lenderAssetLength; i++) {
    //         if(lenderAssets[lender][i].token == _token) {
    //             // subtract the quantity
    //             lenderAssets[lender][i].lentQty -= _amount;
    //             // Reset lender timestamp - this might cause an error
    //             lenderAssets[lender][i].lendStartTimeStamp = block.timestamp;
    //         }
    //     }
    //     // transfer from contract to lender's wallet - apprval not necessary
    //     // (bool success, ) = payable(lender).call{value: _amount}(""); //ETH Value
    //     bool success = IERC20(_token).transferFrom(address(this),lender,_amount);
    //     require (success,"Tranfer to user's wallet not successful");
    //     // Emit withrawl event
    //     return true;
    // }


   


}

// Lender1 : 0x583031D1113aD414F02576BD6afaBfb302140225

// ETH : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 - 100
// USDC : 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db - 50
// DAI : 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB - 

// Lender2 :  0xdD870fA1b7C4700F2BD7f44238821C26f7392148

// ETH : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 - 500
// USDC : 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db - 200
// DAI : 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB - 
