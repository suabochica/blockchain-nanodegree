pragma solidity >=0.5.4;

//----------------------------------
// Imports
//----------------------------------
import "../Roles.sol";

contract Distributor {
    //----------------------------------
    // Variables
    //----------------------------------

    using Roles for Roles.Role;

    Roles.Role private _Distributors;

    //----------------------------------
    // Events
    //----------------------------------

    event DistributorAdded(address indexed account);
    event DistributorRemoved(address indexed account);

    //----------------------------------
    // Constructor
    //----------------------------------

    constructor() public {
        _addDistributor(msg.sender);
    }

    //----------------------------------
    // Modifiers
    //----------------------------------

    modifier onlyDistributor() {
        require(
            isDistributor(msg.sender),
            "Distributor: Caller does not have the Distributor role"
        );
        _;
    }

    //----------------------------------
    // Constructor
    //----------------------------------

    function isDistributor(address account) public view returns (bool) {
        return _Distributors.hasAccountRole(account);
    }

    function addDistributor(address account) public onlyDistributor {
        _addDistributor(account);
    }

    function removeDistributor() public onlyDistributor {
        _removeDistributor(msg.sender);
    }

    function _addDistributor(address account) internal {
        _Distributors.addRoleToAccount(account);

        emit DistributorAdded(account);
    }

    function _removeDistributor(address account) internal {
        _Distributors.removeRoleFromAccount(account);

        emit DistributorAdded(account);
    }
}
