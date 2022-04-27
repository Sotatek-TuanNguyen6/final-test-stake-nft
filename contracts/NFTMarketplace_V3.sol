// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/inteface/inteface.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract NFTMarketplaceV3 {
    using SafeMath for uint256;
    struct Order {
        address seller;
        address collection;   
        uint256 nftsId;
        address tokenAddress;
        uint256 price;   
        bool isSold;   
    }

    struct Stake {
        uint256 tokenId;
        uint256 amount;
        uint256 timestamp;
        uint256 hashrate;
    }

    uint256 counterOrder;
    mapping (uint256 => Order) listOrders;
    address treasury;
    uint256 fee;
    address owner;
    uint256 public rewardPerTokenStored;
    uint256 public lastUpdateTime;
    uint256 public periodFinish;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public userRewardPerTokenPaid;
    // map staker address to stake details
    mapping(address => Stake) public stakes;
    // map staker to total staking time 
    mapping(address => uint256) public stakingTime;
    mapping(address => uint256) private _balances;
    uint256 private countStaker;
    IERC721 public parentNFT;
    IERC20 public rewardsToken;
    IERC721 public stakingToken;

    function initializer() public {
        owner = msg.sender;
        parentNFT = IERC721(0xd9145CCE52D386f254917e481eB44e9943F39138);
        periodFinish = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Dont have permission!');
        _;
    }

    function getCounterOrder() public view returns (uint256) {
        return counterOrder;
    } 

    function createOrder(address _collection, uint256 _nftsId, address _tokenAddress, uint256 _price) external {
        require(IERC721(_collection).ownerOf(_nftsId) == msg.sender, "Only NFT's owner have permit to transfer.");
        require(IERC721(_collection).isApprovedForAll(msg.sender, address(this)), "NFT need to approval.");
        IERC721(_collection).transferFrom(msg.sender, address(this), _nftsId);
        Order memory newOrder = Order(msg.sender, _collection, _nftsId, _tokenAddress, _price, false);
        listOrders[counterOrder] = newOrder;
        counterOrder++;
    }

    function matchOrder(uint256 _orderId) external {   
        require(isOrderExists(_orderId), "Order exitsed");    
        Order memory currentOrder = listOrders[_orderId];  
        require(IERC20(currentOrder.tokenAddress).allowance(msg.sender, address(this)) != 0, 'Token need to approval.');
        require(IERC20(currentOrder.tokenAddress).balanceOf(msg.sender) >= currentOrder.price, "Buyer's balance have to greater than or equal nfts's price");
        IERC721(currentOrder.collection).transferFrom(address(this), msg.sender, currentOrder.nftsId);
        IERC20(currentOrder.tokenAddress).transferFrom(msg.sender, treasury, (currentOrder.price * (100 + fee) / 100));
        IERC20(currentOrder.tokenAddress).transferFrom(treasury, currentOrder.seller, (currentOrder.price * (100 - fee) / 100));
        listOrders[_orderId].isSold = true;
    }

    function cancelOrder(uint256 _orderId) external {
        require(!isOrderExists(_orderId), "Order not exitsed");
        Order storage currentOrder = listOrders[_orderId];
        IERC721(currentOrder.collection).transferFrom(address(this), msg.sender, currentOrder.nftsId);
        listOrders[_orderId].isSold = false;
        counterOrder--;
    }

    function addTreasury(address _treasuryAddress) onlyOwner public {
        treasury = _treasuryAddress;
    }

    function getTreasury() view public returns (address){
        return treasury;
    }

    function setFee(uint256 _fee) onlyOwner  public {
        fee = _fee;
    }

    function getFee() view public returns (uint256){
        return fee;
    }

    function isOrderExists(uint256 key) public view returns (bool) {
        if(listOrders[key].nftsId != 0) {
            return true;
        } 
        return false;
    }

    function stake(uint256 _tokenId, uint256 _amount, uint256 _hashrate) public updateReward(msg.sender) {
        stakes[msg.sender] = Stake(_tokenId, _amount, block.timestamp, _hashrate); 
        parentNFT.transferFrom(msg.sender, address(this), _tokenId);
        countStaker++;
    } 

    function unstake() public updateReward(msg.sender) {
        parentNFT.transferFrom(address(this), msg.sender, stakes[msg.sender].tokenId);
        stakingTime[msg.sender] += (block.timestamp - stakes[msg.sender].timestamp);
        delete stakes[msg.sender];
        countStaker--;
        getReward();
    }      

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken(account);
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken(address account) public view returns (uint256) {
        if (countStaker == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(lastTimeRewardApplicable().sub(lastUpdateTime).mul(stakes[account].hashrate).mul(1e18).div(countStaker));
    }

    function earned(address account) public view returns (uint256) {
        return _balances[account].mul(rewardPerToken(account).sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }
}