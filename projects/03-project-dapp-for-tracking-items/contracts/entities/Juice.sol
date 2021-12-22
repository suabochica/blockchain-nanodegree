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
        uint256 price;
        address consumerId;
        address distributorId;
        address ownerId;
        address producerId;
        string certifyNotes;
        string productNotes;
        JuiceState state;
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
        require(msg.sender == _address, "Verify Caller: Unexpected Caller");
        _;
    }

    modifier paidEnough(uint256 _price) {
        require(msg.value == _price, "Paid Enough: Not Enough Value");
        _;
    }

    modifier checkValue(uint256 _juiceUpc) {
        _;
        uint256 _price = juiceItems[_juiceUpc].price;
        uint256 amountToRefund = msg.value - _price;
        payable(juiceItems[_juiceUpc].consumerId).transfer(amountToRefund);
    }

    modifier isCreated(uint256 _juiceUpc) {
        require(
            juiceItems[_juiceUpc].state == JuiceState.Created,
            "Not Created"
        );
        _;
    }

    modifier isBlended(uint256 _juiceUpc) {
        require(
            juiceItems[_juiceUpc].state == JuiceState.Blended,
            "Not Blended"
        );
        _;
    }

    modifier isProduced(uint256 _juiceUpc) {
        require(
            juiceItems[_juiceUpc].state == JuiceState.Produced,
            "Not Produced"
        );
        _;
    }

    modifier isPacked(uint256 _juiceUpc) {
        require(juiceItems[_juiceUpc].state == JuiceState.Packed, "Not Packed");
        _;
    }

    modifier isCertified(uint256 _juiceUpc) {
        require(
            juiceItems[_juiceUpc].state == JuiceState.Certified,
            "Not Certified"
        );
        _;
    }

    modifier isReadyForSale(uint256 _juiceUpc) {
        require(
            juiceItems[_juiceUpc].state == JuiceState.ReadyForSale,
            "Not ReadyForSale"
        );
        _;
    }

    modifier isSold(uint256 _juiceUpc) {
        require(juiceItems[_juiceUpc].state == JuiceState.Sold, "Not Sold");
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

    function juiceCeratetItem(uint256 _chontaduroUpc, uint256 _productId)
        public
    {
        skuCount = skuCount + 1;

        juiceItems[_chontaduroUpc].sku = skuCount;
        juiceItems[_chontaduroUpc].upc = _chontaduroUpc;
        juiceItems[_chontaduroUpc].productId = _productId;
        juiceItems[_chontaduroUpc].ownerId = msg.sender;
        juiceItems[_chontaduroUpc].state = JuiceState.Created;

        emit JuiceCreated(_chontaduroUpc);
    }

    // TODO: Should be included in the Base contract?
    // function juiceBlendItem(uint256 _juiceUpc, uint256 _chontaduroUpc)
    //     public
    // {
    //     chotaduroItems[_juiceUpc].ownerId = msg.sender;
    //     juiceItems[_juiceUpc].push(_chontaduroUpc);

    //     emit JuiceBlended(_juiceUpc, _chontaduroUpc);
    // }

    function juiceProduceItem(
        uint256 _juiceUpc,
        string calldata _productNotes,
        uint256 _productPrice
    ) public isBlended(_juiceUpc) {
        juiceItems[_juiceUpc].producerId = msg.sender;
        juiceItems[_juiceUpc].productNotes = _productNotes;
        juiceItems[_juiceUpc].price = _productPrice;
        juiceItems[_juiceUpc].state = JuiceState.Produced;

        emit JuiceProduced(_juiceUpc);
    }

    function juiceCertifyItem(uint256 _juiceUpc, string calldata _certifyNotes)
        public
        isProduced(_juiceUpc)
    {
        juiceItems[_juiceUpc].certifyNotes = _certifyNotes;
        juiceItems[_juiceUpc].state = JuiceState.Certified;

        emit JuiceCertified(_juiceUpc);
    }

    function juicePackItem(uint256 _juiceUpc) public isCertified(_juiceUpc) {
        juiceItems[_juiceUpc].state = JuiceState.Packed;

        emit JuicePacked(_juiceUpc);
    }

    function juiceSellItem(uint256 _juiceUpc) public isPacked(_juiceUpc) {
        juiceItems[_juiceUpc].distributorId = msg.sender;
        juiceItems[_juiceUpc].state = JuiceState.ReadyForSale;

        emit JuiceReadyForSale(_juiceUpc);
    }

    function juiceBuyItem(uint256 _juiceUpc)
        public
        isReadyForSale(_juiceUpc)
    // paidEnough(juiceItems[_juiceUpc].price)
    // checkValue(_juiceUpc)
    {
        juiceItems[_juiceUpc].ownerId = msg.sender;
        juiceItems[_juiceUpc].consumerId = msg.sender;

        uint256 price = juiceItems[_juiceUpc].price;
        payable(juiceItems[_juiceUpc].producerId).transfer(price);

        juiceItems[_juiceUpc].state = JuiceState.Sold;

        emit JuiceSold(_juiceUpc);
    }

    function fetchJuiceItem(uint256 _juiceUpc)
        public
        view
        returns (
            uint256 sku,
            uint256 upc,
            address ownerId,
            uint256 productId,
            string memory productNotes,
            uint256 price,
            address producerId,
            address distributorId,
            address consumerId,
            string memory certifyNotes,
            uint256[] memory chontaduros,
            uint256 state
        )
    {
        sku = juiceItems[_juiceUpc].sku;
        upc = juiceItems[_juiceUpc].sku;
        ownerId = juiceItems[_juiceUpc].ownerId;
        productId = juiceItems[_juiceUpc].productId;
        productNotes = juiceItems[_juiceUpc].productNotes;
        price = juiceItems[_juiceUpc].price;
        producerId = juiceItems[_juiceUpc].producerId;
        distributorId = juiceItems[_juiceUpc].distributorId;
        consumerId = juiceItems[_juiceUpc].consumerId;
        certifyNotes = juiceItems[_juiceUpc].certifyNotes;
        // TODO: check the Base.sol scenario
        // chontaduros = juiceItems[_juiceUpc].chontaduros;
        state = uint256(juiceItems[_juiceUpc].state);
    }
}
