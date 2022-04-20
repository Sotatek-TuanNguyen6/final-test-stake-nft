// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTFactory is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;

    constructor() ERC721("Tuannda", "TUNA") {}

    function mintNFT(address player, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenId.increment();

        uint256 newItemId = _tokenId.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}