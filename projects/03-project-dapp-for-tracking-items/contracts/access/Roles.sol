pragma solidity ^0.4.24;

library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    function addRoleToAccount(Role storage role, address account) internal {
        require(!hasAccountRole(role, account), "Roles: Account has role");
        role.bearer[account] = true;
    }

    function removeRoleFromAccount(Role storage role, address account)
        internal
    {
        require(hasAccountRole(role, account), "Roles: Account has not role");
        role.bearer[account] = false;
    }

    function hasAccountRole(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0), "Roles: Account is the zero address");

        return role.bearer[account];
    }
}
