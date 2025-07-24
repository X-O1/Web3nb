// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/**
 * @title Key
 * @author https://github.com/X-O1
 * @notice NFT to access token-gated property lock box or front door codes.
 */

import {ERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract KeyNft is ERC721URIStorage {
    uint256 public tokenIds;
    address public contractAddress;

    constructor() ERC721("Key Nft", "KEY") {
        contractAddress = address(this);
    }

    function increment() public {
        tokenIds += 1;
    }

    function mintKey(address _guest) public returns (uint256 _newTokenId) {
        increment();

        uint256 newTokenId = tokenIds;
        _mint(_guest, newTokenId);
        _setTokenURI(newTokenId, "public/images/keyNft.jpeg");

        return newTokenId;
    }

    function getCurrentTotalSupply() external view returns (uint256 _totalSupply) {
        return tokenIds;
    }

    function getContractAddress() external view returns (address) {
        return contractAddress;
    }
}
