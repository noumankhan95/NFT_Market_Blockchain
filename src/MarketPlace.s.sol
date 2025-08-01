//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;
import {NFT} from "./NFT.s.sol";

contract MarketPlace is NFT {
    error MarketPlace__OnlyOwnerCanList();
    event NFTListed(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 price
    );
    event NFTDeListed(address indexed owner, uint256 indexed tokenId);
    struct Listing {
        address owner;
        uint256 price;
    }
    mapping(address => mapping(uint256 => bool)) public listings;
    mapping(uint256 => Listing) public nftListings;
    modifier onlyOwnerCanListOrDelist(uint256 tokenId) {
        require(
            _ownerOf(tokenId) == msg.sender,
            MarketPlace__OnlyOwnerCanList()
        );
        _;
    }

    function listNFT(
        uint256 _tokenId,
        uint256 _price
    ) public onlyOwnerCanListOrDelist(_tokenId) {
        listings[msg.sender][_tokenId] = true;
        nftListings[_tokenId] = Listing(msg.sender, _price);
        emit NFTListed(msg.sender, _tokenId, _price);
    }

    function delistNFT(
        uint256 _tokenId
    ) public onlyOwnerCanListOrDelist(_tokenId) {
        listings[msg.sender][_tokenId] = false;
        delete nftListings[_tokenId];
        emit NFTDeListed(msg.sender, _tokenId);
    }

    function buyNFT() public {}
}
