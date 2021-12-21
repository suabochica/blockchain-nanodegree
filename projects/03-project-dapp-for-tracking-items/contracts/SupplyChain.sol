pragma solidity >=0.5.4;

//----------------------------------
// Imports
//----------------------------------
// TODO: Define the access roles and import them

contract SupplyChain {
    //----------------------------------
    // Variables
    //----------------------------------

    uint256 sku;
    mapping(uint256 => ChontaduroItem) chontaduroItems;
    mapping(uint256 => JuiceItem) juiceItems;
    mapping(uint256 => uint256[]) juiceChontaduros;
    enum ChontaduroState {
        Planted,
        Harvested,
        Audited,
        Processed
    }
    ChontaduroState constant defaultChontaduroState = ChontaduroState.Planted;
    enum JuiceState {
        Created,
        Blended,
        Produced,
        Certified,
        Packed,
        ReadyForSale,
        Purchased
    }
    JuiceState constant defaultJuiceState = JuiceState.Created;
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
        ChontaduroState itemStae;
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

    //----------------------------------
    // Events
    //----------------------------------
}
