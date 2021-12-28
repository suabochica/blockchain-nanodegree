pragma solidity ^0.4.24;

contract Ownable {
    //----------------------------------
    // Variables
    //----------------------------------

    address private originalOwner;

    //----------------------------------
    // Events
    //----------------------------------

    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    //----------------------------------
    // Modifiers
    //----------------------------------

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    //----------------------------------
    // Constructor
    //----------------------------------

    constructor() public {
        originalOwner = msg.sender;

        emit TransferOwnership(address(0), originalOwner);
    }

    //----------------------------------
    // Functions
    //----------------------------------

    function getOwner() public view returns (address) {
        return originalOwner;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == originalOwner;
    }

    function renounceOwnership() external onlyOwner {
        originalOwner = address(0);

        emit TransferOwnership(originalOwner, address(0));
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal onlyOwner {
        require(newOwner != address(0));
        originalOwner = newOwner;

        emit TransferOwnership(originalOwner, newOwner);
    }
}
