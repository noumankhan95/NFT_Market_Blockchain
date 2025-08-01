//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract MarketPlace {
    error MarketPlace__OnlyOwnerCanList();
    event NFTListed(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 price
    );
    event NFTDeListed(address indexed owner, uint256 indexed tokenId);
    event NFTUpdated(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 indexed newPrice
    );

    struct Listing {
        address owner;
        uint256 price;
    }
    mapping(address => mapping(uint256 => Listing)) public listings;
    ERC20 public paymentToken;
    modifier onlyOwnerCanListOrDelist(uint256 tokenId, address _nftContract) {
        require(
            IERC721(_nftContract).ownerOf(tokenId) == msg.sender,
            MarketPlace__OnlyOwnerCanList()
        );
        _;
    }

    constructor(ERC20 _paymentToken) {
        paymentToken = _paymentToken;
    }

    function listNFT(
        uint256 _tokenId,
        uint256 _price,
        address _nftContract
    ) public onlyOwnerCanListOrDelist(_tokenId, _nftContract) {
        if (_price <= 0) {
            revert("Price must be greater than zero");
        }
        require(
            IERC721(_nftContract).getApproved(_tokenId) == address(this),
            "NFT not approved for marketplace"
        );
        listings[_nftContract][_tokenId] = Listing(msg.sender, _price);
        emit NFTListed(msg.sender, _tokenId, _price);
    }

    function delistNFT(
        uint256 _tokenId,
        address _nftContract
    ) public onlyOwnerCanListOrDelist(_tokenId, _nftContract) {
        delete listings[_nftContract][_tokenId];
        emit NFTDeListed(msg.sender, _tokenId);
    }

    function buyNFT(uint256 _tokenid, address _nftContract) public {
        uint256 price = listings[_nftContract][_tokenid].price;
        address owner = listings[_nftContract][_tokenid].owner;
        bool success = paymentToken.transferFrom(owner, msg.sender, price);
        if (!success) {
            revert("Payment failed");
        }
        IERC721(_nftContract).safeTransferFrom(owner, msg.sender, _tokenid);
        delete listings[_nftContract][_tokenid];
    }

    function updatePricing(
        uint256 _tokenId,
        address _nftContract,
        uint256 _newPrice
    ) public onlyOwnerCanListOrDelist(_tokenId, _nftContract) {
        if (_newPrice <= 0) {
            revert("New price must be greater than zero");
        }
        listings[_nftContract][_tokenId].price = _newPrice;
        emit NFTUpdated(msg.sender, _tokenId, _newPrice);
    }
}
