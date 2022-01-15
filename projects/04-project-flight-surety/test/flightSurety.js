
var Test = require('../config/testConfig.js');
var BigNumber = require('bignumber.js');
var { expect, assert } = require('chai');

const {
  BN,
  constants,
  expectEvent,
  expectRevert,
  balance,
  ether
} = require('@openzeppelin/test-helpers')

contract('Flight Surety Tests', async (accounts) => {

  let config;
  let data;
  let app;
  let actors;
  let actorsNames;
  let airlines;
  let flights;
  let passengers;
  let oracles;

  before('setup contract', async () => {
    config = await Test.Config(accounts);
    data = config.flightSuretyData;
    app = config.flightSuretyApp;
    actors = config.actors;
    actorsName = config.actorsNames;
    airlines = config.airlines;
    flights = config.flights;
    passengers = config.passengers;
    oracles = config.oracles;
  });

  describe("environment setup", () => {
    it("is properly configured", () => {
      assert.notEqual(config, null);
      assert.notEqual(data, null);
      assert.notEqual(app, null);
      assert.notEqual(actors, null);
      assert.notEqual(airlines, null);
      assert.notEqual(flights, null);
      assert.notEqual(oracles, null);

      console.log('💺 : Flights')
      for (const flightKey in flights) {
        if (actors.hasOwnProperty(flightKey)) {
          console.log(`${flightKey}: ${flights[flightKey]}`);
        }
      }

      console.log('🎭 : Actors')
      for (const actorKey in actors) {
        if (actors.hasOwnProperty(actorKey)) {
          console.log(`${actorKey}: ${actors[actorKey]}`);
        }
      }

      console.log('📦 : Oracles')
      for (const oracleKey in oracles) {
        if (actors.hasOwnProperty(oracleKey)) {
          console.log(`${oracleKey}: ${oracles[oracleKey]}`);
        }
      }
    });
  });

  describe("operations and settings", () => {
    it(`(multiparty) has correct initial isOperational() value`, async function () {
      // Get operating status
      let status = await app.isOperational.call();

      assert.equal(status, true, "Incorrect initial operating status value");
    });

    it(`(multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {
      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try {
        await app.setOperatingStatus(false, { from: actors.airline2 });
      }
      catch (e) {
        accessDenied = true;
      }

      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
    });

    it(`(multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {
      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      try {
        await app.setOperatingStatus(false, { from: config.contractOwner });
      }
      catch (e) {
        accessDenied = true;
      }

      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
    });

    it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {

      await app.setOperatingStatus(false, { from: config.contractOwner });

      let reverted = false;

      try {
        await app.registerAirline(actors.airline2, { from: airline1 })
      }
      catch (e) {
        reverted = true;
      }

      assert.equal(reverted, true, "Access not blocked for requireIsOperational");

      // Set it back for other tests to work
      await app.setOperatingStatus(true, { from: config.contractOwner });
    });
  });

  describe("business logic", () => {
    before("nominate arilines", async () => {
      // TODO:
    });
  });


  it('(airline) cannot register an Airline using registerAirline() if it is not funded', async () => {

    // ARRANGE
    let newAirline = accounts[2];

    // ACT
    try {
      await config.flightSuretyApp.registerAirline(newAirline, { from: config.firstAirline });
    }
    catch (e) {

    }
    let result = await config.flightSuretyData.isAirline.call(newAirline);

    // ASSERT
    assert.equal(result, false, "Airline should not be able to register another airline if it hasn't provided funding");

  });
});
