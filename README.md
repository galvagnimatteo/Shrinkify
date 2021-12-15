# Shrinkify

A simple deflationary ERC-20 token with auto liquidity functionality.
A percentage of every transaction gets burned, reducing the total supply.
Another percentage of every transaction gets locked in the contract itself until
the contract's token balance exceed a set amount, then the tokens are used for 
liquidity and resulting LP tokens are sent to the contract's owner, locking that
part of the liquidity pool forever if ownership is renounced.

## Requirements

Truffle (and plugins) are needed to compile, deploy and verify the contract.
```
npm install -g truffle
npm install @truffle/hdwallet-provider
npm i truffle-plugin-verify
```

Openzeppelin libraries are required.
```
npm install @openzeppelin/contracts
```

Uniswap v2 periphery and core are required to create liquidity pair and supply liquidity on Uniswap/Quickswap/Pancakeswap.
```
npm i @uniswap/v2-periphery
npm i @uniswap/v2-core
```

Some files are not included for privacy, they need to be manually created:

`mnemonic.secret` with the mnemonic phrase of the contract's owner wallet.

`providerlink.secret` with the link to the node's provider of the choosen network, with API key if needed (Eg: https://polygon-mumbai.g.alchemy.com/v2/SECRET).

`apikey.secret` with your Etherscan/BSCscan/Polygonscan API key, for verifying the contract's code.

Note that the hardcoded Uniswap v2 router address only works on polygon testnet, it has to be changed if the network changes.

## Compiling, Deploying and Verifying

```
truffle compile
```
to compile.
```
truffle deploy --network <YOUR-NETWORK>
```
to deploy. Add ```--reset --compile-none``` if any timeout errors show up while deploying.
```
truffle run verify Shrinkify --network <YOUR-NETWORK>
```
to verify. 

Networks are defined in `truffle-config.js`, network included in this project by default is polygon_mumbai.

