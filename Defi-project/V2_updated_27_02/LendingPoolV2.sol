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
import "./AddressToTokenMap.sol";

import "./AddressToTokenMap.sol";

contract LendingPoolV2 is ReentrancyGuard {
    using SafeMath for uint;

    //* 1. Declaring the variables
    address deployer;
    uint256 public INTEREST_RATE;
    uint256 public BORROW_RATE;
     uint256 public constant DECIMALS = 18;
    uint256 public constant BORROW_THRESHOLD = 80;
    uint256 public constant LIQUIDATION_THRESHOLD = 10;
    
    uint32 public constant BORROW_DURATION_30 = 30 days;
    uint32 public constant BORROW_DURATION_60 = 60 days;
    uint32 public constant BORROW_DURATION_90 = 90 days;

    LendingConfig lendingConfig;
    AddressToTokenMap addressToTokenMap;
   
    //* 2. Declaring the mapping
    // asset token => reserve qty
    mapping (address => uint) public reserves;
    // For iteration - Do we need this?
    address[] reverseAssets; 
    // mapping(address => UserAsset) lenderAssets;
    // mapping(address => mapping(address => uint)) lenderAssets;
    mapping(address => UserAsset[]) public lenderAssets;
    mapping(address => UserAsset[]) public borrowerAssets;

    // lenderAddress => ethqty : For ETH Lend - Borrow manage
    mapping(address => uint) public lenderETHBalance;
    
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
        uint256 borrowEndTimeStamp; // borrow maturity period
        uint256 maturityPeriod; 
    }

    UserAsset[] public userAssets;

    // struct ReservePool {
    //     address token;
    //     string symbol;
    //     uint amount;
    //     bool isBorrow;
    //     bool isfrozen;
    //     bool isActive;
    // }

    // mapping(address => ReservePool[]) reservePools;
    // ReservePool[] reservePool;

    struct BorrowAsset {
        address asset;
        uint256 availableQty;
        uint256 apy;
    }

     constructor(uint256 _interestRate, uint256 _borrowRate) {
        deployer = msg.sender;
        // Use logic like REWARDS staking
        INTEREST_RATE  = _interestRate;
        // If interest rate is 3.5, pass 350, it will be converted to 3.5
        BORROW_RATE = _borrowRate;
    }

    //* 4. Declaring modifiers
    modifier onlyOwner(address _token) {
        require(isLenderTokenOwner(_token), "Not token owner");
        _;        
    }

    modifier onlyAmountGreaterThanZero(uint256 amount) {
        require(amount > 0, "Amount must be greater than zero");
        _; 
    }

    modifier onlyTokenInReserve(address _token) {
        require(isTokenInReserve(_token), "Token must be in reserve"); // checking token is in reserve or NOT
        _;
    }

    // Sasi GetLatestPrice code
    // function getLatestPrice(address _tokenAddress) public view returns (int) {
    //     AggregatorV3Interface priceFeed;
    //     priceFeed = AggregatorV3Interface(_tokenAddress);
    //     (,int price,,,) = priceFeed.latestRoundData();
    //     return price / 1e8; //1e8 as per 8 decimals in chainlink doc 
    // }

    function getLatestPrice(address _tokenAddress) public view returns(uint)  {
        AggregatorV3Interface priceFeed;
        address tokenToUSDAddress = addressToTokenMap.getPriceFeedMap(_tokenAddress);
        priceFeed = AggregatorV3Interface(tokenToUSDAddress);
        (,int price,,,) = priceFeed.latestRoundData();
        uint256 decimal = priceFeed.decimals();
        uint currentPrice = uint(price) / (10** decimal);
        return currentPrice;
    }

    function getAmountInDollars(address _token, uint256 _amount) public view returns(uint) {
        uint totalAmountInDollars = uint(getLatestPrice(_token)) * _amount;
        return totalAmountInDollars;
    }

    function isLenderTokenOwner(address _token) internal view returns(bool) {
        address lender = msg.sender; 
        uint256 lenderAssetCount = lenderAssets[lender].length;
        for (uint i = 0; i < lenderAssetCount; i++) {
            if (lenderAssets[lender][i].user == lender && lenderAssets[lender][i].token == _token){
                return true;
            }
        }
        return false;
    }

    // function isTokenOwner(address _user, address _token) internal view returns(bool) {
    //     uint256 userAssetLength = userAssets.length;
    //     for (uint i = 0; i < userAssetLength; i++) {
    //         if (userAssets[i].user == _user && userAssets[i].token == _token){
    //             return true;
    //         }
    //     }
    //     return false;
    // }

    function isTokenInReserve(address _token) public view returns(bool) {
        uint reservesAssetsLength = reverseAssets.length;
        for(uint i=0; i < reservesAssetsLength; i++) {
            if(reverseAssets[i] == _token) {
                return true;
            }
        }
        return false;
    } 

   /************* Lender functions ************************/
    receive() external payable {}

    function lend(address _token, uint256 _amount) public payable {
        address lender = msg.sender;
        bool _usageAsCollateralEnabled = (keccak256(abi.encodePacked(_token)) == keccak256(abi.encodePacked("ETH"))) ? true: false;

        string memory _symbol = addressToTokenMap.getAddress(_token);
        
        if(!lendingConfig.isTokenInAssets(_token)) {
            lendingConfig.addAsset(
                _token,
                true,
                _usageAsCollateralEnabled,
                false, //_isfrozen
                true, //_isActive
                _symbol,
                DECIMALS,
                BORROW_THRESHOLD,
                LIQUIDATION_THRESHOLD 
            );
        }

        address ethAddress = lendingConfig.getAssetByTokenSymbol("ETH").token;

         // transfer from the lender's wallet to DeFi app or SC 
        if(_token == ethAddress) {
            // Call for ETH : from lender's wallet to SC
            (bool success, ) = payable(address(this)).call{value : _amount}("");
            require(success, "Deposit failed");

            // * Borrow is against ETH Only => Balance of lentAssets is display only
            lenderETHBalance[lender] += _amount;
        }else {
            // transfer token from the lender's wallet to DeFi app or SC 
            IERC20(_token).transferFrom(lender,address(this),_amount);
        }

        // Add to lenders assets with amount - Add to userAssets struct
        // can use the mapping instead of loop over struct array
        uint lenderAssetLength = lenderAssets[lender].length;
        for (uint i = 0; i < lenderAssetLength; i++) {
            if(lenderAssets[lender][i].token == _token) {
                // amount += lenderAssets[lender][i].lentQty;
                lenderAssets[lender][i].lentQty += _amount;
            }else {
                UserAsset memory userAsset = UserAsset({
                    user: lender,
                    token: _token,
                    lentQty: _amount,
                    borrowQty: 0,
                    lentApy: INTEREST_RATE,
                    borrowApy: 0,
                    lendStartTimeStamp: block.timestamp,
                    borrowStartTimeStamp:0,
                    borrowEndTimeStamp : 0,
                    maturityPeriod : 0
                });
                // add to lender asset list
                lenderAssets[lender].push(userAsset);

                // Push to the struct array
                // userAssets.push(userAsset);                
            }
        }

        // UserAsset memory userAsset = UserAsset({
        //     user: lender,
        //     token: _token,
        //     lentQty: amount,
        //     borrowQty: 0,
        //     apy: INTEREST_RATE,
        //     borrowRate: 0,
        //     lendStartTimeStamp: block.timestamp,
        //     borrowStartTimeStamp:0
        // });
        // add to lender asset list
        // lenderAssets[lender].push(userAsset);

        // Add to Lending Pool a.k.a reserves
        // If using a struct, use a function getCurrentReserve() and add to the struct, that increases gas cost
        reserves[_token] += _amount;
        // Add to reserve assets for enabling iteration
        reverseAssets.push(_token);
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
                return lenderAssets[_borrower][i].borrowQty;
            }
        }
        return 0;
    }

    function getLenderBalanceUSD(address _lender) external view returns(uint256){
        uint256 totalBalance;
        uint lenderAssetLength = lenderAssets[_lender].length;
        for (uint i = 0; i < lenderAssetLength; i++) {
            uint256 tokenUSDBalance = getAmountInDollars(lenderAssets[_lender][i].token, lenderAssets[_lender][i].lentQty);
            totalBalance += tokenUSDBalance;
        }
        return totalBalance;
    }

    function getLenderETHBalanceForBorrowInUSD(address _lender) public view returns(uint256) {
        address token = lendingConfig.getAssetByTokenSymbol("ETH").token;
        uint256 tokenUSDBalance = getAmountInDollars(token, lenderETHBalance[_lender]);
        return tokenUSDBalance;
    }

    function getLenderAssets(address _lender) public view returns (UserAsset[] memory) {
        return lenderAssets[_lender];
    }

    function getBorrowerAssets(address _borrower) public view returns (UserAsset[] memory) {
        return borrowerAssets[_borrower];
    }


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

        // Updating lenderETHBalance
        address ethAddress = lendingConfig.getAssetByTokenSymbol("ETH").token;
        if(_token == ethAddress) {
            lenderETHBalance[lender] -= _amount;
        }

        // transfer from contract to lender's wallet - apprval not necessary
        // (bool success, ) = payable(lender).call{value: _amount}(""); //ETH Value
        bool success = IERC20(_token).transferFrom(address(this),lender,_amount);
        require (success,"Tranfer to user's wallet not successful");
        // Emit withrawl event
        return true;
    }

    /********************* BORROW FUNCTIONS ******************/
     function Borrow(address _token, uint _amount, uint borrowDuration) public nonReentrant onlyAmountGreaterThanZero(_amount) returns(bool) {
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
        uint256 lenderETHAmount = getLenderETHBalanceForBorrowInUSD(borrower);
        uint256 amountInDoller = getAmountInDollars(_token, _amount);

        // TODO : chekcing 80% lendAmount here
        require(lenderETHAmount >= amountInDoller, "Not enough balance to borrow");

        // 2. Checking reserve[_token] >= _amount
        require(reserves[_token] >= _amount, "Not enough qty in the reserve pool to borrow");


        // 3. Get Previous borrowerAssetsLength
        uint borrowerAssetsLength =  borrowerAssets[borrower].length;

        // 4. If token exits => update borrowerAssets 
        //    else push userAssets into borrowerAssets

        uint maturityDuration;
        if(borrowDuration == 30) {
            maturityDuration = block.timestamp + BORROW_DURATION_30;
        }

        if(borrowDuration == 60) {
            maturityDuration = block.timestamp + BORROW_DURATION_60;
        }
        if(borrowDuration == 90) {
            maturityDuration = block.timestamp + BORROW_DURATION_90;
        }

        for (uint i=0 ; i < borrowerAssetsLength; i++) {
            if(borrowerAssets[borrower][i].token == _token) {

                // updateEarned(lender, _token); //100 + 0.00001 eth , 2 
                // TODO: implement 

                uint borrowerTotalAmount = borrowerAssets[borrower][i].borrowQty + _amount;
                borrowerAssets[borrower][i].borrowQty = borrowerTotalAmount;
                borrowerAssets[borrower][i].borrowApy = BORROW_RATE;
                borrowerAssets[borrower][i].borrowStartTimeStamp = block.timestamp;
                borrowerAssets[borrower][i].borrowEndTimeStamp = maturityDuration;
                borrowerAssets[borrower][i].maturityPeriod = borrowDuration;

            }else {
                UserAsset memory userAsset = UserAsset({
                    user: borrower,
                    token: _token,
                    lentQty: 0,
                    borrowQty: _amount,
                    lentApy: 0,
                    borrowApy: BORROW_RATE,
                    lendStartTimeStamp: 0,
                    borrowStartTimeStamp: block.timestamp,
                    borrowEndTimeStamp : maturityDuration,
                    maturityPeriod : borrowDuration
                });
                borrowerAssets[borrower].push(userAsset);
            }
        }

        // 5. Updating lender ETH balance for Next Borrow
        lenderETHBalance[borrower] -= _amount;  // lendingLedger => lenderETHBalance

         // Updating reserves
        reserves[_token] -= _amount;
        // TODO updating reservepool

        // 7. Token Transfer from SC to User
        // bool success = IERC20(_token).transferFrom(address(this), borrower, _amount);
        // require(success, "Tranfer to user's wallet not successful");
        return true;
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
        uint ethBalance =  getLenderETHBalanceForBorrowInUSD(_borrower);
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

      // LendingConfig lc;
        // lc.addAsset(
        //     _token, 
        //     true,
        //     false,
        //     false,
        //     true,
        //     "ETH",
        //     18,
        //     80,
        //     10
        // );

    // struct UserAsset{
    //     address user;
    //     address token;
    //     uint256 lentQty;
    //     uint256 borrowQty;
    //     uint256 interestRate;
    //     uint256 borrowRate;
    //     uint256 lendStartTimeStamp;
    //     uint256 borrowStartTimeStamp;
    // }

        // struct ReservePool {
    //     address token;
    //     uint amount;
    //     bool isfrozen;
    //     bool isActive;
    // }
    // ReservePool[] reservePool;
