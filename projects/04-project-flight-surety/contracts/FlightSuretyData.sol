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

    uint256 public regiterAirlineCount = 0;

    address private contractOwner; // Account used to deploy contract

    bool private operational = true; // Blocks all state changes throughout the contract if false

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
    // Events
    //----------------------------------

    /**
     * @dev Constructor
     *      The deploying account becomes contractOwner
     */
    constructor() public {
        contractOwner = msg.sender;
        authorizedCaller[contarctOwner] = true;
    }

    //----------------------------------
    // Modifiers
    //----------------------------------

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
     * @dev Modifier that requires the "operational" boolean variable to be "true"
     *      This is used on all state changing functions to pause the contract in
     *      the event there is an issue that needs to be fixed
     */
    modifier requireIsOperational() {
        require(operational, "Contract is currently not operational");
        _; // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
     * @dev Modifier that requires the "ContractOwner" account to be the function caller
     */
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
    // Utilities Functions
    //----------------------------------

    /**
     * @dev Get operating status of contract
     *
     * @return A bool that is the current operating status
     */
    function isOperational() public view returns (bool) {
        return operational;
    }

    /**
     * @dev Sets contract operations on/off
     *
     * When operational mode is disabled, all write transactions except for this one will fail
     */
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

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    /**
     * @dev Add an airline to the registration queue
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function registerAirline() external pure {}

    /**
     * @dev Buy insurance for a flight
     *
     */
    function buy() external payable {}

    /**
     *  @dev Credits payouts to insurees
     */
    function creditInsurees() external pure {}

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
     */
    function pay() external pure {}

    /**
     * @dev Initial funding for the insurance. Unless there are too many delayed flights
     *      resulting in insurance payouts, the contract should be self-sustaining
     *
     */
    function fund() public payable {}

    function getFlightKey(
        address airline,
        string memory flight,
        uint256 timestamp
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
     * @dev Fallback function for funding smart contract.
     *
     */
    function() external payable {
        fund();
    }
}
