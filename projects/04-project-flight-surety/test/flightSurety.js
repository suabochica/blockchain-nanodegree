
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
    it(`has correct initial isOperational() value`, async function () {
      // Get operating status
      let status = await app.isOperational.call();

      assert.equal(status, true, "Incorrect initial operating status value");
    });

    it(`can block access to setOperatingStatus() for non-Contract Owner account`, async function () {
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

    it(`can allow access to setOperatingStatus() for Contract Owner account`, async function () {
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

    it(`can block access to functions using requireIsOperational when operating status is false`, async function () {

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
    describe("an airline can register a new airline until four airlines will registered", () => {
      before("nominate airlines", async () => {
        let tx2 = await app.nominateAirline(actors.airline2, { from: actors.airline1 })
        let tx3 = await app.nominateAirline(actors.airline3, { from: actors.airline1 })
        let tx4 = await app.nominateAirline(actors.airline4, { from: actors.airline1 })
        let tx5 = await app.nominateAirline(actors.airline5, { from: actors.airline1 })

        expectEvent(tx2, 'AirlineNominated', {
          airlineAddress: actors.airline2,
        });

        expectEvent(tx3, 'AirlineNominated', {
          airlineAddress: actors.airline3,
        });

        expectEvent(tx4, 'AirlineNominated', {
          airlineAddress: actors.airline4,
        });

        expectEvent(tx5, 'AirlineNominated', {
          airlineAddress: actors.airline5,
        });
      });

      it("should register first airline when contract is deployed", async () => {
        let transaction = false;
        let throwError = false;

        try {
          transaction = await app.isAirlineRegistered(actors.airline1);
        } catch (error) {
          throwError = true;
        }

        assert.equal(transaction, true, "first airline is no registered upon deployment")
        assert.equal(throwError, false, "unexpected error")
      });

      it("should not allow that an unregistered airline register a new one", async () => {
        await expectRevert(
          app.registerAirline(actors.airline2, { from: actors.airline3 }),
          'only funded airlines can register a new one'
        );
      });

      it("should not allow participate in contract until it submit funding of 10 ether", async () => {
        await expectRevert(
          app.registerAirline(actors.airline2, { from: actors.airline1 }),
          'only funded airlines can register a new one'
        );

        let fundingAmount = ether('10');
        let transaction = await app.fundAirline({ from: actors.airline1, value: fundingAmount })

        await expectEvent(transaction, 'AirlineFunded', {
          airlineAddress: actors.airline1,
          amount: fundingAmount
        });

        let result = await app.getAirlineFundsAmount(actors.airline1);

        expect(result).to.be.bignumber.equal(fundingAmount);
      });

      it("should allow that the first airline register the second one", async () => {
        let transaction = await app.registerAirline(actors.airline2, { from: actors.airline1 });

        expectEvent(transaction, 'AirlineRegistered', { airlineAddress: actors.airline2 });
      })

      it("should not register an airline that is already registered", async () => {
        await expectRevert(
          app.registerAirline(actors.airline2, { from: actors.airline1 }),
          'Airline is already registered'
        );
      });

      it("should allow that the second airline register the third one", async () => {
        let fundingAmount = ether('10');
        let transactionToFund = await app.fundAirline({ from: actors.airline2, value: fundingAmount })

        await expectEvent(transactionToFund, 'AirlineFunded', {
          airlineAddress: actors.airline2,
          amount: fundingAmount
        });

        let transactionToRegister = await app.registerAirline(actors.airline3, { from: actors.airline2 });

        expectEvent(transactionToRegister, 'AirlineRegistered', { airlineAddress: actors.airline3 });
      });

      it("should allow that the third airline register the fourth one", async () => {
        let fundingAmount = ether('10');
        let transactionToFund = await app.fundAirline({ from: actors.airline3, value: fundingAmount })

        await expectEvent(transactionToFund, 'AirlineFunded', {
          airlineAddress: actors.airline3,
          amount: fundingAmount
        });

        let transactionToRegister = await app.registerAirline(actors.airline4, { from: actors.airline3 });

        expectEvent(transactionToRegister, 'AirlineRegistered', { airlineAddress: actors.airline4 });
      });
    });

    describe("registration after the fifth airline requires multiparty consensus", () => {
      it("should not allow that the fourth airline register the fifth one without consensus", async () => {
        let fundingAmount = ether('10');
        let transactionToFund = await app.fundAirline({ from: actors.airline4, value: fundingAmount })

        await expectEvent(transactionToFund, 'AirlineFunded', {
          airlineAddress: actors.airline4,
          amount: fundingAmount
        });

        let transactionToRegister = await app.registerAirline(actors.airline5, { from: actors.airline4 });

        expectEvent.notEmitted(transactionToRegister, 'AirlineRegistered');

        let votes = await data.getAirlineVotes.call(actors.airline5);

        assert.equal(votes, 1, 'Expect only one vote has been cast for fifth airline')
      });

      it("should enable registration upon the 50% threshold registered airline votes", async () => {
        let transactionToRegister = await app.registerAirline(actors.airline5, { from: actors.airline3 });

        expectEvent(transactionToRegister, 'AirlineRegistered', { airlineAddress: actors.airline5 });

        let votes = await data.getAirlineVotes.call(actors.airline5);

        assert.equal(votes, 2, 'Expect two votes has been cast for fifth airline')

        let fundingAmount = ether("10");
        let transactionToFund = await app.fundAirline({ from: actors.airline5, value: fundingAmount });

        expectEvent(transactionToFund, 'AirlineFunded', {
          airlineAddress: actors.airline5,
          amount: fundingAmount
        });
      });

      it("should be all the airlines fund", async () => {
        airlines.forEach(async (airlineAddress) => {
          let result = await app.isAirlineFunded(airlineAddress);

          assert.equal(result, true);
        });
      });

      it("should be 50 ether the data contract balance", async () => {
        let tracker = await balance.tracker(data.address, uint = 'wei');
        let expectedEther = ether('50');
        let actualEther = await tracker.get();

        expect(actualEther).to.be.bignumber.equal(expectedEther);
      });
    })

    describe("airlines can register flights and passengers can purchase insurance", () => {
      it("should each airline be able to register a flight", async () => {
        flights.forEach(async (flight) => {
          let flightAirline = flight[0];
          let flightName = flight[1];
          let departureTime = flight[2];
          let transactionToRegister = await app.registerFlight(
            flightName,
            departureTime,
            { from: flightAirline }
          );

          expectEvent(transactionToRegister, 'FlightRegistered', {
            airlineAddress: flightAirline,
            flight: flightName
          });

          let registrationStatus = await app.isFlightRegistered(flightAirline, flightName, departureTime);

          assert.equal(registrationStatus, true, 'Flight registered');
        });
      });

      it("should allow that a passenger purchase insurance on a flight", async () => {
        let insuranceAmount = ether('1');

        passengers.forEach(async (passengerAddress, index) => {
          let flight = flights[index];
          let flightName = flight[1];
          let departureTime = flight[2];
          let transactionToBuy = await app.buyFlightInsurance(
            flightAirline,
            flightName,
            departureTime,
            { from: passengerAddress, value: insuranceAmount }
          );

          expectEvent(transactionToBuy, 'InsurancePurchased', {
            passengerAddress: passengerAddress,
            amount: insuranceAmount
          });
        });
      });
    })
  });
});
