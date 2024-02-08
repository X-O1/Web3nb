// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {Guest} from "../../contracts/Guest.sol";
import {Host} from "../../contracts/Host.sol";
import {HomeNft} from "../../contracts/HomeNft.sol";
import {KeyNft} from "../../contracts/KeyNft.sol";
import {DeployHost} from "../../script/DeployHost.s.sol";
import {DeployKeyNft} from "../../script/DeployKeyNft.s.sol";

contract GuestTest is Test {
    Guest guest;
    Host host;

    address public GUEST = makeAddr("GUEST");
    address public HOST = makeAddr("HOST");

    function setUp() external {
        vm.deal(GUEST, 1 ether);
        vm.deal(HOST, 1 ether);
    }
}
