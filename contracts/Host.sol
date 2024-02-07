// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Host
 * @author https://github.com/X-O1
 * @notice This contract will handle account creation and listing properties for rent.
 */

import {HomeNft} from "./HomeNft.sol";
import {KeyNft} from "./KeyNft.sol";

contract Host {
    HomeNft private homeNft;
    KeyNft private keyNft;

    // TYPE DECLARATIONS
    struct PropertyDetails {
        bool house;
        bool apartment;
        bool entirePlace;
        bool room;
        string location;
        uint256 bedrooms;
        uint256 bathrooms;
        uint256 pricePerNight;
        uint256 minDays;
        uint256 maxDays;
        uint256 daysForDiscount;
    }

    // MODIFIERS

    // STATE VARIABLES
    PropertyDetails[] public properties;

    mapping(address _host => mapping(uint256 _propertyId => PropertyDetails _propertyDetails)) public listings;

    // FUNCTIONS
    function addProperty(
        bool _house,
        bool _apartment,
        bool _entirePlace,
        bool _room,
        string memory _location,
        uint256 _bedrooms,
        uint256 _bathrooms,
        uint256 _pricePerNight,
        uint256 _minDays,
        uint256 _maxDays,
        uint256 _daysForDiscount,
        string memory _homePhoto
    ) public {
        homeNft.mint(_homePhoto);
        PropertyDetails storage listing = listings[msg.sender][homeNft.getCurrentTotalSupply()];

        listing.house = _house;
        listing.apartment = _apartment;
        listing.entirePlace = _entirePlace;
        listing.room = _room;
        listing.location = _location;
        listing.bedrooms = _bedrooms;
        listing.bathrooms = _bathrooms;
        listing.pricePerNight = _pricePerNight;
        listing.minDays = _minDays;
        listing.maxDays = _maxDays;
        listing.minDays = _minDays;
        listing.daysForDiscount = _daysForDiscount;
    }
}
