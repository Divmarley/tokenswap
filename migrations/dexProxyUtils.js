// dexProxyUtils.js

// Import necessary dependencies
const { deployProxy } = require('@openzeppelin/upgrades');

// Define createDexProxy function
// const { deployProxy } = require('hardhat-deploy/proposals');

const createDexProxy = async (contract, options, initMethod, ...params) => {
    try {
        // Deploy the proxy for the contract
        const dexProxy = await deployProxy(contract, [...params], {
            ...options,
            initializer: 'initialize',
        });
        // Return the proxy address 
        return dexProxy.address;
    } catch (error) {
        // Handle any errors that occur during proxy deployment
        console.error('Error deploying proxy:', error);
        throw error; // Rethrow the error for the caller to handle
    }
};




// Export the createDexProxy function
module.exports = { createDexProxy };


 