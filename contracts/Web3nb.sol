// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Host
 * @author https://github.com/X-O1
 * @notice This contract manages adding property details, listings, and bookings.
 */

import {KeyNft} from "./KeyNft.sol";

contract Web3nb {
    // ERRORS
    error Web3nb__PropertyDoesNotExist();
    error Web3nb__NotPropertyOwner();
    error Web3nb__TransactionFailed();

    // TYPE DECLARATIONS
    struct PropertyDetails {
        address owner;
        bytes32 propertyId;
        uint256 keyNftId;
        uint256 pricePerNight;
    }

    struct BookingRequestDetails {
        address guest;
        bytes32 propertyId;
        bytes32 bookingId;
        uint256 daysBooked;
        uint256 depositAmount;
        RequestStatus status;
    }

    struct RequestStatus {
        bool approved;
        bool declined;
        bool pending;
    }

    // EVENTS
    event PropertyAdded(address indexed host, bytes32 indexed propertyId);
    event PropertyDeleted(address indexed host, bytes32 indexed propertyId);
    event BookingRequested(
        address indexed guest, bytes32 indexed propertyId, uint256 indexed daysBooked, uint256 depositAmount
    );
    event BookingApproved(bytes32 indexed propertyId, bytes32 indexed bookingId);

    // MODIFIERS
    modifier onlyPropertyOwner(bytes32 _propertyId) {
        if (msg.sender != propertyDetails[_propertyId].owner) {
            revert Web3nb__NotPropertyOwner();
        }
        _;
    }

    // STATE VARIABLES
    KeyNft keyNftContract;
    uint256 public currentNumOfProperties;
    PropertyDetails[] public allPropertiesListed;

    mapping(bytes32 propertyId => PropertyDetails propertyDetails) public propertyDetails;
    // mapping(address guest => mapping(bytes32 propertyId => BookingRequestDetails bookingRequestDetails)) public
    //     guestBookingRequests;
    mapping(address guest => mapping(bytes32 propertyId => uint256 deposit)) public bookingDeposits;

    mapping(bytes32 bookingId => BookingRequestDetails requestDetails) public propertyRequests;

    // FUNCTIONS
    receive() external payable {}

    constructor(address _keyNftAddress) {
        keyNftContract = KeyNft(_keyNftAddress);
    }

    function addProperty(uint256 _pricePerNight) public returns (bytes32 _propertyId) {
        _incrementNumOfPropertiesListed();
        bytes32 propertyId = _generatePropertyId(currentNumOfProperties);

        _addPropertyDetails(msg.sender, propertyId, _pricePerNight);

        emit PropertyAdded(msg.sender, propertyId);
        return propertyId;
    }

    function _addPropertyDetails(address _owner, bytes32 _propertyId, uint256 _pricePerNight) internal {
        PropertyDetails storage listing = propertyDetails[_propertyId];

        listing.owner = _owner;
        listing.propertyId = _propertyId;
        listing.pricePerNight = _pricePerNight;

        propertyDetails[_propertyId] = listing;
        allPropertiesListed.push(listing);
    }

    function _generatePropertyId(uint256 _currentNumOfProperties) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(_currentNumOfProperties, block.timestamp, msg.sender));
    }

    function _incrementNumOfPropertiesListed() internal {
        currentNumOfProperties += 1;
    }

    function deleteProperty(bytes32 _propertyId) public onlyPropertyOwner(_propertyId) {
        delete propertyDetails[_propertyId];

        _decreaseNumOfPropertiesListed();
        _searchListOfAllPropertiesAndDelete(_propertyId);
        emit PropertyDeleted(msg.sender, _propertyId);
    }

    function _searchListOfAllPropertiesAndDelete(bytes32 _propertyId) internal {
        for (uint256 i = 0; i < allPropertiesListed.length; i++) {
            if (allPropertiesListed[i].propertyId == _propertyId) {
                uint256 lastIndex = allPropertiesListed.length - 1;
                if (i != lastIndex) {
                    allPropertiesListed[i] = allPropertiesListed[lastIndex];
                }
                allPropertiesListed.pop();
                return;
            }
        }
    }

    function _decreaseNumOfPropertiesListed() internal {
        currentNumOfProperties -= 1;
    }

    function requestBooking(bytes32 _propertyId, uint256 _daysBooked) public payable returns (bytes32 _bookingId) {
        uint256 totalDeposit = _calculatePropertyTotalDepositAmount(_propertyId, _daysBooked);
        require(msg.value == totalDeposit, "Send exact deposit amount");

        bookingDeposits[msg.sender][_propertyId] += msg.value;

        bytes32 bookingId = _generateBookingId(_daysBooked, _propertyId);
        _addBookingRequestDetails(msg.sender, _propertyId, bookingId, _daysBooked, msg.value);

        emit BookingRequested(msg.sender, _propertyId, msg.value, _daysBooked);
        return (bookingId);
    }

    function _generateBookingId(uint256 _daysBooked, bytes32 _propertyId) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(_daysBooked, _propertyId, block.timestamp, msg.sender, msg.value));
    }

    function _addBookingRequestDetails(
        address _guest,
        bytes32 _propertyId,
        bytes32 _bookingId,
        uint256 _daysBooked,
        uint256 _depositAmount
    ) internal {
        BookingRequestDetails storage bookingDetails = propertyRequests[_bookingId];
        bookingDetails.guest = _guest;
        bookingDetails.propertyId = _propertyId;
        bookingDetails.daysBooked = _daysBooked;
        bookingDetails.depositAmount = _depositAmount;
        bookingDetails.status.pending = true;
        bookingDetails.status.approved = false;
        bookingDetails.status.declined = false;
    }

    function _calculatePropertyTotalDepositAmount(bytes32 _propertyId, uint256 _daysBooked)
        public
        view
        returns (uint256 _depositAmount)
    {
        uint256 pricePerDay = propertyDetails[_propertyId].pricePerNight;

        uint256 totalDeposit = _daysBooked * pricePerDay;

        return totalDeposit;
    }

    function approveBookingRequest(bytes32 _bookingId) public {
        BookingRequestDetails storage request = propertyRequests[_bookingId];
        require(msg.sender == propertyDetails[request.propertyId].owner, "Not Property owner");
        require(request.status.pending == true, "Request no longer pending");
        require(
            bookingDeposits[request.guest][request.propertyId] >= request.depositAmount, "Guest did not make deposit"
        );
        bookingDeposits[request.guest][request.propertyId] -= request.depositAmount;

        request.status.approved = true;
        request.status.declined = false;
        request.status.pending = false;

        _mintKey(request.guest, request.propertyId);

        (bool success,) = payable(msg.sender).call{value: request.depositAmount}("");
        if (!success) {
            revert Web3nb__TransactionFailed();
        }

        emit BookingApproved(request.propertyId, _bookingId);
    }

    function _mintKey(address _guest, bytes32 _propertyId) internal {
        PropertyDetails storage listing = propertyDetails[_propertyId];
        uint256 keyNFtId = keyNftContract.mintKey(_guest);
        listing.keyNftId = keyNFtId;
    }

    // VIEW
    function getCurrentNumOfPropertiesListed() external view returns (uint256 _numOfListings) {
        return currentNumOfProperties;
    }

    function getPropertyDetails(bytes32 _propertytId) external view returns (PropertyDetails memory _propertyDetails) {
        return propertyDetails[_propertytId];
    }

    function getListOfAllListedProperties() external view returns (PropertyDetails[] memory _allListedProperties) {
        return allPropertiesListed;
    }
}
