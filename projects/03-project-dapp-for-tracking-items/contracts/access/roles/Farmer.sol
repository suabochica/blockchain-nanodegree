pragma solidity ^0.4.24;

//----------------------------------
// Imports
//----------------------------------
import "../Roles.sol";

contract Farmer {
    //----------------------------------
    // Variables
    //----------------------------------

    using Roles for Roles.Role;

    Roles.Role private _Farmers;

    //----------------------------------
    // Events
    //----------------------------------

    event FarmerAdded(address indexed account);
    event FarmerRemoved(address indexed account);

    //----------------------------------
    // Constructor
    //----------------------------------

    constructor() public {
        _addFarmer(msg.sender);
    }

    //----------------------------------
    // Modifiers
    //----------------------------------

    modifier onlyFarmer() {
        require(
            isFarmer(msg.sender),
            "Farmer: Caller does not have the Farmer role"
        );
        _;
    }

    //----------------------------------
    // Constructor
    //----------------------------------

    function isFarmer(address account) public view returns (bool) {
        return _Farmers.hasAccountRole(account);
    }

    function addFarmer(address account) public onlyFarmer {
        _addFarmer(account);
    }

    function removeFarmer() public onlyFarmer {
        _removeFarmer(msg.sender);
    }

    function _addFarmer(address account) internal {
        _Farmers.addRoleToAccount(account);

        emit FarmerAdded(account);
    }

    function _removeFarmer(address account) internal {
        _Farmers.removeRoleFromAccount(account);

        emit FarmerAdded(account);
    }
}
