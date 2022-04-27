// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/inteface/inteface.sol";

contract NFTMarketplaceV1 {
    struct Order {
        address seller;
        address collection;   
        uint256 nftsId;
        address tokenAddress;
        uint256 price;
    }

    uint256 counterOrder;
    mapping (uint256 => Order) listOrders;

    function getCounterOrder() public view returns (uint256) {
        return counterOrder;
    } 

    function createOrder(address _collection, uint256 _nftsId, address _tokenAddress, uint256 _price) public {
        require(IERC721(_collection).ownerOf(_nftsId) == msg.sender, "Only NFT's owner have permit to transfer.");
        require(IERC721(_collection).isApprovedForAll(msg.sender, address(this)), "NFT need to approval.");
        IERC721(_collection).transferFrom(msg.sender, address(this), _nftsId);
        Order memory newOrder = Order(msg.sender, _collection, _nftsId, _tokenAddress, _price);
        listOrders[counterOrder] = newOrder;
        counterOrder++;
    }

    function matchOrder(uint256 _orderId) public {   
        Order memory currentOrder = listOrders[_orderId];  
        require(IERC20(currentOrder.tokenAddress).allowance(msg.sender, address(this)) != 0, 'Token need to approval.');
        require(IERC20(currentOrder.tokenAddress).balanceOf(msg.sender) >= currentOrder.price, "Buyer's balance have to greater than or equal nfts's price");
        IERC721(currentOrder.collection).transferFrom(address(this), msg.sender, currentOrder.nftsId);
        listOrders[_orderId].nftsId = 0;
    }
}