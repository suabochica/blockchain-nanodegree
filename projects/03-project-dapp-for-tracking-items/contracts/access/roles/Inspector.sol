pragma solidity ^0.4.24;

//----------------------------------
// Imports
//----------------------------------
import "../Roles.sol";

contract Inspector {
    //----------------------------------
    // Variables
    //----------------------------------

    using Roles for Roles.Role;

    Roles.Role private _Inspectors;

    //----------------------------------
    // Events
    //----------------------------------

    event InspectorAdded(address indexed account);
    event InspectorRemoved(address indexed account);

    //----------------------------------
    // Constructor
    //----------------------------------

    constructor() public {
        _addInspector(msg.sender);
    }

    //----------------------------------
    // Modifiers
    //----------------------------------

    modifier onlyInspector() {
        require(
            isInspector(msg.sender),
            "Inspector: Caller does not have the Inspector role"
        );
        _;
    }

    //----------------------------------
    // Constructor
    //----------------------------------

    function isInspector(address account) public view returns (bool) {
        return _Inspectors.hasAccountRole(account);
    }

    function addInspector(address account) public onlyInspector {
        _addInspector(account);
    }

    function removeInspector() public onlyInspector {
        _removeInspector(msg.sender);
    }

    function _addInspector(address account) internal {
        _Inspectors.addRoleToAccount(account);

        emit InspectorAdded(account);
    }

    function _removeInspector(address account) internal {
        _Inspectors.removeRoleFromAccount(account);

        emit InspectorAdded(account);
    }
}
