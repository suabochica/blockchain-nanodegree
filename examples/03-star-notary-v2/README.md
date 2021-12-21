# 🌟 Start Notary ERC-721


## 🏗️ Set Up

1. Verify if truffle is installed globally

```
$ truffle version
```

it should return

```
Truffle v5.4.23 (core: 5.4.23)
Solidity v0.5.16 (solc-js)
Node v14.15.4
Web3.js v1.5.3
```

2. If truffle is not installed use the next command to install it

```
$ npm i -g truffle
```

3. Create the folder that will store the DApp

```
$ mkdir start-notary-v1
$ cd start-notary-v1
```

4. Use the truffle box for webpack. Truffle boxes are useful boiler plates that allow you to focus on the DApp. Please check the [truffle boxes](http://trufflesuite.com/boxes/) for more setups

```
$ truffle unbox webpack
```

5. To start the truffle serve just run:

```
$ truffle develop
```