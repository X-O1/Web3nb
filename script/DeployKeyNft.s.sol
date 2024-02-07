// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {KeyNft} from "../contracts/KeyNft.sol";

contract DeployKeyNft is Script {
    function run() external returns (KeyNft) {
        vm.startBroadcast();
        KeyNft keyNft = new KeyNft();
        vm.stopBroadcast();

        return keyNft;
    }
}
