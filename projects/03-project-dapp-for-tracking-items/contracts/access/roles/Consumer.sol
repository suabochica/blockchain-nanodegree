pragma solidity >=0.5.4;

//----------------------------------
// Imports
//----------------------------------
import "../Roles.sol";

contract Consumer {
    //----------------------------------
    // Variables
    //----------------------------------

    using Roles for Roles.Role;

    Roles.Role private _Consumers;

    //----------------------------------
    // Events
    //----------------------------------

    event ConsumerAdded(address indexed account);
    event ConsumerRemoved(address indexed account);

    //----------------------------------
    // Constructor
    //----------------------------------

    constructor() public {
        _addConsumer(msg.sender);
    }

    //----------------------------------
    // Modifiers
    //----------------------------------

    modifier onlyConsumer() {
        require(
            isConsumer(msg.sender),
            "Consumer: Caller does not have the consumer role"
        );
        _;
    }

    //----------------------------------
    // Constructor
    //----------------------------------

    function isConsumer(address account) public view returns (bool) {
        return _Consumers.hasAccountRole(account);
    }

    function addConsumer(address account) public onlyConsumer {
        _addConsumer(account);
    }

    function removeConsumer() public onlyConsumer {
        _removeConsumer(msg.sender);
    }

    function _addConsumer(address account) internal {
        _Consumers.addRoleToAccount(account);

        emit ConsumerAdded(account);
    }

    function _removeConsumer(address account) internal {
        _Consumers.removeRoleFromAccount(account);

        emit ConsumerAdded(account);
    }
}
