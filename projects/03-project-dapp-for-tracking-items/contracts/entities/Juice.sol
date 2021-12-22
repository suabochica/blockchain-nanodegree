pragma solidity >=0.5.4;

contract Juice {
    //----------------------------------
    // Variables
    //----------------------------------

    uint256 skuCount;
    enum JuiceState {
        Created,
        Blended,
        Produced,
        Certified,
        Packed,
        ReadyForSale,
        Sold
    }
    struct JuiceItem {
        uint256 sku;
        uint256 upc;
        uint256 productId;
        uint256 productPrice;
        address consumerId;
        address distributorId;
        address ownerId;
        address producerId;
        string certifyNotes;
        string productNotes;
        JuiceState itemStae;
    }
    JuiceState constant defaultJuiceState = JuiceState.Created;
    mapping(uint256 => JuiceItem) juiceItems;

    //----------------------------------
    // Events
    //----------------------------------

    event JuiceCreated(uint256 juiceUpc);
    event JuiceBlended(uint256 juiceUpc);
    event JuiceProduced(uint256 juiceUpc);
    event JuiceCertified(uint256 juiceUpc);
    event JuicePacked(uint256 juiceUpc);
    event JuiceReadyForSale(uint256 juiceUpc);
    event JuiceSold(uint256 juiceUpc);

    //----------------------------------
    // Modifiers
    //----------------------------------

    modifier verifyCaller(address _address) {
        _;
    }

    modifier paidEnough(uint256 _price) {
        _;
    }

    modifier checkValue(uint256 _juiceUpc) {
        _;
    }

    modifier isCreated(uint256 _juiceUpc) {
        _;
    }

    modifier isBlended(uint256 _juiceUpc) {
        _;
    }

    modifier isProduced(uint256 _juiceUpc) {
        _;
    }

    modifier isPacked(uint256 _juiceUpc) {
        _;
    }

    modifier isCertified(uint256 _juiceUpc) {
        _;
    }

    modifier isReadyForSale(uint256 _juiceUpc) {
        _;
    }

    modifier isSold(uint256 _juiceUpc) {
        _;
    }

    //----------------------------------
    // Constructor
    //----------------------------------
    constructor() public payable {
        skuCount = 0;
    }

    //----------------------------------
    // Functions
    //----------------------------------

    function juiceCeratetItem() public {}

    function juiceBlendItem() public {}

    function juiceProduceItem() public {}

    function juiceCertifyItem() public {}

    function juiceSellItem() public {}

    function juiceBuyItem() public {}

    function fetchJuiceItem() public {}
}
