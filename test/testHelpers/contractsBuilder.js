const { TestHelper } = require('@openzeppelin/upgrades');
const jsonfile = require('jsonfile');
const { addTokenPair } = require('./protectedFunctions');
const {
  DEFAULT_MAX_BLOCKS_FOR_TICK,
  DEFAULT_MAX_ORDER_LIFESPAN,
  DEFAULT_MIN_BLOCKS_FOR_TICK,
  DEFAULT_MIN_ORDER_AMOUNT,
  DEFAULT_ORDER_FOR_TICKS,
  DEFAULT_PRICE_PRECISION,
  DEFAULT_COMMISSION_RATE,
  DEFAULT_CANCELATION_PENALTY_RATE,
  DEFAULT_EXPIRATION_PENALTY_RATE,
  DEFAULT_MIN_MO_MULTIPLY_FACTOR,
  DEFAULT_MAX_MO_MULTIPLY_FACTOR,
  RATE_PRECISION,
  DEFAULT_MINIMUM_COMMISSION
} = require('./constants');

const MoCDecentralizedExchangeProxy = artifacts.require('MoCDecentralizedExchange');
const CommissionManagerProxy = artifacts.require('CommissionManager');
const MoCDexFakeProxy = artifacts.require('MoCDexFake');

// Supposing we are using EXACTLY that network id (1564754684494)
const getProxies = () => {
  const { proxies } = jsonfile.readFileSync('./zos.dev-1564754684494.json');
  return proxies;
};

const getProxyAddress = contractName => {
  const proxies = getProxies();
  const projectPrefix = 'decentralized-exchange';
  const proxiesOfInterest = proxies[`${projectPrefix}/${contractName}`];
  return proxiesOfInterest[proxiesOfInterest.length - 1].address;
};

const createContracts = async ({
  owner,
  useBlacklist,
  useFakeDex,
  minOrderAmount,
  ordersForTick,
  maxBlocksForTick,
  minBlocksForTick,
  maxOrderLifespan,
  customBeneficiaryAddress,
  commission,
  minMultiplyFactor,
  maxMultiplyFactor,
  tokenPair
}) => {
  const project = await TestHelper();
  const moCDexProxy = await (useFakeDex
    ? project.createProxy(MoCDexFakeProxy)
    : project.createProxy(MoCDecentralizedExchangeProxy));
  
  this.using.useFakeDex = useFakeDex;
  this.using.dex = useFakeDex
    ? await MoCDexFake.at(moCDexProxy.address)
    : await MoCDecentralizedExchange.at(moCDexProxy.address);
  
  // Rest of the code remains unchanged...
};

module.exports = () => {
  this.using = {};
  return {
    // createTickStateFake,
    createContracts,
    // getBaseToken,
    // getSecondaryToken,
    // getMoCDex,
    // getCommissionManager,
    // getTickStateFake,
    // getBase,
    // getSecondary,
    // getWRBTC,
    // getDex,
    // getTickState,
    // getGovernor,
    // getStopper,
    // getOwnerBurnableToken,
    // getTestToken,
    // getTokenPriceProviderFake,
    // getMocStateFake,
    // getPriceProviderLastClosingPrice,
    // getExternalOraclePriceProviderFallback,
    // getMocBproUsdPriceProviderFallback,
    // getMocBproBtcPriceProviderFallback
  };
};
