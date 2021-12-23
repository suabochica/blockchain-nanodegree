const truffleAssert = require("truffle-assertions");
const SupplyChain = artifacts.require("SupplyChain");

contract("SupplyChain", accounts => {
  //----------------------------------
  // Variables
  //----------------------------------

  let sku = 1;
  let upc = 1;

  const ownerId = accounts[0];
  const originFarmerId = accounts[1];
  const producerId = accounts[2];
  const inspectorId = accounts[3];
  const distributorId = accounts[4];
  const consumerId = accounts[5];

  const originFarmName = "Chontaduro Maduro";
  const originFarmInformation = "Chontaduro maduro come el negrito Arturo";
  const originFarmLatitude = "10.963889";
  const originFarmLongitude = "-74.796387";
  const productId = sku + upc;
  const price = web3.toWei(1, "ether")
  let harvestNotes = "Harvest Notes";
  let auditNotes = "Audit Notes";
  let certifyNotes = "Certify Notes";
  let productNotes = "Product Notes";

  const emptyAddress = '0x00000000000000000000000000000000000000'

  it("should add the roles to the contract", async () => {
    const supplyChain = await SupplyChain.deployed();

    const contractOwner = await supplyChain.owner();
    assert.equal(contractOwner, ownerId);

    const farmerAdded = await supplyChain.addFarmer(originFarmerId);
    truffleAssert.eventEmitted(farmerAdded, 'FarmerAdded')

    const producerAdded = await supplyChain.addProducer(producerId);
    truffleAssert.eventEmitted(producerAdded, 'ProducerAdded')

    const inspectorAdded = await supplyChain.addInspector(inspectorId);
    truffleAssert.eventEmitted(inspectorAdded, 'InspectorAdded')

    const distributorAdded = await supplyChain.addInspector(distributorId);
    truffleAssert.eventEmitted(distributorAdded, 'DistributorAdded')

    const consumerAdded = await supplyChain.addInspector(consumerId);
    truffleAssert.eventEmitted(consumerAdded, 'ConsumerAdded')
  });

  it("should test the plantItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.plantItem(
      upc,
      productId,
      originFarmerId,
      originFarmName,
      originFarmInformation,
      originFarmLatitude,
      originFarmLongitude
    );

    truffleAssert.eventEmitted(event, "Planted");

    const resultFirstParams = await supplyChain.fetchItemFirstParams(upc);
    const resultSecondParams = await supplyChain.fetchItemSecondParams(upc);

    assert.equal(resultFirstParams[1], upc, "Error: Missing upc");
    assert.equal(resultFirstParams[3], originFarmerId, "Error: Missing originFarmerId");
    assert.equal(resultSecondParams[4], 0, "Error: Invalid state");
  });

  it("should test the harvestItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.harvestItem(upc, harvestNotes);

    truffleAssert.eventEmitted(event, "Harvested");

    const resultSecondParams = await supplyChain.fetchItemSecondParams(upc);

    assert.equal(resultSecondParams[4], 1, "Error: Invalid state");
  });

  it("should test the auditItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.auditItem(upc, auditNotes);

    truffleAssert.eventEmitted(event, "Audited");

    const resultSecondParams = await supplyChain.fetchItemSecondParams(upc);

    assert.equal(resultSecondParams[4], 2, "Error: Invalid state");
  });

  it("should test the processItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.processItem(upc);

    truffleAssert.eventEmitted(event, "Processed");

    const resultSecondParams = await supplyChain.fetchItemSecondParams(upc);

    assert.equal(resultSecondParams[4], 3, "Error: Invalid state");
  });

  it("should test the produceItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.produceItem(upc, productNotes, price);

    truffleAssert.eventEmitted(event, "Produced");

    const resultSecondParams = await supplyChain.fetchItemSecondParams(upc);

    assert.equal(resultSecondParams[4], 4, "Error: Invalid state");
    assert.equal(resultSecondParams[3], price, "Error: Invalid price");
  });

  it("should test the certifyItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.certifyItem(upc, certifyNotes);

    truffleAssert.eventEmitted(event, "Certified");

    const resultSecondParams = await supplyChain.fetchItemSecondParams(upc);

    assert.equal(resultSecondParams[4], 5, "Error: Invalid state");
  });

  it("should test the packItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.packItem(upc);

    truffleAssert.eventEmitted(event, "Packed");

    const resultSecondParams = await supplyChain.fetchItemSecondParams(upc);

    assert.equal(resultSecondParams[4], 6, "Error: Invalid state");
  });

  it("should test the sellItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.sellItem(upc);

    truffleAssert.eventEmitted(event, "ReadyForSale");

    const resultSecondParams = await supplyChain.fetchItemSecondParams(upc);

    assert.equal(resultSecondParams[4], 7, "Error: Invalid state");
    assert.equal(resultSecondParams[8], distributorId, "Error: Invalid distributor id");
  });

  it("should test the buyItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.buyItem(upc);

    truffleAssert.eventEmitted(event, "Sold");

    const resultSecondParams = await supplyChain.fetchItemSecondParams(upc);

    assert.equal(resultSecondParams[4], 8, "Error: Invalid state");
  });

  it("should test the fetchItemFirstParam() function", async () => {
    const supplyChain = await SupplyChain.deployed();

    const resultFirstParams = await supplyChain.fetchItemFirstParams(upc);

    assert.equal(resultFirstParams[0], sku, "Error: Invalid sku");
    assert.equal(resultFirstParams[1], upc, "Error: Invalid upc");
    assert.equal(resultFirstParams[2], ownerId, "Error: Invalid ownerId");
    assert.equal(resultFirstParams[3], originFarmerId, "Error: Invalid originFarmerId");
    assert.equal(resultFirstParams[4], originFarmName, "Error: Invalid originFarmName");
    assert.equal(resultFirstParams[5], originFarmInformation, "Error: Invalid originFarmInformation");
    assert.equal(resultFirstParams[6], originFarmLatitude, "Error: Invalid originFarmLatitude");
    assert.equal(resultFirstParams[7], originFarmLongitude, "Error: Invalid originFarmLongitude");
    assert.equal(resultFirstParams[8], auditNotes, "Error: Invalid auditNotes");
    assert.equal(resultFirstParams[9], harvestNotes, "Error: Invalid harvestNotes");
  });

  it("should test the fetchItemSecondParam() function", async () => {
    const supplyChain = await SupplyChain.deployed();

    const resultSecondParams = await supplyChain.fetchItemSecondParams(upc);

    assert.equal(resultSecondParams[0], sku, "Error: Invalid sku");
    assert.equal(resultSecondParams[1], upc, "Error: Invalid upc");
    assert.equal(resultSecondParams[2], productId, "Error: Invalid productId");
    assert.equal(resultSecondParams[3], price, "Error: Invalid price");
    assert.equal(resultSecondParams[4], 9, "Error: Invalid state");
    assert.equal(resultSecondParams[5], ownerId, "Error: Invalid ownerId");
    assert.equal(resultSecondParams[6], producerId, "Error: Invalid producerId");
    assert.equal(resultSecondParams[7], distributorId, "Error: Invalid distributorId");
    assert.equal(resultSecondParams[8], consumerId, "Error: Invalid consumerId");
    assert.equal(resultSecondParams[9], productNotes, "Error: Invalid productNotes");
    assert.equal(resultSecondParams[10], certifyNotes, "Error: Invalid certifyNotes");
  });
});
