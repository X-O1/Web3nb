// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {Host} from "../../contracts/Host.sol";
import {HomeNft} from "../../contracts/HomeNft.sol";
import {KeyNft} from "../../contracts/KeyNft.sol";
import {DeployHost} from "../../script/DeployHost.s.sol";
import {DeployHomeNft} from "../../script/DeployHomeNft.s.sol";
import {DeployKeyNft} from "../../script/DeployKeyNft.s.sol";

contract HomeTest is Test {
    Host host;
    HomeNft homeNft;
    KeyNft keyNft;

    function setUp() external {
        DeployHost deployHost = new DeployHost();
        host = deployHost.run();

        DeployHomeNft deployHomeNft = new DeployHomeNft();
        homeNft = deployHomeNft.run();

        DeployKeyNft deployKeyNft = new DeployKeyNft();
        keyNft = deployKeyNft.run();
    }

    function test() public {}
}
