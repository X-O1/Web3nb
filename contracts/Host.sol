// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Host
 * @author https://github.com/X-O1
 * @notice This contract will handle account creation and listing properties for rent.
 */

contract Host {
    // TYPE DECLARATIONS
    struct PropertyDetails {
        address owner;
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

    // MODIFIERS

    // STATE VARIABLES
    address public keyNftAddress;
    uint256 public currentNumOfProperties;

    mapping(address _host => mapping(bytes32 _propertyId => PropertyDetails _propertyDetails)) public
        listingDetailsByOwnerAndPropertyId;
    mapping(address _host => PropertyDetails[] _listOfProperties) public allPropertiesListedbyOwner;
    mapping(address _host => bytes32[] _propertyIds) public listOfPropertyIdsByOwner;
    mapping(bytes32 _propertyId => PropertyDetails _propertyDetails) public propertyDetailsByPropertyId;

    // FUNCTIONS
    constructor(address _keyNftAddress) {
        keyNftAddress = _keyNftAddress;
    }

    function addProperty(
        bool _house,
        bool _apartment,
        bool _entirePlace,
        bool _room,
        string memory _location,
        uint256 _bedrooms,
        uint256 _bathrooms,
        uint256 _pricePerNight,
        uint256 _daysForDiscount
    ) public returns (bytes32 _propertyId) {
        _incrementNumOfPropertiesListed();
        bytes32 propertyId = _generatePropertyId(currentNumOfProperties, _location);
        PropertyDetails storage listing = listingDetailsByOwnerAndPropertyId[msg.sender][propertyId];

        listing.owner = msg.sender;
        listing.house = _house;
        listing.apartment = _apartment;
        listing.entirePlace = _entirePlace;
        listing.room = _room;
        listing.location = _location;
        listing.bedrooms = _bedrooms;
        listing.bathrooms = _bathrooms;
        listing.pricePerNight = _pricePerNight;
        listing.daysForDiscount = _daysForDiscount;

        allPropertiesListedbyOwner[msg.sender].push(listing);
        listOfPropertyIdsByOwner[msg.sender].push(propertyId);
        propertyDetailsByPropertyId[propertyId] = listing;

        return propertyId;
    }

    function deleteProperty(bytes32 _propertyId) public {
        _decreaseNumOfPropertiesListed();
        delete listingDetailsByOwnerAndPropertyId[msg.sender][_propertyId];
        delete allPropertiesListedbyOwner[msg.sender];
        delete listOfPropertyIdsByOwner[msg.sender];
        delete propertyDetailsByPropertyId[_propertyId];
    }

    // HELPER FUNCTIONS
    function _incrementNumOfPropertiesListed() internal {
        currentNumOfProperties += 1;
    }

    function _decreaseNumOfPropertiesListed() internal {
        currentNumOfProperties -= 1;
    }

    function _generatePropertyId(uint256 _currentNumOfProperties, string memory _location)
        internal
        view
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_currentNumOfProperties, _location, block.timestamp, msg.sender));
    }
    // VIEW FUNCTIONS

    function getCurrentNumOfPropertiesListed() external view returns (uint256 _numOfListings) {
        return currentNumOfProperties;
    }

    function getListingDetailsByOwnerAndPropertyId(bytes32 _propertyId)
        external
        view
        returns (PropertyDetails memory _propertyDetails)
    {
        return listingDetailsByOwnerAndPropertyId[msg.sender][_propertyId];
    }

    function getAllPropertiesListedByOwner() external view returns (PropertyDetails[] memory) {
        return allPropertiesListedbyOwner[msg.sender];
    }

    function getListOfPropertyIdsByOwner() external view returns (bytes32[] memory _propertyIds) {
        return listOfPropertyIdsByOwner[msg.sender];
    }

    function getPropertyDetailsByPropertyId(bytes32 _propertytId)
        external
        view
        returns (PropertyDetails memory _propertyDetails)
    {
        return propertyDetailsByPropertyId[_propertytId];
    }

    function getPropertyDetails(bytes32 _propertyId) external view returns (PropertyDetails memory _details) {
        return listingDetailsByOwnerAndPropertyId[msg.sender][_propertyId];
    }
}
