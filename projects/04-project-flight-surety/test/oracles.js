
var Test = require('../config/testConfig.js');
const { expect, assert } = require("chai"):

//var BigNumber = require('bignumber.js');
const {
  BN,
  constants,
  expectEvent,
  expectRevert,
  balance,
  ether,
  send
} = require("@openzeppelin/test-helpers")

contract('Oracle functionality', async (accounts) => {

  // Watch contract events
  const STATUS_CODE_UNKNOWN = 0;
  const STATUS_CODE_ON_TIME = 10;
  const STATUS_CODE_LATE_AIRLINE = 20;
  const STATUS_CODE_LATE_WEATHER = 30;
  const STATUS_CODE_LATE_TECHNICAL = 40;
  const STATUS_CODE_LATE_OTHER = 50;

  let config;
  let app;
  let actors;
  let actorsName;
  let oracles;
  let oracleRegistrationFee;
  let minOracleResponse;

  before('setup contract', async () => {
    config = await Test.Config(accounts);
    app = config.flightSuretyApp;
    actors = config.actors;
    actorsName = config.actorsName;
    oracles = config.oracles;
    oracleRegistrationFee = ether("1");
    minOracleResponse = 3;
  });

  describe("on time flight", () => {
    let airlineFundingAmount;
    let insuranceAmount;
    let flightName;
    let flightAirline;
    let departureTime;
    let passengerAddress;

    before("setup flight", () => {
      airlineFundingAmount = ether("10");
      insuranceAmount = ether("1");
      flightName = "ND1309";
      flightAirline = actors.airline1;
      departureTime = "1609623567158";
      passengerAddress = actors.passenger1;

      console.log('💺 : Flight')
      console.log(`Passenger address: ${passengerAddress}`);
      console.log(`Flight airline: ${flightAirline}`);
      console.log(`Flight name: ${flightName}`);
      console.log(`Departure time: ${departureTime}`);
    });

    it("should can register oracles", async () => {
      oracles.forEach(async (oracleAccount) => {
        let transactionToRegister = await app.registerOracle({
          from: oracleAccount,
          value: oracleRegistrationFee
        });
        let result = await app.getMyIndexes.call({ from: oracleAccount });

        expectEvent(transactionToRegister, "OracleRegistered", {
          oracleAddress: oracleAccount,
          indexes: result
        });

        expect(await app.isOracleRegistered.call(oracleAccount)).to.be.true;
      });
    });

    it("should can fund an airline", async () => {
      expect(await app.isAirlineRegistered.call(flightAirline)).to.be.true;

      let transactionToFund = await app.fundAirline({
        from: flightAirline,
        value: airlineFundingAmount
      });

      expectEvent(transactionToFund, "AirlineFunded", {
        airlineAddress: flightAirline,
        amount: airlineFundingAmount
      });

      expect(await app.isAirlineFunded.call(flightAirline)).to.be.true;
    });

    it("should can register a flight", async () => {
      let transactionToRegister = await app.registerFlight(
        flightName,
        departureTime,
        { from: flightAirline, }
      );

      expectEvent(transactionToRegister, "FlightRegistered", {
        airlineAddress: flightAirline,
        amount: airlineFundingAmount
      });

      expect(
        await app.isFlightRegistered.call(
          flightAirline,
          flightName,
          departureTime
        )
      ).to.be.true;
    });

    it("should can purchase insurance", async () => {
      let transactionToBuy = await app.buyFlightInsurance(
        flightAirline,
        flightName,
        departureTime,
        { from: passengerAddress, value: insuranceAmount }
      )

      expectEvent(transactionToBuy, "InsurancePurchased", {
        passengerAddress: passengerAddress,
        amount: insuranceAmount
      });

      expect(
        await app.isPassengerInsure.call(
          passengerAddress,
          flightAirline,
          flightName,
          departureTime
        )
      ).to.be.true;
    });

    it("should get initial status as unknown", async () => {
      let status = await app.getFlightStatus.call(
        flightAirline,
        flightName,
        departureTime,
        { from: passengerAddress }
      );

      expect(status.toNumber()).to.be.equal(STATUS_CODE_UNKNOWN);
    })

    it("should fetch flight status", async () => {
      expect(
        await app.isFlightRegistered.call(
          flightAirline,
          flightName,
          departureTime
        )
      ).to.be.true;

      expectEvent(
        await app.fetchFlightStatus(
          flightAirline,
          flightName,
          departureTime,
          { from: passengerAddress }
        ), "OracleRequest", {
        airline: flightAirline,
        flight: flightName,
        departureTime: departureTime
      }
      )
    });

    it("should report flight status", async () => {
      let verifiedResponses = 0;
      let promises = Promise.all(
        oracles.map(async (oracleAccount) => {
          expect(await app.isOracleRegistered.call(oracleAccount)).to.be.true;
          let oracleIndexes = await app.getMyIndexes.call({ from: oracleAccount });

          expect(oracleIndexes).to.have.lengthOf(3);

          for (let index = 0; index < 3; index++) {
            try {
              await app.submitOracleResponse(
                oracleIndexes[index],
                flightAirline,
                flightName,
                departureTime,
                STATUS_CODE_LATE_AIRLINE,
                { from: oracleAccount }
              );

              verifiedResponse++;
            } catch (error) {
              console.log(`🚨 : ${error}`)
            }
          }
        })
      );

      await promises;

      expect(verifiedResponses).to.be.gte(minOracleResponse);
    })

    it("should verify flight status is late due to airline", async () => {
      let status = await app.getFlightStatus.call(
        flightAirline,
        flightName,
        departureTime,
        { from: passengerAddress }
      );

      expect(status.toNumber()).to.be.equal(STATUS_CODE_LATE_AIRLINE);
    });

    it("should verify insurance payout", async () => {
      let isFlightInsurancePaidOut = await app.isFlightInsurancePaidOut(
        flightAirline,
        flightName,
        departureTime,
        { from: passengerAddress }
      );

      assert.equal(isFlightInsurancePaidOut, true, "Insurance was paid out")

      let passengerBalance = await app.getPassengerBalance(passengerAddress);

      expect(passengerBalance).to.be.bignumber.equal(ether("1.5"));
    });

    it("should passenger withdraw funds", async () => {
      let tracker = await balance.tracker(passengerAddress);

      await app.withdrawPassengerBalance(ether("1.5"), { from: passengerAddress });

      let delta = await tracker.delta();

      expect(delta).to.be.bignumber.gth(ether("1.499"));
    })

  });
});
