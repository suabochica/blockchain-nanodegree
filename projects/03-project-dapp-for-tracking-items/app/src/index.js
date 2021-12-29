import Web3 from "web3";
import supplyChainArtifact from "../../build/contracts/SupplyChain.json";

const App = {
  web3: null,
  account: null,
  supplyChain: null,

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

    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
  },

  bindClickEvent: function () {
    document.addEventListener("click", this.handleButtonClick());
  },

  handleButtonClick: async function (event) {
    event.preventDefault();

    let statusId = event.target.getAttribute('data-id');
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
        return await this.fetchItemLastParams(event);
        break;
      case 12:
        return await this.fetchEvents();
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

    let statusId = event.target.getAttribute('data-id');
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

    let statusId = event.target.getAttribute('data-id');
    statusId = parseInt(statusId);

    const { auditItem } = this.supplyChain.methods;

    await auditItem(upc, auditNotes).send({ from: this.account });
  },

  processItem: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    let statusId = event.target.getAttribute('data-id');
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

    let statusId = event.target.getAttribute('data-id');
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
    let statusId = event.target.getAttribute('data-id');
    statusId = parseInt(statusId);

    const { certifyItem } = this.supplyChain.methods;

    await certifyItem(upc, certifyNotes).send({ from: this.account });
  },

  packItem: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    let statusId = event.target.getAttribute('data-id');
    statusId = parseInt(statusId);

    const { packItem } = this.supplyChain.methods;

    await packItem(upc).send({ from: this.account });
  },

  sellItem: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    let statusId = event.target.getAttribute('data-id');
    statusId = parseInt(statusId);

    const { sellItem } = this.supplyChain.methods;

    await sellItem(upc).send({ from: this.account });
  },

  buyItem: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    let statusId = event.target.getAttribute('data-id');
    statusId = parseInt(statusId);

    const { buyItem } = this.supplyChain.methods;

    await buyItem(upc).send({ from: this.account });
  },

  fetchItemFirstParams: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    let statusId = event.target.getAttribute('data-id');
    statusId = parseInt(statusId);

    const { fetchItemFirstParams } = this.supplyChain.methods;

    await fetchItemFirstParams(upc).send({ from: this.account });
  },

  fetchItemLastParams: async function (event) {
    event.preventDefault();

    const upc = document.getElementById("upc").value;
    let statusId = event.target.getAttribute('data-id');
    statusId = parseInt(statusId);

    const { fetchItemLastParams } = this.supplyChain.methods;

    await fetchItemLastParams(upc).send({ from: this.account });
  },

  fetchEvents: async function () {
    const { currentProvider } = this.supplyChain;
    const { sendAsync } = this.supplyChain.currentProvider;
    const history = document.getElementById("recorded-events");

    if (typeof sendAsync !== "function") {
      sendAsync = function () {
        return currentProvider.send.apply(currentProvider, args);
      }
    }

    const { allEvents } = this.supplyChain
    await allEvents(error, log)

    history.appendChild('<li>' + log.event + ' - ' + log.transactionHash + '</li>');
  }
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
