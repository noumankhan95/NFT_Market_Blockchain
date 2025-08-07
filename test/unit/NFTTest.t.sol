//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {Test} from "forge-std/Test.sol";
import {DeployContract} from "../../script/Deploy.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {NFT} from "../../src/NFT.s.sol";
import {MarketPlace} from "../../src/MarketPlace.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {console2} from "forge-std/console2.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Base64} from "lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract NFTTest is Test {
    NFT public nft;
    MarketPlace public market;
    HelperConfig.NetworkConfig public config;

    function setUp() public {
        DeployContract deploy = new DeployContract();
        (nft, market, config) = deploy.run();
    }

    //NFT Contract Tests
    modifier mintDummyNFT() {
        string
            memory quoteText = "Injustice Anywhere is a Threat To Justice EveryWhere";
        string memory author = "Nouman";
        vm.prank(config.account);
        nft.mintQuote(quoteText, author);
        _;
    }

    function testNFTnameAndSymbolisCorrect() public {
        bytes32 name = keccak256(abi.encode(nft.name()));
        bytes32 nftname = keccak256(abi.encode(bytes("MNFT")));
        assert(name == nftname);
    }

    function testCanMintNFT() public mintDummyNFT {
        assert(nft.ownerOf(0) == config.account);
    }

    function testIsEventEmitted() public {
        string
            memory quoteText = "Injustice Anywhere is a Threat To Justice EveryWhere";
        string memory author = "Nouman";

        vm.recordLogs();

        nft.mintQuote(quoteText, author);

        Vm.Log[] memory logs = vm.getRecordedLogs();

        require(logs.length > 0, "No logs were emitted");

        console2.log("Event Topic 0 (signature hash):");
        console2.logBytes32(logs[0].topics[0]);

        bytes32 expectedEventSig = keccak256("Minted(address,uint256)");
        if (logs[0].topics[0] == expectedEventSig) {
            console2.log(" Minted event was emitted.");
        } else {
            console2.log(" Unexpected event emitted.");
        }
    }

    function testGeneratedURIisCorrect() public {
        string
            memory quoteText = "Injustice Anywhere is a Threat To Justice EveryWhere";
        string memory author = "Nouman";
        vm.prank(config.account);
        nft.mintQuote(quoteText, author);
        string memory uri = nft.tokenURI(0);
        string memory expectedSVG = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500">',
                '<rect width="100%" height="100%" fill="white"/>',
                '<text x="20" y="40" font-size="18" fill="black">',
                quoteText,
                "</text>",
                '<text x="20" y="460" font-size="14" fill="gray">',
                "by - ",
                author,
                "</text>",
                "</svg>"
            )
        );
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"',
                        quoteText,
                        '", "description":"By - ',
                        author,
                        '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(expectedSVG)),
                        '"}'
                    )
                )
            )
        );
    
        assert(
            keccak256(abi.encodePacked(uri)) ==
                keccak256((abi.encodePacked("data:application/json;base64,", json)))
        );
    }

    //function MarketPlace Tests

    function testIsListed() public {
        string
            memory quoteText = "Injustice Anywhere is a Threat To Justice EveryWhere";
        string memory author = "Nouman";
        vm.startPrank(config.account);
        nft.mintQuote(quoteText, author);
        nft.approve(address(market), 0);
        market.listNFT(0, 10e18, address(nft));
        MarketPlace.Listing memory listing = market.getListings(
            0,
            address(nft)
        );

        assert(listing.owner == config.account);
        assert(listing.price == 10e18);
    }

    function testcanDelist() public {
        string
            memory quoteText = "Injustice Anywhere is a Threat To Justice EveryWhere";
        string memory author = "Nouman";
        vm.startPrank(config.account);
        nft.mintQuote(quoteText, author);
        nft.approve(address(market), 0);
        market.listNFT(0, 10e18, address(nft));
        MarketPlace.Listing memory listing = market.getListings(
            0,
            address(nft)
        );

        assert(listing.owner == config.account);
        assert(listing.price == 10e18);
        market.delistNFT(0, address(nft));
        MarketPlace.Listing memory delisting = market.getListings(
            0,
            address(nft)
        );
        assert(delisting.owner == address(0));
        assert(delisting.price == 0);
    }

    function testcanbuyNft() public {
        string
            memory quoteText = "Injustice Anywhere is a Threat To Justice EveryWhere";
        string memory author = "Nouman";
        vm.startPrank(config.account);
        nft.mintQuote(quoteText, author);
        nft.approve(address(market), 0);
        market.listNFT(0, 10e18, address(nft));
        vm.stopPrank();
        address buyer = makeAddr("buyer");
        ERC20Mock(config.usdc).mint(buyer, 30e18);
        vm.startPrank(buyer);
        ERC20Mock(config.usdc).approve(address(market), 10e18);
        market.buyNFT(0, address(nft));
        vm.stopPrank();
        assert(nft.ownerOf(0) == buyer);
    }

    function testcanUpdateListing() public {
        string
            memory quoteText = "Injustice Anywhere is a Threat To Justice EveryWhere";
        string memory author = "Nouman";
        vm.startPrank(config.account);
        nft.mintQuote(quoteText, author);
        nft.approve(address(market), 0);
        market.listNFT(0, 10e18, address(nft));
        market.updatePricing(0, address(nft), 20e18);

        vm.stopPrank();
        MarketPlace.Listing memory listing = market.getListings(
            0,
            address(nft)
        );
        assert(listing.price == 20e18);
    }
}
