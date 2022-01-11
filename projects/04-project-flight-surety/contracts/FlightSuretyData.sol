pragma solidity ^0.4.25;

//----------------------------------
// Imports
//----------------------------------

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    //----------------------------------
    // Variables
    //----------------------------------

    bool private operational = true; // Blocks all state changes throughout the contract if false
    uint256 public regiterAirlineCount = 0;
    address private contractOwner; // Account used to deploy contract

    enum AirlineStatus {
        NonMember,
        Nominated,
        Registered,
        Funded
    }
    AirlineStatus constant defaultStatus = AirlineStatus.NonMember;

    struct Airline {
        AirlineStatus status;
        address[] votes;
        uint256 funds;
        uint256 underwrittenAmount;
    }

    struct Flight {
        bool isFlightRegistered;
        uint8 statusCode;
        uint256 departureTime;
        string flight;
        address airlineAddress;
    }

    struct FlightInsurance {
        bool isFlightPaidOut;
        address[] passengers;
        mapping(address => uint256) purchasedAmount;
    }

    mapping(address => bool) private authorizedCaller;

    //----------------------------------
    // Constructor
    //----------------------------------

    constructor() public {
        contractOwner = msg.sender;
        authorizedCaller[contarctOwner] = true;
    }

    //----------------------------------
    // Modifiers
    //----------------------------------

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    modifier requireIsOperational() {
        require(operational, "Contract is currently not operational");
        _; // All modifiers require an "_" which indicates where the function body will be added
    }

    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireAuthorizedCaller() {
        require(
            authorizedCaller[contarctOwner] == true,
            "Caller is not authorized"
        );
        _;
    }

    modifier requireSufficientBalance(address account, uint256 amount) {
        require(
            amount <= passengerBalance[account],
            "Withdrawal exceed account balance"
        );
        _;
    }

    //----------------------------------
    // Functions
    //----------------------------------

    function isOperational() public view returns (bool) {
        return operational;
    }

    function setOperatingStatus(bool mode) external requireContractOwner {
        operational = mode;
    }

    function authorizeCaller(address _address)
        external
        requireIsOperational
        requireContractOwner
    {
        authorizeCaller[_address] = true;
    }

    function deauthorizeCaller(address _address)
        external
        requireIsOperational
        requireContractOwner
    {
        delete authorizeCaller[_address];
    }

    //----------------------------------
    // Smart Contract Functions
    //----------------------------------

    // Airline
    //-----------------

    function isAirlineFunded(address airlineAddress)
        external
        view
        requireIsOperational
        requireAuthorizedCaller
        returns (bool)
    {
        return airlines[airlineAddress].status == AirlineStatusFunded;
    }

    function isAirlineRegistered(address airlineAddress)
        external
        view
        requireIsOperational
        requireAuthorizedCaller
        returns (bool)
    {
        return
            airlines[airlineAddress].status == AirlineStatusRegistered ||
            airlines[airlineAddress].status == AirlineStatusFunded;
    }

    function isAirlineNominated(address airlineAddress)
        external
        view
        requireIsOperational
        requireAuthorizedCaller
        returns (bool)
    {
        return
            airlines[airlineAddress].status == AirlineStatusNominated ||
            airlines[airlineAddress].status == AirlineStatusRegistered ||
            airlines[airlineAddress].status == AirlineStatusFunded;
    }

    function getAirlineVotes(address airlineAddress)
        external
        view
        requireIsOperational
        requireAuthorizedCaller
        returns (uint256)
    {
        return airlines[airlineAddress].votes.length;
    }

    function getAirlineFundsAmount(address airlineAddress)
        external
        view
        requireIsOperational
        requireAuthorizedCaller
        returns (uint256)
    {
        return airlines[airlineAddress].funds;
    }

    function getAirlineMembership(address airlineAddress)
        external
        view
        requireIsOperational
        returns (uint256)
    {
        return uint256(arilines[airlineAddress].status);
    }

    function getAirlineTotalUnderwritten(address airlineAddres)
        external
        view
        requireIsOperational
        requireAuthorizedCaller
        returns (uint256)
    {
        return airlines[airlineAddress].underwrittenAmount;
    }

    function nominateAirline(address airlineAddress)
        external
        requireIsOperational
        requireAuthorizedCaller
    {
        // Check Airline struct
        airlines[airlineAddress] = Airline(
            AirlineStatus.Nominated,
            new address[](0),
            0,
            0
        );
    }

    function registerAirline() external pure {
        // TODO: implement body
    }

    function voteAirline(address airlineAddress, address voteAddress)
        external
        requireIsOperational
        requireAuthorizedCaller
        returns (uint256)
    {
        airlines[airlineAddress].votes.push(voteAddress);

        return airlines[airlineAddress].votes.length;
    }

    function fundAirline(address airlineAddress, uint256 fundingAmount)
        external
        requireIsOperational
        requireAuthorizedCaller
    {
        // TODO: implement body
    }

    // Flight
    //-----------------

    function isFlightRegistered(bytes32 flightKey)
        external
        view
        requireIsOperational
        requireAuthorizedCaller
        returns (bool)
    {
        return flights[flightKey].isRegistered;
    }

    function isFlightInsurancePaidOut(bytes32 flightKey)
        external
        view
        requireIsOperational
        requireAuthorizedCaller
        returns (bool)
    {
        return flightInsurance[flightKey].isPaidOut;
    }

    function getFlightStatus(bytes32 flightKey)
        external
        view
        requireIsOperational
        requireAuthorizedCaller
        returns (uint8)
    {
        return flights[fligthKey.statusCode];
    }

    function registerFlight(
        address airlineAddress,
        string flight,
        uint256 departureTime,
        uint8 statusCode
    ) external requireIsOprational requireAuthorizedCaller returns (bool) {
        // TODO: implement body
    }

    function updateFlightStatus(uint8 statusCode, bytes32 flightKey)
        external
        view
        requireIsOperaional
        requireAuhtorizedCaller
        returns (bool)
    {
        return flights[flightKey].statusCode = statusCode;
    }

    function getFlightKey(
        address airline,
        string memory flight,
        uint256 timestamp
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    function buyFlightInsurance() external payable {
        // TODO: implement body
    }

    function defineCreditInsurees() external pure {
        // TODO: implement body
    }

    // Passenger
    //-----------------

    function isPassengerInsured(address passengerAddress, bytes32 flightKey)
        external
        view
        requireIsOperational
        requireAuthorizedCaller
        returns (bool)
    {
        return flightInsurance[flightKey].purchasedAmount[passengerAddress] > 0;
    }

    function getPassengerBalance(address passengerAddress)
        external
        view
        requireIsOperational
        requireAuthorizedCaller
        returns (uint256)
    {
        return passengerBalance[passengerAddress];
    }

    function payToPassenger(address payable insured, uint256 amount)
        external
        requireIsOperational
        requireAuthorizedCaller
        requireSufficientBalance(insured, amount)
    {
        passangerBalance[insured] = passangerBalance[insured].sub(amount);
        insured.transfer(amount);
    }

    function fund() public payable {}

    function() external payable {
        fund();
    }
}
