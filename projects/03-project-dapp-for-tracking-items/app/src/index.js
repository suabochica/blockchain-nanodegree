import Web3 from "web3";
import supplyChainArtifact from "../../build/contracts/SupplyChain.json";

const App = {
  web3: null,
  account: null,
  meta: null,

  start: async function () {
    const { web3 } = this;

    try {
      // get contract instance
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = supplyChainArtifact.networks[networkId];
      this.meta = new web3.eth.Contract(
        supplyChainArtifact.abi,
        deployedNetwork.address,
      );

      // get accounts
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];

      this.readForm();
    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
  },

  readForm: function () {
    const sku = document.getElementById("sku").value;
    const upc = document.getElementById("upc").value;
    const ownerId = document.getElementById("ownerId").value;
    const originFarmerId = document.getElementById("originFarmerId").value;
    const originFarmName = document.getElementById("originFarmName").value;
    const originFarmInformation = document.getElementById("originFarmInformation").value;
    const originFarmLatitude = document.getElementById("originFarmLatitude").value;
    const originFarmLongitude = document.getElementById("originFarmLongitude").value;
    const harvestNotes = document.getElementById("harvestNotes").value;
    const auditNotes = document.getElementById("auditNotes").value;
    const producerId = document.getElementById("producerId").value;
    const price = document.getElementById("price").value;
    const productNotes = document.getElementById("productNotes").value;
    const certifyNotes = document.getElementById("certifyNotes").value;
    const distributorId = document.getElementById("distributorId").value;
    const consumerId = document.getElementById("consumerId").value;

    console.log("sku:", sku);
    console.log("upc:", upc);
    console.log("ownerId:", ownerId);
    console.log("originFarmerId:", originFarmerId);
    console.log("originFarmName:", originFarmName);
    console.log("originFarmInformation:", originFarmInformation);
    console.log("originFarmLatitude:", originFarmLatitude);
    console.log("originFarmLongitude:", originFarmLongitude);
    console.log("harvestNotes:", harvestNotes);
    console.log("auditNotes:", auditNotes);
    console.log("producerId:", producerId);
    console.log("price:", price);
    console.log("productNotes:", productNotes);
    console.log("certifyNotes:", certifyNotes);
    console.log("distributorId:", distributorId);
    console.log("consumerId:", consumerId);
  },

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

    let statusId = event.target;
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

  plantItem: function (event) { },

  harvestItem: function (event) { },

  auditItem: function (event) { },

  processItem: function (event) { },

  produceItem: function (event) { },

  certifyItem: function (event) { },

  packItem: function (event) { },

  sellItem: function (event) { },

  sellItem: function (event) { },

  buyItem: function (event) { },

  fetchItemFirstParams: function (event) { },

  fetchItemSecondParams: function (event) { },

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
