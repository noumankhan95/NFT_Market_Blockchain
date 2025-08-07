//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {ERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Base64} from "lib/openzeppelin-contracts/contracts/utils/Base64.sol";

//Were not using setTokenuri because we are not using IPFS

contract NFT is ERC721, Ownable {
    error NFT__Not_Minted();
    struct Quote {
        string text;
        string author;
    }
    uint256 public quoteCount;
    mapping(uint256 => Quote) public quotesToIds;

    constructor() ERC721("MNFT", "NF") Ownable(msg.sender) {}

    function mintQuote(string calldata text, string calldata author) public {
        uint256 quoteId = quoteCount;
        quotesToIds[quoteId] = Quote(text, author);
        quoteCount++;
        _mint(msg.sender, quoteId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), NFT__Not_Minted());
        Quote memory q = quotesToIds[tokenId];
        string memory svg = generateSVG(q.text, q.author);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"',
                        q.text,
                        '", "description":"By - ',
                        q.author,
                        '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked(_baseURI(), json));
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function generateSVG(
        string memory quote,
        string memory author
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500">',
                    '<rect width="100%" height="100%" fill="white"/>',
                    '<text x="20" y="40" font-size="18" fill="black">',
                    quote,
                    "</text>",
                    '<text x="20" y="460" font-size="14" fill="gray">',
                    "by - ",
                    author,
                    "</text>",
                    "</svg>"
                )
            );
    }
}
