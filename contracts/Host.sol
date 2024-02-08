// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Host
 * @author https://github.com/X-O1
 * @notice This contract manages adding property details and listings.
 */

contract Host {
    // ERRORS
    error Web3nb__PropertyDoesNotExist();
    error Web3nb__NotPropertyOwner();

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

    // EVENTS
    event PropertyAdded(address indexed host, bytes32 indexed propertyId);
    event PropertyDeleted(address indexed host, bytes32 indexed propertyId);

    // MODIFIERS
    modifier onlyPropertyOwner(bytes32 _propertyId) {
        if (msg.sender != propertyDetailsByPropertyId[_propertyId].owner) {
            revert Web3nb__NotPropertyOwner();
        }
        _;
    }

    // STATE VARIABLES
    uint256 public currentNumOfProperties;
    PropertyDetails[] public allPropertiesListed;

    mapping(address _host => mapping(bytes32 _propertyId => PropertyDetails _propertyDetails)) public
        listingDetailsByOwnerAndPropertyId;
    mapping(address _host => PropertyDetails[] _listOfProperties) public allPropertiesListedbyOwner;
    mapping(address _host => bytes32[] _propertyIds) public listOfPropertyIdsByOwner;
    mapping(bytes32 _propertyId => PropertyDetails _propertyDetails) public propertyDetailsByPropertyId;

    // FUNCTIONS
    receive() external payable {}

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
            _pricePerNight,
            _daysForDiscount
        );

        emit PropertyAdded(msg.sender, propertyId);
        return propertyId;
    }

    function deleteProperty(bytes32 _propertyId) public onlyPropertyOwner(_propertyId) {
        _decreaseNumOfPropertiesListed();

        delete listingDetailsByOwnerAndPropertyId[msg.sender][_propertyId];
        delete allPropertiesListedbyOwner[msg.sender];
        delete listOfPropertyIdsByOwner[msg.sender];
        delete propertyDetailsByPropertyId[_propertyId];

        _searchListOfAllPropertiesAndDelete(_propertyId);

        emit PropertyDeleted(msg.sender, _propertyId);
    }

    // HELPER
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
        uint256 _pricePerNight,
        uint256 _daysForDiscount
    ) internal {
        PropertyDetails storage listing = listingDetailsByOwnerAndPropertyId[_owner][_propertyId];

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
        listing.daysForDiscount = _daysForDiscount;

        allPropertiesListedbyOwner[msg.sender].push(listing);
        listOfPropertyIdsByOwner[msg.sender].push(_propertyId);
        propertyDetailsByPropertyId[_propertyId] = listing;
        allPropertiesListed.push(listing);
    }

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

    // VIEW
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

    function getListOfAllListedProperties() external view returns (PropertyDetails[] memory _allListedProperties) {
        return allPropertiesListed;
    }
}
