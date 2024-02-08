// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {Host} from "../../contracts/Host.sol";
import {HomeNft} from "../../contracts/HomeNft.sol";
import {KeyNft} from "../../contracts/KeyNft.sol";
import {DeployHost} from "../../script/DeployHost.s.sol";
import {DeployKeyNft} from "../../script/DeployKeyNft.s.sol";

contract HomeTest is Test {
    Host host;
    KeyNft keyNft;

    address public HOST = makeAddr("HOST");

    function setUp() external {
        DeployHost deployHost = new DeployHost();
        host = deployHost.run();

        DeployKeyNft deployKeyNft = new DeployKeyNft();
        keyNft = deployKeyNft.run();

        vm.deal(HOST, 1 ether);
    }

    function testAddingProperty() public {
        vm.prank(HOST);
        host.addProperty(false, true, true, false, "Las Vegas, NV", 1, 1, 1, 10);
        vm.prank(HOST);
        host.addProperty(false, true, true, false, "Las Vegas, NV", 1, 1, 1, 10);

        assertEq(host.getCurrentNumOfPropertiesListed(), 2);
    }

    function testDeletingProperty() public {
        vm.prank(HOST);
        bytes32 propertyId = host.addProperty(false, true, true, false, "Las Vegas, NV", 1, 1, 1, 10);

        vm.prank(HOST);
        host.deleteProperty(propertyId);

        vm.prank(HOST);
        host.addProperty(false, true, true, false, "Las Vegas, NV", 1, 1, 1, 10);

        assertEq(host.getCurrentNumOfPropertiesListed(), 1);
    }
}
