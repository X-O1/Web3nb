// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Web3nb} from "../contracts/Web3nb.sol";
import {KeyNft} from "../contracts/KeyNft.sol";

contract DeployWeb3nb is Script {
    address public keyNftContractAddress;

    constructor(address _keyNftContractAddress) {
        keyNftContractAddress = _keyNftContractAddress;
    }

    function run() external returns (Web3nb) {
        vm.startBroadcast();
        Web3nb web3nb = new Web3nb(keyNftContractAddress);
        vm.stopBroadcast();

        return web3nb;
    }
}
