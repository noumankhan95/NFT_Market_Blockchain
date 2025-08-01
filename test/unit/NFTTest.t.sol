//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {Test} from "forge-std/Test.sol";
import {DeployContract} from "../../script/Deploy.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {NFT} from "../../src/NFT.s.sol";
import {MarketPlace} from "../../src/MarketPlace.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {console2} from "forge-std/console2.sol";

contract NFTTest is Test {
    NFT public nft;
    MarketPlace public market;
    HelperConfig.NetworkConfig public config;

    function setUp() public {
        DeployContract deploy = new DeployContract();
        (nft, market, config) = deploy.run();
    }

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
}
