# 🏋 Udacity Blockchain Capstone

The capstone will build upon the knowledge you have gained in the course in order to build a decentralized housing product. 

## ⚙️ Install

This repository contains Smart Contract code in Solidity (using Truffle), tests (also using Truffle), dApp scaffolding (using HTML, CSS and JS) and server app scaffolding.

To install, download or clone the repo, then:

`npm install`
`truffle compile`

## 👨‍💻 Develop Client

To run truffle tests:

`truffle test ./eth-contracts/test/TestERC721Mintable.js`

To use the dapp:

`truffle migrate`
`npm run app`

To view dapp:

`http://localhost:8000`

## 🚀 Deploy

To build dapp for prod:
`npm run app:prod`

Deploy the contents of the ./dapp folder

## 🕹️ Zokrates

Run the zokrates docker image:

```
docker run -v ~/Development/blockchain-nanodegree/projects/05-project-capstone/zokrates/code:/home/zokrates/code -ti zokrates/zokrates /bin/bash
```

Compile the program

```
zokrates compile -i code/square/square.code
```

Generate the trusted zokrates setup

```
zokrates setup
```

Compute the witness for your desired pair of numbers under the format `number square` (e.g 3 9)

```
zokrates compute-witness -a 3 9
```

Generate the proof:

```
zokrates generate-proof
```

At this point there should be a `proof.json` file that contains `ProofA[]`, `ProofB[]` fields that can be used in the approve solution.

If you want, generate the ~Verifier.sol~ contract with:

```
zokrates export-verifier
```
## 🕹️ ABI

Below I share the generated `abi.json`

```
{
  "inputs": [
    {
      "name": "a",
      "public": false,
      "type": "field"
    },
    {
      "name": "b",
      "public": true,
      "type": "field"
    }
  ],
  "outputs": [
    {
      "type": "field"
    }
  ]
}

```

## 🌊 OpenSea

## 🧭 Resources

* [Remix - Solidity IDE](https://remix.ethereum.org/)
* [Visual Studio Code](https://code.visualstudio.com/)
* [Truffle Framework](https://truffleframework.com/)
* [Ganache - One Click Blockchain](https://truffleframework.com/ganache)
* [Open Zeppelin ](https://openzeppelin.org/)
* [Interactive zero knowledge 3-colorability demonstration](http://web.mit.edu/~ezyang/Public/graph/svg.html)
* [Docker](https://docs.docker.com/install/)
* [ZoKrates](https://github.com/Zokrates/ZoKrates)
