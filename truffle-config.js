const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const mnemonic = fs.readFileSync("mnemonic.secret").toString().trim();
const apikey = fs.readFileSync("apikey.secret").toString();
const providerlink = fs.readFileSync("providerlink.secret").toString();


module.exports = {
  networks: {
    polygon_mumbai: {
        provider: () => new HDWalletProvider(mnemonic, providerlink),
        network_id: 80001,
        confirmations: 2,
        timeoutBlocks: 200,
        skipDryRun: true,
        chainId: 80001,
        gas: 20000000,
        gasPrice: 30000000000,
        timeoutBlocks: 250,
        networkCheckTimeout: 3000000
    }
  },

  compilers: {
    solc: {
      version: "pragma",
      settings: {
        optimizer: {
          enabled: false,
          runs: 200
        },
    evmVersion: "byzantium"
  }
    }
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    polygonscan: apikey
  }
}