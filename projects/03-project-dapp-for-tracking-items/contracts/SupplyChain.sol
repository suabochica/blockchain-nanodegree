pragma solidity >=0.5.4;

//----------------------------------
// Imports
//----------------------------------

import "./Ownable.sol";
import "./access/roles/Consumer.sol";
import "./access/roles/Distributor.sol";
import "./access/roles/Farmer.sol";
import "./access/roles/Producer.sol";
import "./access/roles/Inspector.sol";

contract Base is Ownable, Consumer, Distributor, Farmer, Producer, Inspector {
    //----------------------------------
    // Variables
    //----------------------------------

    uint256 upc;
    uint256 sku;
    mapping(uint256 => Item) items;
    mapping(uint256 => uint256[]) itemsHistory;

    enum State {
        Planted,
        Harvested,
        Audited,
        Processed,
        Produced,
        Certified,
        Packed,
        ReadyForSale,
        Sold
    }

    struct Item {
        uint256 sku;
        uint256 upc;
        uint256 productId;
        uint256 price;
        address originFarmerId;
        address ownerId;
        string originFarmInformation;
        string originFarmLatitude;
        string originFarmLongitude;
        string originFarmName;
        string auditNotes;
        string harvestNotes;
        string certifyNotes;
        string productNotes;
        State state;
        address consumerId;
        address distributorId;
        address producerId;
    }

    //----------------------------------
    // Events
    //----------------------------------

    event Planted(uint256 upc);
    event Harvested(uint256 upc);
    event Audited(uint256 upc);
    event Processed(uint256 upc);
    event Produced(uint256 upc);
    event Certified(uint256 upc);
    event Packed(uint256 upc);
    event ReadyForSale(uint256 upc);
    event Sold(uint256 upc);

    //----------------------------------
    // Modifiers
    //----------------------------------

    modifier verifyCaller(address _address) {
        require(msg.sender == _address, "Verify Caller: Unexpected Caller");
        _;
    }

    modifier paidEnough(uint256 _price) {
        require(msg.value == _price, "Paid Enough: Not Enough Value");
        _;
    }

    modifier checkValue(uint256 _upc) {
        _;
        uint256 _price = items[_upc].price;
        uint256 amountToRefund = msg.value - _price;
        payable(items[_upc].consumerId).transfer(amountToRefund);
    }

    modifier isPlanted(uint256 _upc) {
        require(items[_upc].state == State.Planted, "Not Planted");
        _;
    }

    modifier isHarvested(uint256 _upc) {
        require(items[_upc].state == State.Harvested, "Not Harvested");
        _;
    }

    modifier isAudited(uint256 _upc) {
        require(items[_upc].state == State.Audited, "Not Audited");
        _;
    }

    modifier isProcessed(uint256 _upc) {
        require(items[_upc].state == State.Processed, "Not Processed");
        _;
    }

    modifier isProduced(uint256 _upc) {
        require(items[_upc].state == State.Produced, "Not Produced");
        _;
    }

    modifier isPacked(uint256 _upc) {
        require(items[_upc].state == State.Packed, "Not Packed");
        _;
    }

    modifier isCertified(uint256 _upc) {
        require(items[_upc].state == State.Certified, "Not Certified");
        _;
    }

    modifier isReadyForSale(uint256 _upc) {
        require(items[_upc].state == State.ReadyForSale, "Not ReadyForSale");
        _;
    }

    modifier isSold(uint256 _upc) {
        require(items[_upc].state == State.Sold, "Not Sold");
        _;
    }

    //----------------------------------
    // Constructor
    //----------------------------------

    constructor() public payable {
        sku = 0;
        upc = 0;
    }

    //----------------------------------
    // Functions
    //----------------------------------

    // function kill() public onlyOwner {}

    function plantItem(
        uint256 _upc,
        uint256 _productId,
        address _originFarmerId,
        string calldata _originFarmName,
        string calldata _originFarmInformation,
        string calldata _originFarmLatitude,
        string calldata _originFarmLongitude
    ) public onlyFarmer {
        sku = sku + 1;

        items[_upc].sku = sku;
        items[_upc].upc = _upc;
        items[_upc].productId = _productId;
        items[_upc].ownerId = msg.sender;
        items[_upc].originFarmerId = _originFarmerId;
        items[_upc].originFarmInformation = _originFarmInformation;
        items[_upc].originFarmLatitude = _originFarmLatitude;
        items[_upc].originFarmLongitude = _originFarmLongitude;
        items[_upc].originFarmName = _originFarmName;

        emit Planted(_upc);
    }

    function harvestItem(uint256 _upc, string calldata _harvestNotes)
        public
        onlyFarmer
        isPlanted(_upc)
    {
        items[_upc].ownerId = msg.sender;
        items[_upc].harvestNotes = _harvestNotes;
        items[_upc].state = State.Harvested;

        emit Harvested(_upc);
    }

    function auditItem(uint256 _upc, string calldata _auditNotes)
        public
        onlyInspector
        isHarvested(_upc)
    {
        items[_upc].auditNotes = _auditNotes;
        items[_upc].state = State.Audited;

        emit Audited(_upc);
    }

    function processItem(uint256 _upc) public onlyFarmer isAudited(_upc) {
        items[_upc].state = State.Processed;

        emit Processed(_upc);
    }

    function produceItem(
        uint256 _upc,
        string calldata _productNotes,
        uint256 _productPrice
    ) public onlyProducer isProcessed(_upc) {
        items[_upc].producerId = msg.sender;
        items[_upc].productNotes = _productNotes;
        items[_upc].price = _productPrice;
        items[_upc].state = State.Produced;

        emit Produced(_upc);
    }

    function certifyItem(uint256 _upc, string calldata _certifyNotes)
        public
        onlyInspector
        isProduced(_upc)
    {
        items[_upc].certifyNotes = _certifyNotes;
        items[_upc].state = State.Certified;

        emit Certified(_upc);
    }

    function packItem(uint256 _upc) public onlyProducer isCertified(_upc) {
        items[_upc].state = State.Packed;

        emit Packed(_upc);
    }

    function sellItem(uint256 _upc) public onlyDistributor isPacked(_upc) {
        items[_upc].distributorId = msg.sender;
        items[_upc].state = State.ReadyForSale;

        emit ReadyForSale(_upc);
    }

    function buyItem(uint256 _upc)
        public
        payable
        onlyConsumer
        isReadyForSale(_upc)
        paidEnough(items[_upc].price)
        checkValue(_upc)
    {
        items[_upc].ownerId = msg.sender;
        items[_upc].consumerId = msg.sender;

        uint256 price = items[_upc].price;
        payable(items[_upc].producerId).transfer(price);

        items[_upc].state = State.Sold;

        emit Sold(_upc);
    }

    function fetchItemFirstParams(uint256 _upc)
        public
        view
        returns (
            uint256 sku,
            uint256 upc,
            address ownerId,
            address originFarmerId,
            string memory originFarmName,
            string memory originFarmInformation,
            string memory originFarmLatitude,
            string memory originFarmLongitude,
            string memory auditNotes,
            string memory harvestNotes
        )
    {
        sku = items[_upc].sku;
        upc = items[_upc].upc;
        ownerId = items[_upc].ownerId;
        originFarmerId = items[_upc].originFarmerId;
        originFarmName = items[_upc].originFarmName;
        originFarmInformation = items[_upc].originFarmInformation;
        originFarmLatitude = items[_upc].originFarmLatitude;
        originFarmLongitude = items[_upc].originFarmLongitude;
        auditNotes = items[_upc].auditNotes;
        harvestNotes = items[_upc].harvestNotes;

        return (
            sku,
            upc,
            ownerId,
            originFarmerId,
            originFarmName,
            originFarmInformation,
            originFarmLatitude,
            originFarmLongitude,
            auditNotes,
            harvestNotes
        );
    }

    function fetchItemLastParams(uint256 _upc)
        public
        view
        returns (
            uint256 sku,
            uint256 upc,
            uint256 productId,
            uint256 price,
            uint256 state,
            address ownerId,
            address producerId,
            address distributorId,
            address consumerId,
            string memory productNotes,
            string memory certifyNotes
        )
    {
        sku = items[_upc].sku;
        upc = items[_upc].upc;
        productId = items[_upc].productId;
        price = items[_upc].price;
        state = uint256(items[_upc].state);
        ownerId = items[_upc].ownerId;
        producerId = items[_upc].producerId;
        distributorId = items[_upc].distributorId;
        consumerId = items[_upc].consumerId;
        productNotes = items[_upc].productNotes;
        certifyNotes = items[_upc].certifyNotes;

        return (
            sku,
            upc,
            productId,
            price,
            state,
            ownerId,
            producerId,
            distributorId,
            consumerId,
            productNotes,
            certifyNotes
        );
    }
}
