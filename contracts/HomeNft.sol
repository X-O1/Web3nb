// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/**
 * @title Home Nft
 * @author https://github.com/X-O1
 * @notice NFT that represents the listing property.
 */

import {ERC721URIStorage} from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract HomeNft is ERC721URIStorage {
    uint256 public tokenIds;

    constructor() ERC721("Home nft", "HOME") {}

    function increment() public {
        tokenIds += 1;
    }

    function mint(string memory _tokenURI) public returns (uint256 _newTokenId) {
        increment();

        uint256 newTokenId = tokenIds;
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);

        return newTokenId;
    }

    function getCurrentTotalSupply() external view returns (uint256 _totalSupply) {
        return tokenIds;
    }
}
