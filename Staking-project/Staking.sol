//SPDX-License-Identifier:MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error TransferFailed();
error NeedsMoreThanZero();
contract staking is ReentrancyGuard{

    //* 1. Creating storage variable
    // create ERC20 token for staking and reward 
    IERC20 public stakingToken;  
    IERC20 public rewardsToken;

    // Fixed reward rate
    uint256 public constant REWARD_RATE=100; //this is reward token per second
    uint256 public lastUpdateTime; // last time person staked in a SC. 
    // Its not gaurantee user wil stake all the token at once.
    // Can stake 1000 9th jan 
    // staked 200 token on 14 jan

    // Reward Per token stored : Reward will be calculated on the individual token.
    uint256 public rewardPerTokenStored;
    uint256 private totalSupply; // totalsupply of the token

    //* 2. Creating mappings
    // How much reward to be paid tu user for that userRewardPerTokenPaid
    mapping(address=>uint256) public userRewardPerTokenPaid;
    mapping(address=>uint256) public rewards; // staking rewards
    mapping(address=>uint256) public balances; // for user balance

    //* 3. Creating events
    event Staked(address indexed user,uint256 indexed amount); // emitted on staking functionlity 
    event withdrewStake(address indexed user,uint256 indexed amount);  // emitted on withdraw functionlity
    event RewardsClaimed(address indexed user,uint256 indexed amount);  // emitted on reward functionlity

    
    //* 4. Creating constructor and intialzing our TOKENS
    constructor(address _stakingToken, address _rewardsToken){
        stakingToken=IERC20(_stakingToken); // initializing token by using ERC20 interface
        rewardsToken=IERC20(_rewardsToken);
    }

    //* 5. Calculating how much reward a token gets based on how long its been in the contract
    function rewardPerToken() public view returns(uint256){
        if(totalSupply==0){
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored+(((block.timestamp-lastUpdateTime)*REWARD_RATE*1e18)/totalSupply);
    }

    function earned(address account) public view returns(uint256){
        return((balances[account]*(rewardPerToken()-userRewardPerTokenPaid[account]))/1e18)+rewards[account];
    }

    function stake(uint256 amount) external updateReward(msg.sender) nonReentrant moreThanZero(amount){
        totalSupply+=amount;
        balances[msg.sender]+=amount;
        emit Staked(msg.sender,amount);
        bool success= stakingToken.transferFrom(msg.sender,address(this),amount);
        if(!success){
            revert TransferFailed();
        }
    }

    function withdraw(uint256 amount) external nonReentrant updateReward(msg.sender){
        totalSupply-=amount;
        balances[msg.sender]-=amount;
        emit withdrewStake(msg.sender,amount);
        bool success=stakingToken.transfer(msg.sender,amount);
        if(!success){
            revert TransferFailed();
        }
    }

    function claimReward() external nonReentrant updateReward(msg.sender){
        uint256 reward= rewards[msg.sender];
        rewards[msg.sender]=0;
        emit RewardsClaimed(msg.sender,reward);
        bool success= rewardsToken.transfer(msg.sender,reward);
        if(!success){
            revert TransferFailed();
        }
    }

    modifier updateReward(address account){
        rewardPerTokenStored=rewardPerToken();
        lastUpdateTime=block.timestamp;
        rewards[account]=earned(account);
        userRewardPerTokenPaid[account]= rewardPerTokenStored;
        _;
    }

    modifier moreThanZero(uint256 amount){
        if(amount==0){
            revert NeedsMoreThanZero();
        }
        _;
    }
    function getStaked(address account) public view returns(uint256){
        return balances[account];
    }
}