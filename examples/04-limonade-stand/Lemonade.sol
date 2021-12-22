pragma solidity >=0.5.4;

contract LemonadeStand {
    //----------------------------------
    // Variables
    //----------------------------------
    address owner;
    uint256 skuCount;
    enum State {
        ForSale,
        Sold,
        Shipped
    }
    struct Item {
        string name;
        uint256 sku;
        uint256 price;
        State state;
        address seller;
        address buyer;
    }
    mapping(uint256 => Item) items;

    //----------------------------------
    // Events
    //----------------------------------

    event ForSale(uint256 skuCount);
    event Sold(uint256 skuCount);
    event Shipped(uint256 skuCount);

    //----------------------------------
    // Modifiers
    //----------------------------------

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier verifyCaller(address _address) {
        require(msg.sender == _address);
        _;
    }

    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price);
        _;
    }

    modifier checkValue(uint256 _sku) {
        _;
        uint256 _price = items[_sku].price;
        uint256 amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
    }

    modifier forSale(uint256 _sku) {
        require(items[_sku].state == State.ForSale);
        _;
    }

    modifier sold(uint256 _sku) {
        require(items[_sku].state == State.Sold);
        _;
    }

    //----------------------------------
    // Functions
    //----------------------------------

    constructor() public payable {
        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string _name, uint256 _price) public onlyOwner {
        skuCount = skuCount + 1;
        emit ForSale(skuCount);
        items[skuCount] = Item({
            name: _name,
            sku: skuCount,
            price: _price,
            state: State.ForSale,
            seller: msg.sender,
            buyer: 0
        });
    }

    function buyItem(uint256 sku)
        public
        payable
        forSale(sku)
        paidEnough(items[sku].price)
        checkValue(sku)
    {
        address buyer = msg.sender;
        uint256 price = items[sku].price;

        items[sku].buyer = buyer;
        items[sku].state = State.Sold;
        items[sku].seller.transfer(price);

        emit Sold(sku);
    }

    function shipItem(uint256 sku)
        public
        sold(sku)
        verifyCaller(items[sku].seller)
    {
        items[sku].state = State.Shipped;

        emit Shipped(sku);
    }

    function fetchItem(uint256 _sku)
        public
        view
        returns (
            string name,
            uint256 sku,
            uint256 price,
            string stateIs,
            address seller,
            address buyer
        )
    {
        uint256 state;
        name = items[_sku].name;
        sku = items[_sku].sku;
        price = items[_sku].price;
        state = uint256(items[_sku].state);

        if (state == 0) {
            stateIs = "For Sale";
        }

        if (state == 1) {
            stateIs = "Sold";
        }

        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
    }
}
