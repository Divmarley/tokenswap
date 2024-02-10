/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-ethers");
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
    localhost: {
      url: "http://localhost:8545", // Use the correct RPC URL
    },
  },
};