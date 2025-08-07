//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MockUSDC} from "../test/mock/Usdc.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address usdc;
        address account;
    }
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 public constant ANVIL_CHAIN_ID = 31337;
    address private constant BURNER_WALLET =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function run() public {}

    mapping(uint256 => NetworkConfig) public configs;

    function getActiveNetworkChainId()
        public
        view
        returns (NetworkConfig memory)
    {
        if (configs[block.chainid].usdc == address(0)) {
            revert("Invalid Chain");
        }
        return configs[block.chainid];
    }

    constructor() {
        configs[ETH_MAINNET_CHAIN_ID] = getEthChain();
        configs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaChain();
        configs[ANVIL_CHAIN_ID] = getAnvilChain();
    }

    function getEthChain() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({usdc: address(0), account: address(0)});
    }

    function getSepoliaChain() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({usdc: address(0), account: address(0)});
    }

    function getAnvilChain() internal returns (NetworkConfig memory) {
        vm.startBroadcast(BURNER_WALLET);
        MockUSDC usdc = new MockUSDC();
        usdc.mint(BURNER_WALLET, 100e18); // Mint 100 USDC to the burner wallet
        vm.stopBroadcast();
        return NetworkConfig({usdc: address(usdc), account: BURNER_WALLET});
    }
}
