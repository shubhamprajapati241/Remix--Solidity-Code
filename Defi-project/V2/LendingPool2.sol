// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "./LendingConfig.sol";
import "./AggregatorV3Interface.sol";

contract LendingPoolV2 is ReentrancyGuard {


    LendingConfig config;
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
    address[] public reserveAssets; 

    // lenderAddress => ethqty : For ETH Lend - Borrow manage
    mapping(address => uint) public lenderETHLendQty;

    // mapping(address => UserAsset) lenderAssets;
    mapping(address => UserAsset[]) public lenderAssets;
    mapping(address => UserAsset[]) borrowerAssets;

    //* 3. Declaring the structs
    struct UserAsset {
        address user;
        address token;
        uint256 lentQty;
        uint256 borrowQty;
        uint256 lentApy;
        uint256 borrowApy;
        uint256 lendStartTimeStamp;
        uint256 borrowStartTimeStamp;
    }

    struct ReservePool {
        address token;
        string symbol;
        uint amount;
        bool isBorrow;
        bool isfrozen;
        bool isActive;
    }

    // mapping(address => ReservePool[]) reservePools;
    ReservePool[] reservePool;

    // For now => optimization needed
    struct BorrowAsset {
        address asset;
        uint256 availableQty;
        uint256 apy;
    }

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

    // Aggregator functionality
    

    function getLatestPrice(address _tokenAddress) public view returns (int) {
        AggregatorV3Interface priceFeed;
        priceFeed = AggregatorV3Interface(_tokenAddress);
        (,int price,,,) = priceFeed.latestRoundData();
        return price / 1e8; //1e8 as per 8 decimals in chainlink doc 
    }

    function isTokenOwner(address _user, address _token) internal view returns(bool) {
        uint256 userAssetLength = lenderAssets[_user].length;
        for (uint i = 0; i < userAssetLength; i++) {
            if (lenderAssets[_user][i].user == _user && lenderAssets[_user][i].token == _token){
                return true;
            }
        }
        return false;
    }

   /***************** Lender functions ************************/
    receive() external payable {}

    function lend(address _token, uint256 _amount) public payable {
        address lender = msg.sender;

        // transfer Token : from the lender's wallet to DeFi app or SC 
        // IERC20(_token).transferFrom(lender,address(this),_amount);
        
        // Transfer ETH : from lender's wallet to SC
        // if(lendETH(1 ether)) { // REST Functionality 
        // }        

        // Add to lenders assets with amount - Add to userAssets struct
        // can use the mapping instead of loop over struct array

        uint lenderAssetLength = lenderAssets[lender].length;
        uint256 amount = _amount;
        
        /* ASK to Sasi => Did into borrow part
            TODO :  If token exits => update the lenderAssets details 
                    Else push the token values 
        */
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
            lentApy: INTEREST_RATE,
            borrowApy: 0,
            lendStartTimeStamp: block.timestamp,
            borrowStartTimeStamp:0
        });

        // add to lender asset list
        lenderAssets[lender].push(userAsset);
        // Add to Lending Pool a.k.a reserves
        // If using a struct, use a function getCurrentReserve() and add to the struct, that increases gas cost
        reserves[_token] += _amount;
        // Add to reserve assets for enabling iteration
        reserveAssets.push(_token);

        // Pushing reserves into ReservePool array => For now Testing 
        address _ethAddress = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        address _daiAddress = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
        address _usdcAddress = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;

        // ETH
        if(_token == _ethAddress) {
            reservePool.push(ReservePool(_token , "ETH", amount, false, false, false));
            // Updating Lender ETH balance => convert amount into USD
            lenderETHLendQty[lender] += amount;
        }

        // DAI
        if(_token == _daiAddress) {
            reservePool.push(ReservePool(_token , "DAI", amount, true, false, false));
        }

        // USDC
        if(_token == _usdcAddress) {
            reservePool.push(ReservePool(_token , "USDC", amount, true,  false, false));
        }

    }

    function lendETH(uint amount) internal returns(bool) { 
        (bool success, ) = address(this).call{value : amount}("");
        require(success, "Deposit failed");
        return true;
    } 


    /* TODO : On 22 Feb call
        1. REQUIRE ETH in collateral
        2. Get ETh balance in USD
        3. Calculate 80% of ETH balance from 
        4. Taking Token and amount 
        token / usd => chainlink oracle pricing
        require( amount > 80% Thresold)

        ------- Helper functions => getAssetsToBorrow

        5. Update the reserve pool
        6. Push into borrowerAssets 
        6. transfer into ERC20 token
    */ 

    function Borrow(address _token, uint _amount) public returns(bool) {

        /* TODO 
            1. Checking lenderETHAssets >= _amount 
            2. Checking reserve[_token] >= _amount & Updating Reserves
            3. Get Prev borrowAssetsLength
            4. If token exits => update borrowerAssets else push userAssets into borrowerAssets
            5. Updating lenderBalanceQty
            6. Token Transfer from SC to User : Add reentrancy
        */
        
        address borrower = msg.sender;

        // 1. Checking lenderETHAssets >= _amount 
        uint lenderETHAmount = uint256(getLenderETHBalanceUSD(borrower));
        require(lenderETHAmount >= _amount, "Not enough balance to borrow");

        // 2. Checking reserve[_token] >= _amount
        require(reserves[_token] >= _amount, "Not enough qty in the reserve pool to borrow");

        // Updating reserves
        reserves[_token] -= _amount;
        // TODO updating reservepool

        // 3. Get Previous borrowerAssetsLength
        uint borrowerAssetsLength =  borrowerAssets[borrower].length;

        // 4. If token exits => update borrowerAssets 
        //    else push userAssets into borrowerAssets
        for (uint i=0 ; i < borrowerAssetsLength; i++) {
            if(borrowerAssets[borrower][i].token == _token) {
                uint borrowerTotalAmount = borrowerAssets[borrower][i].borrowQty + _amount;

                borrowerAssets[borrower][i].borrowQty = borrowerTotalAmount;
                borrowerAssets[borrower][i].borrowApy = BORROW_RATE;
                borrowerAssets[borrower][i].borrowStartTimeStamp = block.timestamp;
            }else {
                UserAsset memory userAsset = UserAsset({
                    user: borrower,
                    token: _token,
                    lentQty: 0,
                    borrowQty: _amount,
                    lentApy: 0,
                    borrowApy: BORROW_RATE,
                    lendStartTimeStamp: 0,
                    borrowStartTimeStamp: block.timestamp
                });
                borrowerAssets[borrower].push(userAsset);
            }
        }

        // 5. Updating lender ETH balance for Next Borrow
        lenderETHLendQty[borrower] -= _amount; 

        // 7. Token Transfer from SC to User
        // bool success = IERC20(_token).transferFrom(address(this), borrower, _amount);
        // require(success, "Tranfer to user's wallet not successful");
        return true;
    }

    function getReservesInPool() public view returns(ReservePool[] memory) {
        return reservePool;
    }

    // Calculate the Assets to Borrow and return it
    function getAssetsToBorrow(address _borrower) public view returns(BorrowAsset[] memory) {
        
        /* TODO : 
            1. REQUIRE ETH in collateral & Get ETh balance in USD
            2. Calculate 80% of ETH balance
            3. Get stable assets from reserve => USDC, DAI, 
            4. Create BorrowAssetsArray and return it
        */

        //  1. REQUIRE ETH in collateral & Get ETh balance in USD

        // 2 Eth => 3200 => 2600
        uint ethBalance =  uint256(getLenderETHBalanceUSD(_borrower));
        require(ethBalance > 0 , "First Deposit ETH as Collateral");

        // 2. Calculate 80% of ETH balance
        uint maxBorrowAmount = (ethBalance * BORROW_THRESHOLD)/ 100; // Problem: Not getting the decimal value; 96 96.8
        
        // 3. Get stable assets from reserve

        BorrowAsset[] memory borrowAsset = new BorrowAsset[](reservePool.length);

        for(uint i = 0; i < reservePool.length ; i++) {
            // Remove the ETH Address by isBorrow from Reserve Struct
            if(reservePool[i].isBorrow) {
                uint reserveTokenQty = reservePool[i].amount;
                address token = reservePool[i].token;

                // ReserveTokenQty should more than borrow
                if(reserveTokenQty >= maxBorrowAmount) {
                    borrowAsset[i] = BorrowAsset(token, maxBorrowAmount, 3);
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
    function getBorrowerAssetBal(address _borrower, address _token) public view returns(uint256){
        uint borrowerAssetLength = borrowerAssets[_borrower].length;
        for (uint i = 0; i < borrowerAssetLength; i++) {
            if(borrowerAssets[_borrower][i].token == _token) {
                return borrowerAssets[_borrower][i].borrowQty;
            }
        }
        return 0;
    }

    function getLenderBalanceUSD(address _lender) public view returns(int256) {
        int256 totalBalance;
        uint lenderAssetLength = lenderAssets[_lender].length;
        for (uint i = 0; i < lenderAssetLength; i++) {
            int256 tokenUSDBalance = int256(getLatestPrice(lenderAssets[_lender][i].token)) * int256(lenderAssets[_lender][i].lentQty);
            totalBalance += tokenUSDBalance;
        }
        return totalBalance;
    }


    function getLenderETHBalanceUSD(address _lender) public view returns(int256) {
        address token = config.getAssetByTokenSymbol("ETH").token;
        int256 tokenUSDBalance = int256(getLatestPrice(token)) * int256(lenderETHLendQty[_lender]);
       
        return tokenUSDBalance;
    }

    // function getLenderAssets(address _lender) public view returns (UserAsset[] memory) {
    //     return lenderAssets[_lender];
    // }

    // function getBorrowerAssets(address _borrower) public view returns (UserAsset[] memory) {
    //     return borrowerAssets[_borrower];
    // }


    function withdraw(address _token, uint256 _amount) external onlyOwner(_token) payable returns(bool) {

        address lender  = msg.sender;
        // check if the owner has reserve
        require(getLenderAssetBal(lender, _token) >= _amount,"Not enough balance to withdraw");
        // we update the earned rewwards before the lender can withdraw
        //updateEarned(lender, _token); //100 + 0.00001 eth , 2 // TODO: implement 
        // Reserve must have enough withdrawl qty 
        require (reserves[_token] >= _amount, "Not enough qty in reserve pool to withdraw");
        // Remove from reserve
        reserves[_token] -= _amount;
        // Remove amount from lender assets
        uint lenderAssetLength = lenderAssets[lender].length;
        for (uint i = 0; i < lenderAssetLength; i++) {
            if(lenderAssets[lender][i].token == _token) {
                // subtract the quantity
                lenderAssets[lender][i].lentQty -= _amount;
                // Reset lender timestamp - this might cause an error
                lenderAssets[lender][i].lendStartTimeStamp = block.timestamp;
            }
        }

        // Updating lenderETHLendQty
        address ethAddress = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        if(_token == ethAddress) {
            lenderETHLendQty[lender] -= _amount;
        }

        // transfer from contract to lender's wallet - apprval not necessary
        // (bool success, ) = payable(lender).call{value: _amount}(""); //ETH Value
        // bool success = IERC20(_token).transferFrom(address(this),lender,_amount);
        // require (success,"Tranfer to user's wallet not successful");
        // Emit withrawl event
        return true;
    }

}

// Lender1 : 0x583031D1113aD414F02576BD6afaBfb302140225

// ETH : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 - 10
// DAI : 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB - 200
// USDC : 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db - 300

// Lender2 :  0xdD870fA1b7C4700F2BD7f44238821C26f7392148

// ETH : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 - 40
// USDC : 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db - 50
// DAI : 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB - 60

