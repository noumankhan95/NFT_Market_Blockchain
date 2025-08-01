//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;
import {HelperConfig} from "./HelperConfig.s.sol";
import {Script} from "forge-std/Script.sol";
import {NFT} from "../src/NFT.s.sol";
import {MarketPlace} from "../src/MarketPlace.s.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DeployContract is Script {
    function run()
        public
        returns (NFT, MarketPlace, HelperConfig.NetworkConfig memory)
    {
        HelperConfig netconfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = netconfig
            .getActiveNetworkChainId();
        vm.startBroadcast(config.account);
        MarketPlace market = new MarketPlace(ERC20(config.usdc));
        NFT nft = new NFT();
        nft.transferOwnership(address(market));
        vm.stopBroadcast();

        return (nft, market, config);
    }
}
