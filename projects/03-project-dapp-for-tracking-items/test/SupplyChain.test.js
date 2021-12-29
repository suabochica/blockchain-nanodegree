
const SupplyChain = artifacts.require("SupplyChain");
const truffleAssert = require("truffle-assertions");

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

  // Accounts:
  // (0) 0x6056eaa347edabb0418193281313bb4546c14ec4
  // (1) 0x836ebbe93aca2e476ec286b0dfd6ef527106e37e
  // (2) 0x2d525c92908b481ede5aec62736a265740acdb4d
  // (3) 0xba4806d27a2d69858328fe0b426c1d03038b7161
  // (4) 0xa1eef75f99ff244be00cdce018fb95b36983513a
  // (5) 0xff7bb7259db94a82fff86eb9ed3214ee39f8d449
  // (6) 0xb47d7fb99e6571550950f53e71c18f211c39b46b
  // (7) 0xd2feb8255743905a33784855c354ce24253df544
  // (8) 0xc9bdd79bc46b357590c791e71ebafcb35ad01f89
  // (9) 0xf23aa1a9c7369a9ba8ffde4604ca47a2fbc4d17e

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
    const resultLastParams = await supplyChain.fetchItemLastParams(upc);

    assert.equal(resultFirstParams[1], upc, "Error: Missing upc");
    assert.equal(resultFirstParams[3], originFarmerId, "Error: Missing originFarmerId");
    assert.equal(resultLastParams[4], 0, "Error: Invalid state");
  });

  it("should test the harvestItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.harvestItem(upc, harvestNotes);

    truffleAssert.eventEmitted(event, "Harvested");

    const resultLastParams = await supplyChain.fetchItemLastParams(upc);

    assert.equal(resultLastParams[4], 1, "Error: Invalid state");
  });

  it("should test the auditItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.auditItem(upc, auditNotes);

    truffleAssert.eventEmitted(event, "Audited");

    const resultLastParams = await supplyChain.fetchItemLastParams(upc);

    assert.equal(resultLastParams[4], 2, "Error: Invalid state");
  });

  it("should test the processItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.processItem(upc);

    truffleAssert.eventEmitted(event, "Processed");

    const resultLastParams = await supplyChain.fetchItemLastParams(upc);

    assert.equal(resultLastParams[4], 3, "Error: Invalid state");
  });

  it("should test the produceItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.produceItem(upc, productNotes, price);

    truffleAssert.eventEmitted(event, "Produced");

    const resultLastParams = await supplyChain.fetchItemLastParams(upc);

    assert.equal(resultLastParams[4], 4, "Error: Invalid state");
    assert.equal(resultLastParams[3], price, "Error: Invalid price");
  });

  it("should test the certifyItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.certifyItem(upc, certifyNotes);

    truffleAssert.eventEmitted(event, "Certified");

    const resultLastParams = await supplyChain.fetchItemLastParams(upc);

    assert.equal(resultLastParams[4], 5, "Error: Invalid state");
  });

  it("should test the packItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.packItem(upc);

    truffleAssert.eventEmitted(event, "Packed");

    const resultLastParams = await supplyChain.fetchItemLastParams(upc);

    assert.equal(resultLastParams[4], 6, "Error: Invalid state");
  });

  it("should test the sellItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.sellItem(upc);

    truffleAssert.eventEmitted(event, "ReadyForSale");

    const resultLastParams = await supplyChain.fetchItemLastParams(upc);

    assert.equal(resultLastParams[4], 7, "Error: Invalid state");
    assert.equal(resultLastParams[8], distributorId, "Error: Invalid distributor id");
  });

  it("should test the buyItem() function", async () => {
    const supplyChain = await SupplyChain.deployed();
    const event = await supplyChain.buyItem(upc);

    truffleAssert.eventEmitted(event, "Sold");

    const resultLastParams = await supplyChain.fetchItemLastParams(upc);

    assert.equal(resultLastParams[4], 8, "Error: Invalid state");
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
  });

  it("should test the fetchItemLastParam() function", async () => {
    const supplyChain = await SupplyChain.deployed();

    const resultLastParams = await supplyChain.fetchItemLastParams(upc);

    assert.equal(resultLastParams[0], sku, "Error: Invalid sku");
    assert.equal(resultLastParams[1], upc, "Error: Invalid upc");
    assert.equal(resultLastParams[2], productId, "Error: Invalid productId");
    assert.equal(resultLastParams[3], price, "Error: Invalid price");
    assert.equal(resultLastParams[4], 9, "Error: Invalid state");
    assert.equal(resultLastParams[5], producerId, "Error: Invalid producerId");
    assert.equal(resultLastParams[6], distributorId, "Error: Invalid distributorId");
    assert.equal(resultLastParams[7], consumerId, "Error: Invalid consumerId");
    assert.equal(resultLastParams[8], productNotes, "Error: Invalid productNotes");
  });
});
