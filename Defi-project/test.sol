// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;

contract TEST {
    

    uint256 public immutable BORROW_THRESHOLD=50;

    function getAssetsToBorrow() public view  returns(uint){
        // Go by balance  not by tokens
        // 1. require borrower Assets for ETH
        // 2. require reserves to have borrow threshold% of ETH to lend
        // 3. remove balance of existing borrows
        // 3. spread that borrow threshold amount amongst other tokens - use Price Oracle ETH/USD -> DAI/USD (ETH->DAI) 80% - that is availbale
        

        // 1. Getting lender totalAssets => 2 ETH => 3200 USD
        // uint lendingTotalAmount = lenderTotalLandings[msg.sender];
        uint lendingTotalAmount = 3200;

        // 2. Getting Max borrow amount with borrow thresold. 
        //  ETH => Borrow thresold will be low => 60% => 3200 * 50% = 1600 => user can borrow in stable coin

        uint maxBorrowAmount = lendingTotalAmount * BORROW_THRESHOLD / 100 ;

        return maxBorrowAmount;

        // 3. Getting Reserve assets from lending pool 
        // If lendingpool reserve assets not equal to borrow amount => remove that assets from borrow list

        // 4. Creating Borrow assets array for return


    
        
        
        // uint256 availableAssets = reserveAssets.length;
        // Borrow[] memory b = new Borrow[](availableAssets);



        
    }


   


}


// Asset Address:

// ETH : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 - 10 ETH
// USDC : 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
// DAI : 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB

// Lender Address : 

// Lender1 : 0x583031D1113aD414F02576BD6afaBfb302140225
// Lender2 :  0xdD870fA1b7C4700F2BD7f44238821C26f7392148
