/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-ethers");
const HDWalletProvider = require('truffle-hdwallet-provider');
const endpointUrl = "https://holy-clean-resonance.ethereum-sepolia.quiknode.pro/b5ccb3c734b159fe7f58d41b914b0dbc1a5402d9/";
const privateKey = "96ea8f6ce6602ca3d0570d46ee522412782502000084143ea955ae245bd3802c";
module.exports = { 
  solidity: {
    version: "0.8.24",   
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    sepolia: {
      url: endpointUrl,
      accounts: [privateKey],
    },
    // development: {
    //   host: '127.0.0.1',
    //   port: 8545,
    //   network_id: '*',
    //   gas: 0xfffffffffff
    // },
    // test: {
    //   host: '127.0.0.1',
    //   port: 7545,
    //   network_id: '*'
    // },
    // coverage: {
    //   host: '127.0.0.1',
    //   port: 8555,
    //   network_id: '*',
    //   gas: 0xfffffffffff
    // },
    // rskTestnet: {
    //   host: 'https://public-node.testnet.rsk.co/',
    //   provider: new HDWalletProvider(mnemonic, 'https://public-node.testnet.rsk.co/'),
    //   network_id: '*',
    //   gas: 6800000,
    //   gasPrice: 69000000,
    //   skipDryRun: true,
    //   confirmations: 1
    // },
    // rskMainnet: {
    //   host: 'https://public-node.rsk.co/',
    //   provider: new HDWalletProvider(mnemonic, 'https://public-node.rsk.co/'),
    //   network_id: '*',
    //   gas: 6800000,
    //   gasPrice: 60000000,
    //   skipDryRun: true,
    //   confirmations: 1
    // }
  },
  mocha: {
    useColors: true,
    bail: true
  },
  plugins: ['truffle-contract-size']
  // networks: {
  //   sepolia: {
  //     url: endpointUrl,
  //     accounts: [privateKey],
  //   },
  //   localhost: {
  //     url: "http://localhost:8545", // Use the correct RPC URL
  //   },
  // },
};
