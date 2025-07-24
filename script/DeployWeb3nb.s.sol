// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Web3nb} from "../contracts/Web3nb.sol";
import {KeyNft} from "../contracts/KeyNft.sol";

contract DeployWeb3nb is Script {
    address public keyNftContractAddress;


    constructor() {
    }

    function run() external returns (Web3nb) {
        vm.startBroadcast();

        //Deploy Key Nft
        KeyNft keyNft = new KeyNft();
        keyNftContractAddress = address(keyNft);
        //Deploy web3nb contract
        Web3nb web3nb = new Web3nb(keyNftContractAddress);
        vm.stopBroadcast();
        return web3nb;
    }
}
