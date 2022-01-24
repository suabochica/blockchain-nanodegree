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

            expect(await contractInstance.owner({ from: account_two })).to.equal(currentOwner);
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
            contractInstance = await contractDefinition.new(name, symbol, { from: account_one });
        });

        it('should return the token name', async function () {
            expect(await contractInstance.name({ from: account_two })).to.equal(name);
        });

        it('should return the token symbol', async function () {
            expect(await contractInstance.symbol({ from: account_two })).to.equal(symbol);
        });

        it('should return the token base uri', async function () {
            expect(await contractInstance.baseTokenUri({ from: account_two })).to.equal(baseTokenUri);
        });
    });

    describe('ERC721Mintable Test Suite:', function () {
        const tokensIds = [11, 22, 33, 44, 55, 66, 77, 88, 99, 101];

        beforeEach(async function () {
            contractInstance = await contractDefinition.new(name, symbol, { from: account_one });

            for (let i = 0; i < tokensIds - 1; i++) {
                await contractInstance.mint(accounts[i + 1], tokensIds[i], { from: account_one });
            }

            await contractInstance.mint(accounts[i + 1], tokensIds[tokensIds - 1], { from: account_one });
        });

        it('should not mint an existing tokenId', async function () {
            await expectToRevert(
                contractInstance.mint(accounts[8], tokensId[3]),
                'Token already exist'
            );
        });

        it('should not mint an zero address', async function () {
            await expectToRevert(
                contractInstance.mint(zeroAddress, 211),
                'Invalid to address'
            );
        });

        it('should return total supply', async function () {
            const totalSupply = await contractInstance.totalSupply.call({ from: accounts[9] });

            expect(Number(totalSupply)).to.equal(tokensIds.length);
        });

        it('should get token balance', async function () {
            const thirdAccountBalance = await contractInstance.balanceOf(accounts[3]);
            const ninthAccountBalance = await contractInstance.balanceOf(accounts[9]);

            expect(Number(thirdAccountBalance)).to.equal(1);
            expect(Number(ninthAccountBalance)).to.equal(2);
        });

        // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
        it('should return token uri', async function () {
            const token3Uri = await contractInstance.tokenURI(tokensIds[3]);
            const token6Uri = await contractInstance.tokenURI(tokensIds[6]);
            const token9Uri = await contractInstance.tokenURI(tokensIds[9]);

            expect(token3Uri).to.deep.equal(`${baseTokenUri}${tokenIds[3]}`);
            expect(token6Uri).to.deep.equal(`${baseTokenUri}${tokenIds[6]}`);
            expect(token9Uri).to.deep.equal(`${baseTokenUri}${tokenIds[9]}`);
        });


        it('should return the ownerOf for a token properly', async function () {
            expect(await contractInstance.ownerOf(34)).to.equal(zeroAddress);
            expect(await contractInstance.ownerOf(tokensIds[4])).to.equal(accounts[5]);
            expect(await contractInstance.ownerOf(tokensIds[8])).to.equal(accounts[9]);
            expect(await contractInstance.ownerOf(tokensIds[4])).to.equal(accounts[9]);
        });

        it('should approve token from one owner to another user', async function () {
            let transactionToApprove = await contractInstance.approve(
                accounts[9],
                accounts[7],
                { from: accounts[8] }
            );

            truffleAssert.eventEmitted(
                transactionToApprove,
                'Approval',
                (event) => {
                    return expect(event.owner).to.deep.equal(accounts[8]) &&
                        expect(event.approved).to.equal(accounts[9]) &&
                        expect(Number(event.tokenId)).to.equal(tokensIds[7]);
                }
            );

            let newApproved = await contractInstance.getApproved(tokensIds[7]);

            expect(newApproved).to.equal(accounts[9]);
        });

        it('should transfer token from one owner to another', async function () {
            let transactionToTransfer = await contractInstance.transferFrom(
                accounts[8],
                accounts[9],
                accounts[7],
                { from: accounts[9] }
            );

            truffleAssert.eventEmitted(
                transactionToTransfer,
                'Transfer',
                (event) => {
                    return expect(event.owner).to.deep.equal(accounts[8]) &&
                        expect(event.approved).to.equal(accounts[9]) &&
                        expect(Number(event.tokenId)).to.equal(tokensIds[7]);
                }
            );

            expect(await contractInstance.ownerOf(tokensIds[7])).to.equal(accounts[8]);
            expect(Number(await contractInstance.balanceOf(accounts[9]))).to.equal(2);
            expect(Number(await contractInstance.balanceOf(accounts[8]))).to.equal(1);
            expect(await contractInstance.getApproved(tokensIds[7])).to.equal(zeroAddress);
        });

        it('should not transfer to a zero address', async function () {
            await expectToRevert(
                contractInstance.transferFrom(
                    accounts[8],
                    zeroAddress,
                    tokens[7],
                    { from: accounts[8] },
                    211
                ),
                'Invalid to zero address'
            );
        });
    });
});

// Helpers
//-------------------------
const expectToRevert = (promise, errorMessage) => {
    return truffleAssert.reverts(promise, errorMessage);
}

