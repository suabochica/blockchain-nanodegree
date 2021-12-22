pragma solidity >=0.5.4;

//----------------------------------
// Imports
//----------------------------------
// TODO: Define the access roles and import them

contract Base {
    //----------------------------------
    // Variables
    //----------------------------------

    // uint256 skuCounter;
    // mapping(uint256 => ChontaduroItem) chontaduroItems;
    // mapping(uint256 => JuiceItem) juiceItems;
    mapping(uint256 => uint256[]) juiceChontaduros;
    // enum ChontaduroState {
    //     Planted,
    //     Harvested,
    //     Audited,
    //     Processed
    // }
    // ChontaduroState constant defaultChontaduroState = ChontaduroState.Planted;
    // enum JuiceState {
    //     Created,
    //     Blended,
    //     Produced,
    //     Certified,
    //     Packed,
    //     ReadyForSale,
    //     Sold
    // }
    // JuiceState constant defaultJuiceState = JuiceState.Created;
    // struct ChontaduroItem {
    //     uint256 sku;
    //     uint256 upc;
    //     address originFarmerId;
    //     address ownerId;
    //     string originFarmerInformation;
    //     string originFarmerLatitude;
    //     string originFarmerLongitude;
    //     string originFarmerName;
    //     string auditNotes;
    //     string harvestNotes;
    //     ChontaduroState itemState;
    // }
    // struct JuiceItem {
    //     uint256 sku;
    //     uint256 upc;
    //     uint256 productId;
    //     uint256 productPrice;
    //     address consumerId;
    //     address distributorId;
    //     address ownerId;
    //     address producerId;
    //     string certifyNotes;
    //     string productNotes;
    //     JuiceState itemStae;
    // }

    //----------------------------------
    // Events
    //----------------------------------

    // event ChontaduroPlanted(uint256 chontaduroUpc);
    // event ChontaduroHarvested(uint256 chontaduroUpc);
    // event ChontaduroAudited(uint256 chontaduroUpc);
    // event ChontaduroProcessed(uint256 chontaduroUpc);

    // event JuiceCreated(uint256 juiceUpc);
    // event JuiceBlended(uint256 juiceUpc);
    // event JuiceProduced(uint256 juiceUpc);
    // event JuiceCertified(uint256 juiceUpc);
    // event JuicePacked(uint256 juiceUpc);
    // event JuiceReadyForSale(uint256 juiceUpc);
    // event JuiceSold(uint256 juiceUpc);

    //----------------------------------
    // Modifiers
    //----------------------------------

    // modifier verifyCaller(address _address) {
    //     _;
    // }

    // modifier paidEnough(uint256 _price) {
    //     _;
    // }

    // modifier checkValue(uint256 _juiceUpc) {
    //     _;
    // }

    // Chontaduro Modifiers
    //----------------------------------

    // modifier isPlanted(uint256 _chontaduroUpc) {
    //     _;
    // }

    // modifier isHarvested(uint256 _chontaduroUpc) {
    //     _;
    // }

    // modifier isAudited(uint256 _chontaduroUpc) {
    //     _;
    // }

    // modifier isProcessed(uint256 _chontaduroUpc) {
    //     _;
    // }

    // Juice Modifiers
    //----------------------------------

    // modifier isCreated(uint256 _juiceUpc) {
    //     _;
    // }

    // modifier isBlended(uint256 _juiceUpc) {
    //     _;
    // }

    // modifier isProduced(uint256 _juiceUpc) {
    //     _;
    // }

    // modifier isPacked(uint256 _juiceUpc) {
    //     _;
    // }

    // modifier isCertified(uint256 _juiceUpc) {
    //     _;
    // }

    // modifier isReadyForSale(uint256 _juiceUpc) {
    //     _;
    // }

    // modifier isSold(uint256 _juiceUpc) {
    //     _;
    // }

    //----------------------------------
    // Constructor
    //----------------------------------

    // constructor() public payable {
    //     skuCounter = 1;
    // }

    //----------------------------------
    // Functions
    //----------------------------------

    // function kill() public onlyOwner {}

    // Chontaduro Functions
    //----------------------------------

    // function chontaduroPlantItem() public {}

    // function chontaduroHarvestItem() public {}

    // function chontaduroAuditItem() public {}

    // function chontaduroProcessItem() public {}

    // function fetchChontaduroItem() public {}

    // Juice Functions
    //----------------------------------

    // function juiceCeratetItem() public {}

    // function juiceBlendItem() public {}

    // function juiceProduceItem() public {}

    // function juiceCertifyItem() public {}

    // function juiceSellItem() public {}

    // function juiceBuyItem() public {}

    // function fetchJuiceItem() public {}
}
