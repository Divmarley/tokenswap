/** @format */

const { BigNumber } = require('ethers');
const { ethers } = require('hardhat');
const { chunk } = require('lodash');

async function main() {
  const [deployer] = await ethers.getSigners();

 console.log("Deploying contracts with the account:", deployer.address);

  // // Deploy the MoCExchangeLib library
  // const MoCExchangeLib = await ethers.getContracctFactory("MoCExchangeLib");
  // const mocExchangeLib = await MoCExchangeLib.deploy();

  // // Deploy the MoCDecentralizedExchange contract and link the library
  // const MoCDecentralizedExchange = await ethers.getContractFactory("MoCDecentralizedExchange", {
  //   libraries: {
  //     MoCExchangeLib: mocExchangeLib.address
  //   }
  // });
  // const mocDecentralizedExchange = await MoCDecentralizedExchange.deploy();

  // console.log("Contracts deployed successfully!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
