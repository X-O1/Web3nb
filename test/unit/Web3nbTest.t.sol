// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {Web3nb} from "../../contracts/Web3nb.sol";
import {KeyNft} from "../../contracts/KeyNft.sol";
import {DeployWeb3nb} from "../../script/DeployWeb3nb.s.sol";
import {DeployKeyNft} from "../../script/DeployKeyNft.s.sol";

// contract Web3nbTest is Test {
//     Web3nb web3nb;
//     KeyNft keyNft;

//     address public HOST = makeAddr("HOST");
//     address public GUEST = makeAddr("GUEST");
//     address keyNftContractAddress = 0x90193C961A926261B756D1E5bb255e67ff9498A1;

//     function setUp() external {
//         DeployKeyNft deployKeyNft = new DeployKeyNft();
//         keyNft = deployKeyNft.run();

//         DeployWeb3nb deployWeb3nb = new DeployWeb3nb(keyNftContractAddress);
//         web3nb = deployWeb3nb.run();

//         vm.deal(HOST, 10 ether);
//         vm.deal(GUEST, 10 ether);
//     }

//     modifier propertyListed() {
//         vm.prank(HOST);
//         web3nb.addProperty(1 ether);
//         _;
//     }

//     function testDeploymentScripts() public {}

//     function testAddingProperty() public {
//         vm.prank(HOST);
//         web3nb.addProperty(1 ether);
//         vm.prank(HOST);
//         web3nb.addProperty(1 ether);

//         assertEq(web3nb.getCurrentNumOfPropertiesListed(), 2);
//     }

//     function testDeletingProperty() public {
//         vm.prank(HOST);
//         bytes32 propertyId = web3nb.addProperty(1 ether);

//         vm.prank(HOST);
//         web3nb.getListOfAllListedProperties();

//         vm.prank(HOST);
//         web3nb.deleteProperty(propertyId);

//         web3nb.getListOfAllListedProperties();

//         vm.prank(HOST);
//         web3nb.addProperty(1 ether);

//         vm.expectRevert();
//         vm.prank(GUEST);
//         web3nb.deleteProperty(propertyId);

//         assertEq(web3nb.getCurrentNumOfPropertiesListed(), 1);
//     }

//     function testBookingRequest() public {
//         vm.prank(HOST);
//         bytes32 propertyId = web3nb.addProperty(1 ether);

//         uint256 depositAmount = web3nb._calculatePropertyTotalDepositAmount(propertyId, 5);
//         vm.prank(GUEST);
//         web3nb.requestBooking{value: depositAmount}(propertyId, 5);
//     }

//     function testApprovingBookingRequestAndMintingKeyNftUponApproval() public propertyListed {
//         vm.prank(HOST);
//         bytes32 propertyId = web3nb.addProperty(1 ether);
//         uint256 depositAmount = web3nb._calculatePropertyTotalDepositAmount(propertyId, 5);
//         vm.prank(GUEST);
//         bytes32 bookingId = web3nb.requestBooking{value: depositAmount}(propertyId, 5);

//         vm.prank(HOST);
//         uint256 keyNftId = web3nb.approveBookingRequest(bookingId);

//         assertEq(keyNft.ownerOf(keyNftId), GUEST);

//         vm.prank(HOST);
//         bytes32 propertyId2 = web3nb.addProperty(1 ether);
//         uint256 depositAmount2 = web3nb._calculatePropertyTotalDepositAmount(propertyId2, 5);
//         vm.prank(GUEST);
//         bytes32 bookingId2 = web3nb.requestBooking{value: depositAmount2}(propertyId2, 5);

//         vm.prank(HOST);
//         uint256 keyNftId2 = web3nb.approveBookingRequest(bookingId2);

//         assertEq(keyNft.ownerOf(keyNftId2), GUEST);
//     }

//     function testDecliningBookingRequest() public {
//         vm.prank(HOST);
//         bytes32 propertyId = web3nb.addProperty(1 ether);
//         uint256 depositAmount = web3nb._calculatePropertyTotalDepositAmount(propertyId, 5);
//         vm.prank(GUEST);
//         bytes32 bookingId = web3nb.requestBooking{value: depositAmount}(propertyId, 5);

//         assertEq(web3nb.getDepositBalance(GUEST, propertyId), depositAmount);

//         vm.prank(HOST);
//         web3nb.declineBookingRequest(bookingId);

//         assertEq(web3nb.getDepositBalance(GUEST, propertyId), 0);
//     }

//     function testCancelingBookingRequest() public {
//         vm.prank(HOST);
//         bytes32 propertyId = web3nb.addProperty(1 ether);
//         uint256 depositAmount = web3nb._calculatePropertyTotalDepositAmount(propertyId, 5);
//         vm.prank(GUEST);
//         bytes32 bookingId = web3nb.requestBooking{value: depositAmount}(propertyId, 5);

//         assertEq(web3nb.getDepositBalance(GUEST, propertyId), depositAmount);

//         vm.prank(GUEST);
//         web3nb.cancelBookingRequest(bookingId);

//         assertEq(web3nb.getDepositBalance(GUEST, propertyId), 0);
//     }
// }
