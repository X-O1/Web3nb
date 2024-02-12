# Web3nb: Home Hosting Service

## Overview
Web3nb is blockchain-based infrastructure designed to facilitate a home hosting service, similar to how Airbnb operates but within the decentralized web space. This smart contract enables property owners to list their properties and manage bookings through a decentralized, transparent, and secure system.

## Features
- **Property Listing**: Property owners can list their properties, including details such as price per night.
- **Booking Requests**: Guests can request bookings for listed properties, specifying the duration of their stay.
- **Booking Management**: Property owners can approve, decline, or cancel booking requests.
- **Key NFTs**: Upon booking approval, a unique NFT key is minted and assigned to the guest for access purposes.
- **Deposit Handling**: Handles booking deposits, ensuring funds are appropriately managed between guests and hosts throughout the booking process.

## Smart Contract Functions

### Public Functions
- `addProperty(uint256 _pricePerNight)`: Allows a property owner to list a new property by specifying the price per night.
- `deleteProperty(bytes32 _propertyId)`: Enables a property owner to remove a listed property.
- `requestBooking(bytes32 _propertyId, uint256 _daysBooked)`: Allows a guest to request a booking for a specified number of days.
- `cancelBookingRequest(bytes32 _bookingId)`: Enables a guest to cancel a pending booking request.
- `approveBookingRequest(bytes32 _bookingId)`: Allows the property owner to approve a booking request.
- `declineBookingRequest(bytes32 _bookingId)`: Enables the property owner to decline a booking request.

### View Functions
- `getCurrentNumOfPropertiesListed()`: Returns the current number of listed properties.
- `getPropertyDetails(bytes32 _propertyId)`: Retrieves details of a specific property.
- `getListOfAllListedProperties()`: Returns a list of all properties currently listed.
- `getDepositBalance(address _guest, bytes32 _propertyId)`: Returns the deposit balance associated with a specific booking.

## Events
- `PropertyAdded`
- `PropertyDeleted`
- `BookingRequested`
- `BookingApproved`
- `BookingDeclined`
- `BookingCanceled`

## Error Handling
Custom error messages are implemented for various fail states, enhancing the contract's usability and debuggability.

## Requirements
- Solidity ^0.8.20

## Usage
To interact with this contract:
1. Deploy the contract with the address of the KeyNFT contract as a constructor parameter.
2. Call the `addProperty` function to list a new property.
3. Guests can request bookings using the `requestBooking` function.
4. Property owners manage booking requests through `approveBookingRequest`, `declineBookingRequest`, and `cancelBookingRequest` functions.

## Security Considerations
This contract includes basic security features such as ownership checks and error handling. Further audits and security measures are recommended before deploying in a production environment.

## License
This project is licensed under the MIT License.