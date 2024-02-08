// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Host} from "../contracts/Host.sol";
import {KeyNft} from "../contracts/KeyNft.sol";

contract DeployHost is Script {
    address keyNft;

    function run() external returns (Host) {
        vm.startBroadcast();
        Host host = new Host(keyNft);
        vm.stopBroadcast();

        return host;
    }
}
