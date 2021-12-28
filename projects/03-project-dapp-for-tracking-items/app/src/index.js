import Web3 from "web3";
import supplyChainArtifact from "../../build/contracts/SupplyChain.json";

const App = {
  web3: null,
  account: null,
  supplyChain: null,
  // emptyAddress: "0x0000000000000000000000000000000000000000",
  // metaMaskAccountId: "0x0000000000000000000000000000000000000000",
  // sku: 0,
  // upc: 0,
  // productId: 0,
  // ownerId: "0x0000000000000000000000000000000000000000",
  // originFarmerId: "0x0000000000000000000000000000000000000000",
  // originFarmName: "",
  // originFarmInformation: null,
  // originFarmLatitude: null,
  // originFarmLongitude: null,
  // harvestNotes: "",
  // auditNotes: "",
  // producerId: "0x0000000000000000000000000000000000000000",
  // price: 0,
  // productNotes: "",
  // certifyNotes: "",
  // distributorId: "0x0000000000000000000000000000000000000000",
  // consumerId: "0x0000000000000000000000000000000000000000",


  start: async function () {
    const { web3 } = this;

    try {
      // get contract instance
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = supplyChainArtifact.networks[networkId];
      this.supplyChain = new web3.eth.Contract(
        supplyChainArtifact.abi,
        deployedNetwork.address,
      );

      // get accounts
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];

      // this.readForm();
    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
  },

  // readForm: function () {
  //   App.sku = document.getElementById("sku").value;
  //   App.upc = document.getElementById("upc").value;
  //   App.productId = document.getElementById("productId").value;
  //   App.ownerId = document.getElementById("ownerId").value;
  //   App.originFarmerId = document.getElementById("originFarmerId").value;
  //   App.originFarmName = document.getElementById("originFarmName").value;
  //   App.originFarmInformation = document.getElementById("originFarmInformation").value;
  //   App.originFarmLatitude = document.getElementById("originFarmLatitude").value;
  //   App.originFarmLongitude = document.getElementById("originFarmLongitude").value;
  //   App.harvestNotes = document.getElementById("harvestNotes").value;
  //   App.auditNotes = document.getElementById("auditNotes").value;
  //   App.producerId = document.getElementById("producerId").value;
  //   App.price = document.getElementById("price").value;
  //   App.productNotes = document.getElementById("productNotes").value;
  //   App.certifyNotes = document.getElementById("certifyNotes").value;
  //   App.distributorId = document.getElementById("distributorId").value;
  //   App.consumerId = document.getElementById("consumerId").value;

  //   console.log("sku:", App.sku);
  //   console.log("upc:", App.upc);
  //   console.log("productId:", App.productId);
  //   console.log("ownerId:", App.ownerId);
  //   console.log("originFarmerId:", App.originFarmerId);
  //   console.log("originFarmName:", App.originFarmName);
  //   console.log("originFarmInformation:", App.originFarmInformation);
  //   console.log("originFarmLatitude:", App.originFarmLatitude);
  //   console.log("originFarmLongitude:", App.originFarmLongitude);
  //   console.log("harvestNotes:", App.harvestNotes);
  //   console.log("auditNotes:", App.auditNotes);
  //   console.log("producerId:", App.producerId);
  //   console.log("price:", App.price);
  //   console.log("productNotes:", App.productNotes);
  //   console.log("certifyNotes:", App.certifyNotes);
  //   console.log("distributorId:", App.distributorId);
  //   console.log("consumerId:", App.consumerId);
  // },

  sendCoin: async function () {
    const amount = parseInt(document.getElementById("amount").value);
    const receiver = document.getElementById("receiver").value;

    this.setStatus("Initiating transaction... (please wait)");

    const { sendCoin } = this.meta.methods;
    await sendCoin(receiver, amount).send({ from: this.account });

    this.setStatus("Transaction complete!");
    this.refreshBalance();
  },

  setStatus: function (message) {
    const status = document.getElementById("status");
    status.innerHTML = message;
  },

  bindClickEvent: function () {
    document.addEventListener("click", this.handleButtonClick());
  },

  handleButtonClick: async function (event) {
    event.preventDefault();

    let statusId = parseInt(event.target.getAttribute('data-id'));
    console.log("statusId", statusId);

    switch (statusId) {
      case 1:
        return await this.plantItem(event);
        break;
      case 2:
        return await this.harvestItem(event);
        break;
      case 3:
        return await this.auditItem(event);
        break;
      case 4:
        return await this.processItem(event);
        break;
      case 5:
        return await this.produceItem(event);
        break;
      case 6:
        return await this.certifyItem(event);
        break;
      case 7:
        return await this.packItem(event);
        break;
      case 8:
        return await this.sellItem(event);
        break;
      case 9:
        return await this.buyItem(event);
        break;
      case 10:
        return await this.fetchItemFirstParams(event);
        break;
      case 11:
        return await this.fetchItemSecondParams(event);
        break;
    }
  },

  plantItem: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    const productId = document.getElementById("productId").value;
    const originFarmerId = document.getElementById("originFarmerId").value;
    const originFarmName = document.getElementById("originFarmName").value;
    const originFarmInformation = document.getElementById("originFarmInformation").value;
    const originFarmLatitude = document.getElementById("originFarmLatitude").value;
    const originFarmLongitude = document.getElementById("originFarmLongitude").value;

    let statusId = event.target.getAttribute('data-id');
    statusId = parseInt(statusId);

    const { plantItem } = this.supplyChain.methods;

    await plantItem(
      upc,
      productId,
      originFarmerId,
      originFarmName,
      originFarmInformation,
      originFarmLatitude,
      originFarmLongitude
    ).send({ from: this.account });
  },

  harvestItem: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    const ownerId = document.getElementById("ownerId").value;
    const harvestNotes = document.getElementById("harvestNotes").value;

    let statusId = parseInt(event.target.getAttribute('data-id'));
    statusId = parseInt(statusId);

    const { harvestItem } = this.supplyChain.methods;

    await harvestItem(
      upc,
      harvestNotes,
    ).send({ from: this.account });
  },

  auditItem: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    const auditNotes = document.getElementById("auditNotes").value;

    let statusId = parseInt(event.target.getAttribute('data-id'));
    statusId = parseInt(statusId);

    const { auditItem } = this.supplyChain.methods;

    await auditItem(upc, auditNotes).send({ from: this.account });
  },

  processItem: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    let statusId = parseInt(event.target.getAttribute('data-id'));
    statusId = parseInt(statusId);

    const { processItem } = this.supplyChain.methods;

    await processItem(upc).send({ from: this.account });
  },

  produceItem: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    const producerId = document.getElementById("producerId").value;
    const productNotes = document.getElementById("productNotes").value;
    const price = document.getElementById("price").value;

    let statusId = parseInt(event.target.getAttribute('data-id'));
    statusId = parseInt(statusId);

    const { produceItem } = this.supplyChain.methods;

    await produceItem(
      upc,
      productNotes,
      price,
    ).send({ from: this.account });
  },

  certifyItem: async function (event) {
    event.preventDefault();
    const certifyNotes = document.getElementById("certifyNotes").value;

    const upc = document.getElementById("upc").value;
    let statusId = parseInt(event.target.getAttribute('data-id'));
    statusId = parseInt(statusId);

    const { certifyItem } = this.supplyChain.methods;

    await certifyItem(upc, certifyNotes).send({ from: this.account });
  },

  packItem: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    let statusId = parseInt(event.target.getAttribute('data-id'));
    statusId = parseInt(statusId);

    const { packItem } = this.supplyChain.methods;

    await packItem(upc).send({ from: this.account });
  },

  sellItem: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    let statusId = parseInt(event.target.getAttribute('data-id'));
    statusId = parseInt(statusId);

    const { sellItem } = this.supplyChain.methods;

    await sellItem(upc).send({ from: this.account });
  },

  buyItem: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    let statusId = parseInt(event.target.getAttribute('data-id'));
    statusId = parseInt(statusId);

    const { buyItem } = this.supplyChain.methods;

    await buyItem(upc).send({ from: this.account });
  },

  fetchItemFirstParams: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    let statusId = parseInt(event.target.getAttribute('data-id'));
    statusId = parseInt(statusId);

    const { fetchItemFirstParams } = this.supplyChain.methods;

    await fetchItemFirstParams(upc).send({ from: this.account });
  },

  fetchItemSecondParams: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    let statusId = parseInt(event.target.getAttribute('data-id'));
    statusId = parseInt(statusId);

    const { fetchItemSecondParams } = this.supplyChain.methods;

    await fetchItemSecondParams(upc).send({ from: this.account });
  },
};

window.App = App;

window.addEventListener("load", function () {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum);
    window.ethereum.enable(); // get permission to access accounts
  } else {
    console.warn(
      "No web3 detected. Falling back to http://127.0.0.1:8545. You should remove this fallback when you deploy live",
    );
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:8545"),
    );
  }

  App.start();
});
