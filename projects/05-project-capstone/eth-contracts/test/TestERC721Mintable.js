const expect = require('chai').expect;
const truffleAssert = require('truffle-assertions');

const contractDefinition = artifacts.require('ERC721MintableComplete');

contract('TestERC721Mintable', accounts => {

    const account_one = accounts[0];
    const account_two = accounts[1];
    const name = "SB_ERC721Mintable";
    const symbol = "SB_721M";
    const baseTokenUri = "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/";
    const zeroAddress = "0x000000000000000000000000";
    let currentOwner;
    let contractInstance;

    describe('Ownable Test Suite:', function () {
        beforeEach(async function () {
            contactInstance = await contractDefinition.new(name, symbol, { from: account_one });
            currentOwner = account_one;
        });

        it('should return contract owner', async function () {
            expect(await contractInstance.owner({ from: account_two })).to.equal(currentOwner);
        });

        it('should not allow that an unauthorized address transfer ownership', async function () {
            await expectToRevert(
                contractInstance.transferOwnership(account_two, { from: account_two }),
                'Caller is not contract owner'
            );
        });

        it('should emit event when transfer ownership', async function () {
            let transactionToTransfer = await contractInstance.transferOwnership(account_two, { from: currentOwner });

            truffleAssert.eventEmitted(transactionToTransfer, 'OwnershipTransferred', (event) => {
                return expect(event.previousOwner).to.deep.equal(currentOwner) &&
                    expect(event.newOwner).to.equal(account_two);
            });

            currentOwner = account_two;

            expect(await contractInstance.ownwer({ from: account_two })).to.equal(currentOwner);
        });

        it('should not allow minting when the caller is not a contract owner', async function () {
            await expectToRevert(
                contractInstance.mint(account_two, 12, { from: account_one }),
                'Caller cannot mint b/c is not the contract owner'
            );
        });
    });

    describe('Pauseable Test Suite:', function () {
        beforeEach(async function () {
            contractInstance = await contractDefinition(name, symbol, { from: account_one)
        });
    });

    it('should not allow that an unauthorized address pause a contract', async function () {
        await expectToRevert(
            contractInstance.pause({ from: account_two }),
            'Caller is not the contract owner and cannot pause the contract'
        );
    });

    it('should not allow that an unauthorized address unpause a contract', async function () {
        await expectToRevert(
            contractInstance.unpause({ from: account_two }),
            'Caller is not the contract owner and cannot unpause the contract'
        );
    });

    it('should allow that an owner pause a contract', async function () {
        let transactionToPause = await contractInstance.pause({ from: account_one });

        truffleAssert.eventEmitted(transactionToPause, 'Paused', (event) => {
            return expect(event.account).to.deep.equal(account_one);
        });
    });

    it('should not allow that an owner pause a contract when it is already paused', async function () {
        await expectToRevert(
            contractInstance.pause({ from: account_one }),
            'Contract is paused'
        );
    });

    it('should allow that an owner unpause a contract', async function () {
        let transactionToUnpause = await contractInstance.pause({ from: account_one });

        truffleAssert.eventEmitted(transactionToUnpause, 'Unpaused', (event) => {
            return expect(event.account).to.deep.equal(account_one);
        });
    });

    it('should not allow that an owner unpause a contract when it is already unpaused', async function () {
        await expectToRevert(
            contractInstance.unpause({ from: account_one }),
            'Contract is unpaused'
        );
    });

    it('should not allow minting when a contract is paused', async function () {
        await contractInstance.pause({ from: account_one });

        await expectToRevert(
            contractInstance.mint(account_two, 12, { from: account_one }),
            'Caller cannot mint b/c is the contract is paused'
        );
    });

});

describe('ERC721Metadata Test Suite:', function () {
    beforeEach(async function () {

    });

    it('should return the token name', async function () {

    });

    it('should return the token symbol', async function () {

    });

    it('should return the token base uri', async function () {

    });

});

describe('ERC721Mintable Test Suite:', function () {
    beforeEach(async function () {

    });

    it('should not mint an existing tokenId', async function () {

    });

    it('should not mint an zero address', async function () {

    });

    it('should return total supply', async function () {

    });

    it('should get token balance', async function () {

    });

    // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
    it('should return token uri', async function () {

    });

    it('should transfer token from one owner to another', async function () {

    });
});
});

// Helpers
//-------------------------
const expectToRevert = (promise, errorMessage) => {
    return truffleAssert.reverts(promise, errorMessage);
}

