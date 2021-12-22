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
        string originFarmerInformation;
        string originFarmerLatitude;
        string originFarmerLongitude;
        string originFarmerName;
        string auditNotes;
        string harvestNotes;
        ChontaduroState itemStaTe;
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
        _;
    }

    modifier paidEnough(uint256 _price) {
        _;
    }

    modifier checkValue(uint256 _juiceUpc) {
        _;
    }

    // Chontaduro Modifiers
    //----------------------------------

    modifier isPlanted(uint256 _chontaduroUpc) {
        _;
    }

    modifier isHarvested(uint256 _chontaduroUpc) {
        _;
    }

    modifier isAudited(uint256 _chontaduroUpc) {
        _;
    }

    modifier isProcessed(uint256 _chontaduroUpc) {
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

    function chontaduroPlantItem() public {}

    function chontaduroHarvestItem() public {}

    function chontaduroAuditItem() public {}

    function chontaduroProcessItem() public {}

    function fetchChontaduroItem() public {}
}
