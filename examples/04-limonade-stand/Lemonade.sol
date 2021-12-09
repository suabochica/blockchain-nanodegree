pragma solidity ^0.4.24;

contract LemonadeStand {

    //----------------------------------
    // Variables
    //----------------------------------
    address owner;
    uint skuCount;
    enum State { ForSale, Sold }
    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address seller;
        address buyer;
    }
    mapping (uint => Item) items;

    //----------------------------------
    // Events
    //----------------------------------
    event ForSale(uint skuCount);
    event Sold(uint skuCount);

    //----------------------------------
    // Modifiers
    //----------------------------------
    modifier onlyOwner() {}

    modifier verifyCaller(address _address) {}

    modifier paidEnough(uint _price) {}

    modifier forSale(uint _sku) {}

    modifier sold(uint _sku) {}

    //----------------------------------
    // Functions
    //----------------------------------

    constructor() public payable {
        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string _name, uint _price) onlyOwner public {}

    function buyItem(uint _sale) forSale(sky) paidEnoug(itemsp[sku].price) public payable {}

    function fetchItem(uint _sku)
        public
        view 
        returns (
            string name, 
            uint sku,
            uint price
            string stateIs,
            address seller,
            address buyer,
        ) {}

}