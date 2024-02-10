/** @format */
const { upgradeProxy } = require('@openzeppelin/upgrades');
async function main() {

  // const upgradedInstance = await upgradeProxy(proxyAddress, NewImplementation, { deployer });
  // We get the contract to deploy
  // const Note = await ethers.getContractFactory('Note');
  // const [deployer] = await ethers.getSigners();
  // console.log('Deploying Note...');
  // const note = await Note.deploy(14);
  // await box.deployed();
  // console.log('Box deployed to:', note.target);
//   const upgradedInstance = await upgradeProxy(proxyAddress, NewImplementation, { deployer });
// console.log(upgradedInstance);  
  // const Token = await ethers.getContractFactory('Token');
  // const token = await Token.deploy();

  // console.log('MyToken address:', token.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
