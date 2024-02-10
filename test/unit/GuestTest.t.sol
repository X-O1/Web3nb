// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {Guest} from "../../contracts/Guest.sol";
import {Host} from "../../contracts/Host.sol";
import {HomeNft} from "../../contracts/HomeNft.sol";
import {KeyNft} from "../../contracts/KeyNft.sol";
import {DeployHost} from "../../script/DeployHost.s.sol";
import {DeployKeyNft} from "../../script/DeployKeyNft.s.sol";
import {DeployGuest} from "../../script/DeployGuest.s.sol";

contract GuestTest is Test {
    Guest guest;
    Host host;
    KeyNft keyNft;

    address public GUEST = payable(makeAddr("GUEST"));
    address public HOST = payable(makeAddr("HOST"));
    address hostContractAddress = 0x90193C961A926261B756D1E5bb255e67ff9498A1;
    address keyNftContractAddress = 0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496;

    function setUp() external {
        DeployHost deployHost = new DeployHost();
        host = deployHost.run();

        DeployKeyNft deployKeyNft = new DeployKeyNft();
        keyNft = deployKeyNft.run();

        DeployGuest deployGuest = new DeployGuest(hostContractAddress, keyNftContractAddress);
        guest = deployGuest.run();

        vm.deal(GUEST, 10 ether);
        vm.deal(HOST, 1 ether);
    }

    modifier propertyListed() {
        vm.prank(HOST);
        host.addProperty(false, true, true, false, "Las Vegas, NV", 1, 1, 1);
        _;
    }

    function testDeploymentScripts() public {}

    function testBookingRequest() public propertyListed {
        vm.prank(HOST);
        bytes32 propertyId = host.addProperty(false, true, true, false, "Las Vegas, NV", 1, 1, 1 ether);
        uint256 depositAmount = guest.calculatePropertyTotalDepositAmount(propertyId, 5);
        vm.prank(GUEST);
        guest.requestBooking{value: depositAmount}(propertyId, 1, 5);
    }
}
