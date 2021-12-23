pragma solidity >=0.5.4;

//----------------------------------
// Imports
//----------------------------------
import "../Roles.sol";

contract Producer {
    //----------------------------------
    // Variables
    //----------------------------------

    using Roles for Roles.Role;

    Roles.Role private _Producers;

    //----------------------------------
    // Events
    //----------------------------------

    event ProducerAdded(address indexed account);
    event ProducerRemoved(address indexed account);

    //----------------------------------
    // Constructor
    //----------------------------------

    constructor() public {
        _addProducer(msg.sender);
    }

    //----------------------------------
    // Modifiers
    //----------------------------------

    modifier onlyProducer() {
        require(
            isProducer(msg.sender),
            "Producer: Caller does not have the Producer role"
        );
        _;
    }

    //----------------------------------
    // Constructor
    //----------------------------------

    function isProducer(address account) public view returns (bool) {
        return _Producers.hasAccountRole(account);
    }

    function addProducer(address account) public onlyProducer {
        _addProducer(account);
    }

    function removeProducer() public onlyProducer {
        _removeProducer(msg.sender);
    }

    function _addProducer(address account) internal {
        _Producers.addRoleToAccount(account);

        emit ProducerAdded(account);
    }

    function _removeProducer(address account) internal {
        _Producers.removeRoleFromAccount(account);

        emit ProducerAdded(account);
    }
}
