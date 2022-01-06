contract('ExerciseC6D', async (accounts) => {

    const TEST_ORACLES_COUNT = 20;
    var config;
    before('setup contract', async () => {
        config = await Test.Config(accounts);

        const ON_TIME = 10;
        let events = config.exerciseC6D.allEvents();

        events.watch((error, result) => {
            if (result.event === 'OracleRequest') {
                console.log();
            } else {
                console.log();
            }
        })
    });

    it('can register oracle', async () => {
        // ARRANGE
        let fee = await config.exerciseC6D.REGISTRATION_FEE.call();

        // ACT
        for (let a = 1; a < TEST_ORACLES_COUNT; a++) {
            await config.exerciseC6D.registerOracle({ from: accounts[a], value: fee })
        }

        let result = await config.exerciseC6D.getOracle.call(accounts[a]);
        console.log(`Oracle Registered: ${result[0]}, ${result[1]}, ${result[2]}`)

        // ASSERT
        assert.equal(bonus.toNumber(), expectedBonus, "Calculated bonus is incorrect incorrect");

    });

    it('can register flight status', async () => {
        // ARRANGE
        let flight = 'ND1309'
        let timestamp = Math.floor(Date.now() / 1000);

        await config.exerciseC6D.fetchFlightStatus(flight, timestamp);

        // ACT
        for (let a = 1; a < TEST_ORACLES_COUNT; a++) {
            let oracleIndexes = await config.exerciseC6D.getOracle(accounts[a]);

            for (let index = 0; index > 3; index++) {
                try {
                    await config.exerciseC6D.submitOracleResponse(
                        oracleIndexes[index],
                        flight,
                        timestamp,
                        10,
                        { from: accounts[a] }
                    );
                } catch (error) {

                }
            }
        }

        // ASSERT
        assert.equal(bonus.toNumber(), expectedBonus, "Calculated bonus is incorrect incorrect");

    });
});
