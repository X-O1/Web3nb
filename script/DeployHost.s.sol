// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Host} from "../contracts/Host.sol";

contract DeployHost is Script {
    function run() external returns (Host) {
        vm.startBroadcast();
        Host host = new Host();
        vm.stopBroadcast();

        return host;
    }
}
