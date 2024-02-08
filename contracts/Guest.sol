// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Guest
 * @author https://github.com/X-O1
 * @notice This contract manages guest booking requests.
 */

import {Host} from "./Host.sol";

contract Guest {
    Host hostContract;

    // EVENTS
    event BookingRequested(address indexed guest, bytes32 indexed propertyId, uint256 indexed depositAmount);

    // MODIFIERS

    // STATE VARIABLES
    mapping(address _guest => mapping(bytes32 _propertyId => BookingDetails _bookingDetails)) public bookingRequests;

    // TYPE DECLARATIONS
    struct PropertyDetails {
        address payable owner;
        bytes32 propertyId;
        bool house;
        bool apartment;
        bool entirePlace;
        bool room;
        string location;
        uint256 bedrooms;
        uint256 bathrooms;
        uint256 pricePerNight;
        uint256 daysForDiscount;
    }

    struct BookingDetails {
        address payable guest;
        bytes32 propertyId;
        uint256 numberOfAdditionalGuests;
        uint256 daysBooked;
        uint256 depositAmount;
    }

    // FUNCTIONS
    receive() external payable {}

    constructor(address _hostContractAddress) {
        hostContract = Host(payable(_hostContractAddress));
    }

    function requestBooking(bytes32 _propertyId, uint256 _numOfAdditionalGuests, uint256 _daysBooked)
        public
        payable
        returns (address _propertyOwner, uint256 _depositAmount)
    {
        uint256 totalDeposit = _calculatePropertyTotalDepositAmount(_propertyId, _daysBooked);
        require(msg.value == totalDeposit, "Send exact deposit amount");

        _addBookingDetails(msg.sender, _propertyId, _numOfAdditionalGuests, _daysBooked, msg.value);

        emit BookingRequested(msg.sender, _propertyId, msg.value);
        return (hostContract.getPropertyDetailsByPropertyId(_propertyId).owner, msg.value);
    }

    // HELPER
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
        internal
        view
        returns (uint256 _depositAmount)
    {
        uint256 pricePerDay = hostContract.getPropertyDetailsByPropertyId(_propertyId).pricePerNight;

        uint256 totalDeposit = _daysBooked * pricePerDay;

        return totalDeposit;
    }
}
