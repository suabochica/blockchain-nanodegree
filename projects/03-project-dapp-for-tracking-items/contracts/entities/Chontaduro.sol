pragma solidity >=0.5.4;

contract Chontaduro {
    //----------------------------------
    // Variables
    //----------------------------------

    uint256 skuCount;
    enum ChontaduroState {
        Planted,
        Harvested,
        Audited,
        Processed
    }
    struct ChontaduroItem {
        uint256 sku;
        uint256 upc;
        address originFarmerId;
        address ownerId;
        string originFarmInformation;
        string originFarmLatitude;
        string originFarmLongitude;
        string originFarmName;
        string auditNotes;
        string harvestNotes;
        ChontaduroState state;
    }
    mapping(uint256 => ChontaduroItem) chontaduroItems;
    ChontaduroState constant defaultChontaduroState = ChontaduroState.Planted;

    //----------------------------------
    // Events
    //----------------------------------

    event ChontaduroPlanted(uint256 chontaduroUpc);
    event ChontaduroHarvested(uint256 chontaduroUpc);
    event ChontaduroAudited(uint256 chontaduroUpc);
    event ChontaduroProcessed(uint256 chontaduroUpc);

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

    // TODO: Check value is in the chontaduro scope?
    // modifier checkValue(uint256 _juiceUpc) {
    //     _;
    //     uint256 _price = juiceItems[_juiceUps].price;
    //     uint256 amountToreturn = msg.value - _prive;
    //     items[_juiceUpc].consumerId.transfer(amountToRefund);
    // }

    // Chontaduro Modifiers
    //----------------------------------

    modifier isPlanted(uint256 _chontaduroUpc) {
        require(
            chontaduroItems[_chontaduroUpc].state == ChontaduroState.Planted,
            "Not Planted"
        );
        _;
    }

    modifier isHarvested(uint256 _chontaduroUpc) {
        require(
            chontaduroItems[_chontaduroUpc].state == ChontaduroState.Harvested,
            "Not Harvested"
        );
        _;
    }

    modifier isAudited(uint256 _chontaduroUpc) {
        require(
            chontaduroItems[_chontaduroUpc].state == ChontaduroState.Audited,
            "Not Audited"
        );
        _;
    }

    modifier isProcessed(uint256 _chontaduroUpc) {
        require(
            chontaduroItems[_chontaduroUpc].state == ChontaduroState.Processed,
            "Not Processed"
        );
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

    // function kill() public onlyOwner {}

    // Chontaduro Functions
    //----------------------------------

    function chontaduroPlantItem(
        uint256 _chontaduroUpc,
        address _originFarmerId,
        string calldata _originFarmName,
        string calldata _originFarmInformation,
        string calldata _originFarmLatitude,
        string calldata _originFarmLongitude
    ) public {
        skuCount = skuCount + 1;

        chontaduroItems[_chontaduroUpc] = ChontaduroItem({
            sku: skuCount,
            upc: _chontaduroUpc,
            ownerId: msg.sender,
            originFarmerId: _originFarmerId,
            originFarmInformation: _originFarmInformation,
            originFarmLatitude: _originFarmLatitude,
            originFarmLongitude: _originFarmLongitude,
            originFarmName: _originFarmName,
            auditNotes: "",
            harvestNotes: "",
            state: ChontaduroState.Planted
        });

        emit ChontaduroPlanted(_chontaduroUpc);
    }

    function chontaduroHarvestItem(
        uint256 _chontaduroUpc,
        string calldata _harvestNotes
    ) public isPlanted(_chontaduroUpc) {
        chontaduroItems[_chontaduroUpc].ownerId = msg.sender;
        chontaduroItems[_chontaduroUpc].harvestNotes = _harvestNotes;
        chontaduroItems[_chontaduroUpc].state = ChontaduroState.Harvested;

        emit ChontaduroHarvested(_chontaduroUpc);
    }

    function chontaduroAuditItem(
        uint256 _chontaduroUpc,
        string calldata _auditNotes
    ) public isHarvested(_chontaduroUpc) {
        chontaduroItems[_chontaduroUpc].auditNotes = _auditNotes;
        chontaduroItems[_chontaduroUpc].state = ChontaduroState.Audited;

        emit ChontaduroAudited(_chontaduroUpc);
    }

    function chontaduroProcessItem(uint256 _chontaduroUpc)
        public
        isAudited(_chontaduroUpc)
    {
        chontaduroItems[_chontaduroUpc].state = ChontaduroState.Processed;

        emit ChontaduroProcessed(_chontaduroUpc);
    }

    function fetchChontaduroItem(uint256 _chontaduroUpc)
        public
        view
        returns (
            uint256 sku,
            uint256 upc,
            address originFarmerId,
            address ownerId,
            string memory originFarmInformation,
            string memory originFarmLatitude,
            string memory originFarmLongitude,
            string memory originFarmName,
            string memory auditNotes,
            string memory harvestNotes
        )
    {
        sku = chontaduroItems[_chontaduroUpc].sku;
        upc = chontaduroItems[_chontaduroUpc].upc;
        originFarmerId = chontaduroItems[_chontaduroUpc].originFarmerId;
        ownerId = chontaduroItems[_chontaduroUpc].ownerId;
        originFarmInformation = chontaduroItems[_chontaduroUpc]
            .originFarmInformation;
        originFarmLatitude = chontaduroItems[_chontaduroUpc].originFarmLatitude;
        originFarmLongitude = chontaduroItems[_chontaduroUpc]
            .originFarmLongitude;
        originFarmName = chontaduroItems[_chontaduroUpc].originFarmName;
        auditNotes = chontaduroItems[_chontaduroUpc].auditNotes;
        harvestNotes = chontaduroItems[_chontaduroUpc].harvestNotes;

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
}
