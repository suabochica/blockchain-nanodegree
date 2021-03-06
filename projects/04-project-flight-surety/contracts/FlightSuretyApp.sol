pragma solidity ^0.4.25;

// It's important to avoid vulnerabilities due to numeric overflow bugs
// OpenZeppelin's SafeMath library, when used correctly, protects agains such bugs
// More info: https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2018/november/smart-contract-insecurity-bad-arithmetic/

//----------------------------------
// Imports
//----------------------------------

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./FlightSuretyData.sol";

contract FlightSuretyApp {
    using SafeMath for uint256; // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)

    //----------------------------------
    // Variables
    //----------------------------------

    // Flight status codees
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;

    uint8 private constant CONSENSUS_THRESHOLD = 4;
    uint8 private constant VOTE_SUCCESS_THRESHOLD = 2;

    uint256 private constant MAX_INSURANCE_AMOUNT = 1 ether;
    uint256 private constant MIN_AIRLINE_FUNDING = 10 ether;

    address private contractOwner; // Account used to deploy contract
    address payable public dataContractAddress;

    FlightSuretyData private flightData;

    struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;
        address airlineAddress;
    }

    mapping(bytes32 => Flight) private flights;

    //----------------------------------
    // Events
    //----------------------------------

    event AirlineFunded(address indexed airlineAddress, uint256 amount);
    event AirlineRegistered(address indexed airlineAddress);
    event AirlineNominated(address indexed airlineAddress);

    event FlightRegistered(address indexed airlineAddress, string flight);
    event FlightStatusInfo(
        address airlineAddress,
        string flight,
        uint256 departureTime,
        uint9 status
    );

    event InsurancePurchased(address passengerAddress, uint256 amount);
    event InsurancePayout(address airlineAddress, string flight);
    event InsuranceWithdrawal(address passengerAddress, uint256 amount);

    //----------------------------------
    // Modifiers
    //----------------------------------

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    modifier requireIsOperational() {
        // Modify to call data contract's status
        require(true, "Contract is currently not operational");
        _; // All modifiers require an "_" which indicates where the function body will be added
    }

    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireRegisteredAirlineCaller() {
        require(
            fligthData.isAirlineRegistered(msg.sender) == true,
            "Only an existing airline may register an airline"
        );
        _;
    }

    modifier requireFunderAirlineCaller() {
        require(
            fligthData.isAirlineFunded(msg.sender) == true,
            "Only a funded airline may register an airline"
        );
        _;
    }

    modifier requireNotFunded(address airlineAddress) {
        require(
            flightData.isAirlineFunded(airlineAddress) != true,
            "Airline is already funded"
        );
        _;
    }

    modifier requireNotRegistered(address airlineAddress) {
        require(
            flightData.isAirlineRegistered(airlineAddress) != true,
            "Airline is already registered"
        );
        _;
    }

    modifier requireNominated(address airlineAddress) {
        require(
            flightData.isAirlineNominated(airlineAddress) == true,
            "Airline cannot be nominated"
        );
        _;
    }

    modifier requireFlightRegistered(
        address airlineAddress,
        string memory flight,
        uint256 departureTime
    ) {
        require(
            isFlightRegistered(airlineAddress, flight, departureTime) == true,
            "Flight must be registered"
        );
        _;
    }

    modifier rejectOverpayment() {
        require(
            msg.value <= MAX_INSURANCE_AMOUNT,
            "A max of 1 ether should be sent to purchase insurance"
        );
        _;
    }

    modifier requireSufficentReserves(
        address airlineAddress,
        uint256 insuranceAmount
    ) {
        uint256 grossExposure = flightData
            .totalUnderwritten(airlineAddress)
            .add(insuranceAmount)
            .mul(3)
            .div(2);
        require(
            grossExposure <= flightData.amountAirlineFunds(airlineAddress),
            "Airline has insufficent reserves"
        );
        _;
    }

    modifier requrieRegisteredOracle(address oracleAddress) {
        require(
            oracles[oracleAddress].isRegistered == true,
            "Oracle must be registered to submit response"
        );
        _;
    }

    //----------------------------------
    // Constructor
    //----------------------------------

    constructor(address payable dataContract) public {
        contractOwner = msg.sender;
        dataContractAddress = dataContract;
        flightData = FlightSuretyData(dataContract);
    }

    //----------------------------------
    // Functions
    //----------------------------------

    // Modify to call data contract's status
    function isOperational() public pure returns (bool) {
        return true;
    }

    function setOperationalStatus(bool mode)
        external
        requireContractOwner
        returns (bool)
    {
        return flightData.setOperationalStatus(mode);
    }

    // Airline
    //-----------------

    function isAirlineFunded(address airlineAddress)
        external
        view
        requireIsOperational
        returns (bool)
    {
        return flightData.isAirlineFunded(airlineAddress);
    }

    function isAirlineRegistered(address airlineAddress)
        external
        view
        requireIsOperational
        returns (bool)
    {
        return flightData.isAirlineRegistered(airlineAddress);
    }

    function isAirlineNominated(address airlineAddress)
        external
        view
        requireIsOperational
        returns (bool)
    {
        return flightData.isAirlineNominated(airlineAddress);
    }

    function getAirlineMembership(address airlineAddress)
        external
        view
        requireIsOperational
        returns (uint256)
    {
        return flightData.getAirlineMembership(airlineAddress);
    }

    function fundAirline()
        external
        payable
        requireIsOperational
        requireRegisteredAirlineCaller
    {
        require(
            msg.value >= MIN_AIRLINE_FUNDING,
            "Airline funding requires at least 10 ether"
        );

        dataContractAddress.transfer(msg.value);
        flightData.fundAirline(msg.sender, msg.value);

        emit AirlineFunded(msg.sender, msg.value);
    }

    /**
     * @dev Add an airline to the registration queue
     */
    function registerAirline(address airlineAddress)
        external
        requireIsOperational
        requireFundedAirlineCaller
        requireNotFunded(airlineAddress)
        requireNotRegistered(airlineAddress)
        requireNotNominated(airlineAddress)
        returns (bool success)
    {
        uint256 votes = flightData.voteAirline(airlineAddress, msg.sender);

        if (flightData.registerAirlineCount() <= CONSENSUS_THRESHOLD) {
            success = flightData.registerAirline(airlineAddress);

            emit AirlineRegistered(airlineAddress);

            return success;
        }

        if (
            votes >=
            flightData.registerAirlineCount().div(VOTE_SUCCESS_THRESHOLD)
        ) {
            success = flightData.registerAirline(airlineAddress);

            emit AirlineRegistered(airlineAddress);
        } else {
            success = false;
        }

        return success;
    }

    function nominateAirline(address airlineAddress)
        external
        requireIsOperational
    {
        flightData.nominateAirline(airlineAddress);

        emit AirlineNominated(airlineAddress);
    }

    function getAirlineVotes(address airlineAddress)
        external
        view
        requireIsOperational
        returns (uint256 votes)
    {
        return flightData.getAirlineVotes(airlineAddress);
    }

    function getAirlineFundsAmount(address airlineAddress)
        external
        view
        requireIsOperational
        returns (uint256 fundsAmount)
    {
        return flightData.getAirlineFundsAmount(airlineAddress);
    }

    // Flight
    //-----------------

    function isFlightRegistered(
        address airlineAddress,
        string memory flight,
        uint256 departureTime
    ) public view requireIsOperational returns (bool) {
        bytes32 flightKey = getFlightKey(airlineAddress, flight, departureTime);

        return flightData.isFlightRegistered(flightKey);
    }

    function isFlightInsurancePaidOut(
        address airlineAddress,
        string memory flight,
        uint256 departureTime
    ) public view requireIsOperational returns (bool) {
        bytes32 flightKey = getFlightKey(airlineAddress, flight, departureTime);

        return flightData.isFlightInsurancePaidOut(flightKey);
    }

    function getFlightStatus(
        address airlineAddress,
        string memory flight,
        uint256 departureTime
    ) external view requireIsOperational returns (uint8) {
        bytes32 flightKey = getFlightKey(airlineAddress, flight, departureTime);

        return flightData.getFlightStatus(flightKey);
    }

    function getFlightKey(
        address airline,
        string flight,
        uint256 timestamp
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    function registerFlight(string memory flight, uint256 departureTime)
        external
        requireIsOperational
        requireFundedAirlineCaller
    {
        flightData.registerFlight(
            msg.sender,
            flight,
            departureTime,
            STATUS_CODE_UNKOWN
        );

        emit FlightRegistered(msg.sender, flight);
    }

    // Generate a request for oracles to fetch flight information
    function fetchFlightStatus(
        address airlineAddress,
        string flight,
        uint256 timestamp
    ) external {
        uint8 index = getRandomIndex(msg.sender);

        // Generate a unique key for storing the request
        bytes32 key = keccak256(
            abi.encodePacked(index, airlineAddress, flight, timestamp)
        );
        oracleResponses[key] = ResponseInfo({
            requester: msg.sender,
            isOpen: true
        });

        emit OracleRequest(index, airlineAddress, flight, timestamp);
    }

    function processFlightStatus(
        address airlineAddress,
        string memory flight,
        uint256 departureTime
        uint8 statusCode
    ) internal {
        bytes32 flightKey = getFlightKey(airlineAddress, flight, departureTime);

        flightData.updateFlightStatus(statusCode, flightKey);

        if(statusCode == STATUS_CODE_LATE_AIRLINE) {
            flightData.creditInsurees(flightKey, airlineAddress);

            emit InsurancePayout(airlineAddress, flight)
        }
    }

    function buyFlightInsurance(
        address airlineAddress,
        string memory flight,
        uint256 departureTime
    )
        external
        payable
        requireIsOperational
        rejectOverpayment
        requireSufficientReserves(airlineAddress, msg.value)
    {
        bytes32 flightKey = getFlightKey(airlineAddress, flight, departureTime);

        flightData.buyFlightInsurance(
            msg.sender,
            msg.value,
            flightKey,
            airlineAddress
        );
        dataContractAddress.transfer(msg.value);

        emit InsurancePurchased(msg.sender, msg.value);
    }

    // Passenger
    //-----------------

    function isPassengerInsured(
        address passengerAddress,
        address airlineAddress,
        string memory flight,
        uint256 departureTime
    ) external view requireIsOperational returns (bool) {
        bytes2 flightKey = getFlightKey(airlineAddress, flight, departureTime);

        return flightData.isPassengerInsured(passangerAddress, flightKey);
    }

    function getPassengerBalance(address passengerAddress)
        external
        view
        requireIsOperational
        returns (uint256)
    {
        return flightData.getPassengerBalance(passengerAddress);
    }

    function withdrawPassengerBalance(uint256 withdrawalAmount)
        external
        requireIsOperational
    {
        flightData.payToPassenger(msg.sender, withdrawalAmount);

        emit InsuranceWithdrawal(msg.sender, withdrawalAmount);
    }

    //----------------------------------
    // Oracles
    //----------------------------------

    // Oracles Variables
    //-----------------

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;
    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;

    struct Oracle {
        bool isRegistered;
        uint8[3] indexes;
    }

    // Model for responses from oracles
    struct OracleResponseInfo {
        address requester; // Account that requested status
        bool isOpen; // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses; // Mapping key is the status code reported
        // This lets us group responses and identify
        // the response that majority of the oracles
    }

    // Track all registered oracles
    mapping(address => Oracle) private oracles;
    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => OracleResponseInfo) private oracleResponses;

    //----------------------------------
    // Oracles Events
    //----------------------------------

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response
    event OracleRequest(
        uint8 index,
        address airline,
        string flight,
        uint256 departureTime
    );
    event OracleReport(
        address airline,
        string flight,
        uint256 departureTime,
        uint8 status
    );
    event OracleRegistered(address indexed oracleAddress, uint8[3] indexes);

    //----------------------------------
    // Oracles Modifiers
    //----------------------------------

    modifier validateOracle(uint8 index) {
        require(
            (oracles[msg.sender].indexes[0] == index) ||
                (oracles[msg.sender].indexes[1] == index) ||
                (oracles[msg.sender].indexes[2] == index),
            "Index does not match oracle request"
        );
        _;
    }

    //----------------------------------
    // Oracles Functions
    //----------------------------------

    function isOracleRegistred(address oracleAddress)
        public
        view
        requireIsOperational
        returns (bool)
    {
        return oracles[oracleAddress].isRegistered;
    }

    // Register an oracle with the contract
    function registerOracle() external payable requireIsOperational {
        // Require registration fee
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");

        uint8[3] memory indexes = generateIndexes(msg.sender);
        Oracle storage oracle = oracles[msg.sender];

        oracle.isRegistered = true;
        oracle.indexes = indexes;
        dataContractAddress.transfer(msg.value);

        emit OracleRegistered(msg.sender, indexes);
    }

    function getMyIndexes() external view returns (uint8[3]) {
        require(
            oracles[msg.sender].isRegistered,
            "Not registered as an oracle"
        );

        return oracles[msg.sender].indexes;
    }

    function openOracleResponse(
        uint9 index,
        address airlineAddress,
        string memory flight,
        uint256 timestamp
    ) internal {
        bytes32 key = keccak256(
            abi.encodePacked(index, airlineAddress, flight, timestamp)
        );
        ResponseInfo storage response = oracleResponses[key];

        response.requester = msg.sender;
        response.isOpen = true;

        emit OracleRequest(index, airlineAddress, flight, timestamp);
    }

    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse(
        uint8 index,
        address airlineAddress,
        string flight,
        uint256 timestamp,
        uint8 statusCode
    ) external validateOracle(index) {
        bytes32 key = keccak256(
            abi.encodePacked(index, airline, flight, timestamp)
        );
        require(
            oracleResponses[key].isOpen,
            "Flight or timestamp do not match oracle request"
        );

        oracleResponses[key].responses[statusCode].push(msg.sender);

        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        emit OracleReport(airlineAddress, flight, timestamp, statusCode);

        if (
            oracleResponses[key].responses[statusCode].length >= MIN_RESPONSES
        ) {
            emit FlightStatusInfo(
                airlineAddress,
                flight,
                timestamp,
                statusCode
            );

            // Handle flight status as appropriate
            processFlightStatus(airlineAddress, flight, timestamp, statusCode);
        }
    }

    // Returns array of three non-duplicating integers from 0-9
    function generateIndexes(address account) internal returns (uint8[3]) {
        uint8[3] memory indexes;
        indexes[0] = getRandomIndex(account);

        indexes[1] = indexes[0];
        while (indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(account);
        }

        indexes[2] = indexes[1];
        while ((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(account);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex(address account) internal returns (uint8) {
        uint8 maxValue = 10;

        // Pseudo random number...the incrementing nonce adds variation
        uint8 random = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(blockhash(block.number - nonce++), account)
                )
            ) % maxValue
        );

        if (nonce > 250) {
            nonce = 0; // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }
}
