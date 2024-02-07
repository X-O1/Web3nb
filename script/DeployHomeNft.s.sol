// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {HomeNft} from "../contracts/HomeNft.sol";

contract DeployHomeNft is Script {
    function run() external returns (HomeNft) {
        vm.startBroadcast();
        HomeNft homeNft = new HomeNft();
        vm.stopBroadcast();

        return homeNft;
    }
}
