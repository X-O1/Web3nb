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

    // TYPE DECLARATIONS
    struct PropertyDetails {
        address payable owner;
        bytes32 propertyId;
        uint256 keyNftTokenId;
        uint256 pricePerNight;
        bool bookingApproved;
        bool house;
        bool apartment;
        bool entirePlace;
        bool room;
        string location;
        uint256 bedrooms;
        uint256 bathrooms;
    }

    struct BookingDetails {
        address guest;
        bytes32 propertyId;
        uint256 numberOfAdditionalGuests;
        uint256 daysBooked;
        uint256 depositAmount;
    }

    struct PropertyStatus {
        bool bookingRequestPending;
        bool bookingApproved;
    }

    struct Listing {
        PropertyDetails propertyDetails;
        BookingDetails bookingDetails;
        PropertyStatus propertyStatus;
    }

    // Re-Archetype data structures ^^^

    // EVENTS
    event PropertyAdded(address indexed host, bytes32 indexed propertyId);
    event PropertyDeleted(address indexed host, bytes32 indexed propertyId);
    event BookingRequested(
        address indexed guest, bytes32 indexed propertyId, uint256 indexed daysBooked, uint256 depositAmount
    );

    // MODIFIERS
    modifier onlyPropertyOwner(bytes32 _propertyId) {
        if (msg.sender != propertyDetailsByPropertyId[_propertyId].owner) {
            revert Web3nb__NotPropertyOwner();
        }
        _;
    }

    // STATE VARIABLES
    KeyNft keyNftContract;
    uint256 public currentNumOfProperties;
    PropertyDetails[] public allPropertiesListed;

    mapping(bytes32 _propertyId => PropertyDetails _propertyDetails) public propertyDetailsByPropertyId;
    mapping(address _guest => mapping(bytes32 _propertyId => BookingDetails _bookingDetails)) public bookingRequests;
    mapping(address _guest => mapping(bytes32 _propertyId => uint256 _deposit)) public bookingDeposits;

    // FUNCTIONS
    receive() external payable {}

    constructor(address _keyNftAddress) {
        keyNftContract = KeyNft(_keyNftAddress);
    }

    function addProperty(
        bool _house,
        bool _apartment,
        bool _entirePlace,
        bool _room,
        string memory _location,
        uint256 _bedrooms,
        uint256 _bathrooms,
        uint256 _pricePerNight
    ) public returns (bytes32 _propertyId) {
        _incrementNumOfPropertiesListed();
        bytes32 propertyId = _generatePropertyId(currentNumOfProperties, _location);

        _addPropertyDetails(
            msg.sender,
            propertyId,
            _house,
            _apartment,
            _entirePlace,
            _room,
            _location,
            _bedrooms,
            _bathrooms,
            _pricePerNight
        );

        emit PropertyAdded(msg.sender, propertyId);
        return propertyId;
    }

    function _addPropertyDetails(
        address _owner,
        bytes32 _propertyId,
        bool _house,
        bool _apartment,
        bool _entirePlace,
        bool _room,
        string memory _location,
        uint256 _bedrooms,
        uint256 _bathrooms,
        uint256 _pricePerNight
    ) internal {
        PropertyDetails storage listing = propertyDetailsByPropertyId[_propertyId];

        listing.owner = payable(_owner);
        listing.propertyId = _propertyId;
        listing.house = _house;
        listing.apartment = _apartment;
        listing.entirePlace = _entirePlace;
        listing.room = _room;
        listing.location = _location;
        listing.bedrooms = _bedrooms;
        listing.bathrooms = _bathrooms;
        listing.pricePerNight = _pricePerNight;
        listing.bookingApproved = false;

        propertyDetailsByPropertyId[_propertyId] = listing;
        allPropertiesListed.push(listing);
    }

    function _generatePropertyId(uint256 _currentNumOfProperties, string memory _location)
        internal
        view
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_currentNumOfProperties, _location, block.timestamp, msg.sender));
    }

    function _incrementNumOfPropertiesListed() internal {
        currentNumOfProperties += 1;
    }

    function deleteProperty(bytes32 _propertyId) public onlyPropertyOwner(_propertyId) {
        delete propertyDetailsByPropertyId[_propertyId];

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

    // function approveBookingRequest(bytes32 _propertyId) public {
    //     PropertyDetails storage listing = propertyDetailsByPropertyId[_propertyId];

    //     listing.bookingApproved = true;
    // }

    function requestBooking(bytes32 _propertyId, uint256 _numOfAdditionalGuests, uint256 _daysBooked)
        public
        payable
        returns (address _guest, bytes32 propertyId, uint256 daysBooked, address _propertyOwner, uint256 _depositAmount)
    {
        uint256 totalDeposit = _calculatePropertyTotalDepositAmount(_propertyId, _daysBooked);
        bookingDeposits[msg.sender][_propertyId] += msg.value;
        require(msg.value == totalDeposit, "Send exact deposit amount");
        _addBookingDetails(msg.sender, _propertyId, _numOfAdditionalGuests, _daysBooked, msg.value);

        emit BookingRequested(msg.sender, _propertyId, msg.value, _daysBooked);
        return (msg.sender, _propertyId, _daysBooked, propertyDetailsByPropertyId[_propertyId].owner, msg.value);
    }

    function _addBookingDetails(
        address _guest,
        bytes32 _propertyId,
        uint256 _numOfAdditionalGuests,
        uint256 _daysBooked,
        uint256 _depositAmount
    ) internal {
        BookingDetails storage bookingDetails = bookingRequests[_guest][_propertyId];
        bookingDetails.guest = payable(_guest);
        bookingDetails.propertyId = _propertyId;
        bookingDetails.numberOfAdditionalGuests = _numOfAdditionalGuests;
        bookingDetails.daysBooked = _daysBooked;
        bookingDetails.depositAmount = _depositAmount;
    }

    function _calculatePropertyTotalDepositAmount(bytes32 _propertyId, uint256 _daysBooked)
        public
        view
        returns (uint256 _depositAmount)
    {
        uint256 pricePerDay = propertyDetailsByPropertyId[_propertyId].pricePerNight;

        uint256 totalDeposit = _daysBooked * pricePerDay;

        return totalDeposit;
    }

    // VIEW
    function getCurrentNumOfPropertiesListed() external view returns (uint256 _numOfListings) {
        return currentNumOfProperties;
    }

    function getPropertyDetailsByPropertyId(bytes32 _propertytId)
        external
        view
        returns (PropertyDetails memory _propertyDetails)
    {
        return propertyDetailsByPropertyId[_propertytId];
    }

    function getListOfAllListedProperties() external view returns (PropertyDetails[] memory _allListedProperties) {
        return allPropertiesListed;
    }
}
