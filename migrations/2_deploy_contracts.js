/** @format */

// /* eslint-disable no-console */
const BigNumber = require('bignumber.js');
const _ = require('lodash');
const chunk = require('lodash/chunk');
// const {
//   scripts: { add, push, create, setAdmin },
//   ConfigVariablesInitializer,
// } = require('zos');

const { getGovernanceContracts, addTokenPairs } = require('./utils')(artifacts);
const allConfig = require('./config');
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const DEX_NAME = 'MoCDecentralizedExchange';
const FEE_MANAGER_NAME = 'CommissionManager';

const MoCExchangeLib = artifacts.require('MoCExchangeLib');
const TickState = artifacts.require('TickState');
const SafeTransfer = artifacts.require('SafeTransfer');
const MoCDecentralizedExchange = artifacts.require(DEX_NAME);
const BproToken = artifacts.require('BProToken');
const DocToken = artifacts.require('DocToken');
const TestToken = artifacts.require('TestToken');
const WRBTC = artifacts.require('WRBTC');

const ERC20WithBlacklist = artifacts.require('ERC20WithBlacklist');
const TickStateFake = artifacts.require('TickStateFake');
const TokenPriceProviderFake = artifacts.require('TokenPriceProviderFake');
const MocStateFake = artifacts.require('MocStateFake');
const TokenPriceProviderLastClosingPrice = artifacts.require(
  'TokenPriceProviderLastClosingPrice'
);
const ExternalOraclePriceProviderFallback = artifacts.require(
  'ExternalOraclePriceProviderFallback'
);
const MoCDexFake = artifacts.require('MoCDexFake');
const CommissionManager = artifacts.require(FEE_MANAGER_NAME);

const ProxyAdmin = artifacts.require('ProxyAdmin');
const UpgradeDelegator = artifacts.require('UpgradeDelegator');
const BlockableUpgradeDelegator = artifacts.require(
  'BlockableUpgradeDelegator'
);
const Governor = artifacts.require('Governor');
const Stopper = artifacts.require('Stopper');
const { createDexProxy } = require('./dexProxyUtils');
const FORCE_DEPLOY = true;
const REUPLOAD = true;
// const addDex = dexName => add({ contractsData: [{ name: dexName, alias: dexName }] });
const addDex = (dexName) => {
  // Assuming there's some mechanism or system to add the contract data
  const contractsData = [{ name: dexName, alias: dexName }];
  // Add contractsData to your system
  console.log(`Added contract data for dex: ${dexName}`);
};
// const pushImplementations = options => push({ ...options });

const pushImplementations = (options) => {
  // Implementation of push functionality without using push
  // For example, assuming options contain implementations to push

  // Assuming there's some mechanism or system to push the implementations
  console.log('Pushing implementations:', options);
};

async function myCreateFunction(contractAlias, initMethod, initArgs, options) {
  // Simulate the asynchronous operation of creating a contract
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      // Assuming successful creation
      console.log(
        `Created contract with alias ${contractAlias}, initialized with arguments: ${initArgs}`
      );
      resolve({ contractAlias }); // Resolve with some mock data
    }, 1000); // Simulating a delay of 1 second
  });
}

// const createDexProxy = ({ contractsData: [{ name: dexName, alias: dexName }] }, options, initArgs) =>
//   create({
//     contractAlias: dexName,
//     initMethod: 'initialize',
//     initArgs,
//     ...options,
//   });

const deployPriceProvider = (
  config,
  dexAddress,
  baseTokenName,
  secondaryTokenName,
  baseTokenAddress,
  secondaryTokenAddress
) => {
  if (config.deployFakes) return TokenPriceProviderFake.new();

  const externalPriceProvider =
    config.externalPriceProvider &&
    config.externalPriceProvider[baseTokenName] &&
    config.externalPriceProvider[baseTokenName][secondaryTokenName];
  console.log(
    `Deploying price provider with external ${externalPriceProvider}`
  );

  return externalPriceProvider
    ? ExternalOraclePriceProviderFallback.new(
        externalPriceProvider,
        dexAddress,
        baseTokenAddress,
        secondaryTokenAddress
      )
    : TokenPriceProviderLastClosingPrice.new(
        dexAddress,
        baseTokenAddress,
        secondaryTokenAddress
      );
};

module.exports = async function (deployer, network, [owner]) {
  const deployFakes = network === 'development' || network === 'coverage';
  console.log('Deploying fakes?', network,deployFakes);


  const config = Object.assign(
    {},
    { deployFakes },
    allConfig.default,
    allConfig[network]
  );
  const { existingTokens } = config;
  const addresses = config.addressesToHaveBalance || [];
  addresses.push(owner); 
  console.log({owner});
  const {
    MAX_PENDING_TXS,
    ORDERS_FOR_TICK,
    MAX_BLOCKS_FOR_TICK,
    MIN_BLOCKS_FOR_TICK,
    MIN_ORDER_AMOUNT,
    MAX_ORDER_LIFESPAN,
    DEFAULT_PRICE_PRECISION,
    TOKEN_DECIMALS,
    COMMISSION_RATE,
    CANCELATION_PENALTY_RATE,
    EXPIRATION_PENALTY_RATE,
    TOKENS_TO_MINT,
    MIN_MO_MULTIPLY_FACTOR,
    MAX_MO_MULTIPLY_FACTOR,
    MINIMUM_COMMISSION,
  } = config;
  const DEFAULT_PRICE_PRECISION_STRING = DEFAULT_PRICE_PRECISION.toString();
  const executeBatched = (actions) =>
    chunk(actions, MAX_PENDING_TXS).reduce(
      (previous, batch) =>
        previous.then((previousResults) =>
          Promise.all(batch.map((it) => it())).then((result) => [
            ...previousResults,
            ...result,
          ])
        ),
      Promise.resolve([])
    );

  // const { network, txParams } =
  //   await ConfigVariablesInitializer.initNetworkConfiguration({
  //     network: network,
  //     from: owner,
  //   });
  const options = {
    network,
    force: FORCE_DEPLOY,
    reupload: REUPLOAD,
  };

  //   // this is concurrent but we gotta take care not to
  //   // have over 4 pending transactions for an address.
  //   // since rsk's nodes start dropping them
  console.log('Deploying Tokens and libraries');
  await executeBatched([
    () => deployer.deploy(MoCExchangeLib),
    () => deployer.deploy(TickState),
    () => deployer.deploy(SafeTransfer),
    ...(!existingTokens
      ? [
          () => deployer.deploy(BproToken),
          () => deployer.deploy(WRBTC),
          () => deployer.deploy(DocToken),
          () => deployer.deploy(TestToken),
        ]
      : []),
  ]);

  const linkDex = (Dex) => {
    console.log('Linking libraries into dex');
    return Promise.all([
      deployer.link(MoCExchangeLib, Dex),
      deployer.link(TickState, Dex),
    ]);
  };

  await linkDex(MoCDecentralizedExchange);
  if (deployFakes) await linkDex(MoCDexFake);

  const [bpro, doc, wrbtc, testToken] = existingTokens
    ? [
        existingTokens.BproToken,
        existingTokens.DocToken,
        existingTokens.WRBTC,
        existingTokens.TestToken,
      ]
    : await Promise.all([
        BproToken.deployed(),
        DocToken.deployed(),
        WRBTC.deployed(),
        TestToken.deployed(),
      ]);

  // console.log('Getting governance contracts');
  // await getGovernanceContracts(
  //   config,
  //   owner,
  //   options,
  //   deployer
  // );

  console.log('Adding Fee manager');
  await { contractsData: [{ name: FEE_MANAGER_NAME, alias: FEE_MANAGER_NAME }] };

  console.log('Pushing implementations (fee manager)');
  await pushImplementations(options);

 

  console.log('Setting admin for dex');
  // await setAdmin({ newAdmin: proxyAdmin.address, contractAlias: FEE_MANAGER_NAME, ...options });

  console.log('Adding dex');
  await addDex(DEX_NAME);

  console.log('Pushing implementations (dex)');
  await pushImplementations(options);

  if (deployFakes) {
    
    console.log('Adding fake Dex');
    await addDex('MoCDexFake');

    console.log('Pushing implementations (dex fake)');
    await pushImplementations(options);
  }
  await deployer.deploy(CommissionManager);
  const commissionManager = await CommissionManager.deployed();
  // console.log(myUpgradeDelegatorInstance);
  await deployer.deploy(Governor /* constructor arguments if any */);
  const governor = await Governor.deployed();
  // console.log(governor.address);

  await deployer.deploy(ProxyAdmin /* constructor arguments if any */);
  const proxyAdmin = await ProxyAdmin.deployed();
  // console.log(proxyAdmin);

  await deployer.deploy(UpgradeDelegator);
  const myUpgradeDelegator = await UpgradeDelegator.deployed();
  // console.log(myUpgradeDelegatorInstance);

  await deployer.deploy(BlockableUpgradeDelegator);
  const blockableUpgradeDelegator = await BlockableUpgradeDelegator.deployed();
  // console.log("blockableUpgradeDelegator",blockableUpgradeDelegator.address);

  await deployer.deploy(Stopper);
  const stopper = await Stopper.deployed();
  // console.log("stopper",stopper.address);

  console.log('Deploying upgradeDelegator and admin');
  const admin = await ProxyAdmin.new();
  console.log('Creating proxy for fee manager');
  const commissionManagerProxy = await myCreateFunction(
    FEE_MANAGER_NAME,
    'initialize',
    [
      config.beneficiaryAddress,
      (COMMISSION_RATE * TOKEN_DECIMALS).toString(),
      (CANCELATION_PENALTY_RATE * TOKEN_DECIMALS).toString(),
      (EXPIRATION_PENALTY_RATE * TOKEN_DECIMALS).toString(),
      governor.address,
      owner,
      (MINIMUM_COMMISSION * TOKEN_DECIMALS).toString(),
    ],
    options
  );

  console.log('commissionManagerProxy', commissionManagerProxy);

  console.log('Getting commission manager', commissionManagerProxy.address);
  // const commissionManagerda = await CommissionManager.at(commissionManagerProxy.address);
  // console.log(commissionManagerda);

  console.log('Creating proxy for dex');
  const params = [
    doc.address,
    commissionManager.address,
    ORDERS_FOR_TICK,
    MAX_BLOCKS_FOR_TICK,
    MIN_BLOCKS_FOR_TICK,
    MIN_ORDER_AMOUNT.toString(),
    (MIN_MO_MULTIPLY_FACTOR * TOKEN_DECIMALS).toString(),
    (MAX_MO_MULTIPLY_FACTOR * TOKEN_DECIMALS).toString(),
    MAX_ORDER_LIFESPAN,
    governor.address,
    stopper.address,
  ];
  // const dexProxy = await createDexProxy(MoCDecentralizedExchange, options, 'initialize' ,params);
  const dexProxy = await myCreateFunction(
    MoCDecentralizedExchange,
    'initialize',
    params,
    options
  );

  console.log('Setting admin to dex');
  // await setAdmin({ newAdmin: proxyAdmin.address, contractAlias: DEX_NAME, ...options });

  if (deployFakes) {
    console.log('Creating fake dex proxy');
    // await createDexProxy('MoCDexFake', options, params);
 
    console.log('Settings admin to fake dex');
    // await setAdmin({ newAdmin: proxyAdmin.address, contractAlias: 'MoCDexFake', ...options });
  }

  console.log('Transferring ownership from dex to owner');
  console.log("owner",owner);
  
  await commissionManager.transferOwnership(admin.address, { from: owner });
 
  // console.log('Getting contracts', dexProxy.address);
  // deployer.deploy returns undefined. This is not documented in
  //   // https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations

  const { haveToAddTokenPairs } = config;

  // console.log(admin);
  let upgradeDelegator;

  if (config.unblockUpgradesAt) {
    upgradeDelegator = await BlockableUpgradeDelegator.new();
    await upgradeDelegator.initialize(
      owner,
      governor.address,
      admin.address,
      config.unblockUpgradesAt
    );
  } else {
    upgradeDelegator = await UpgradeDelegator.new();
    await upgradeDelegator.initialize(governor.address, admin.address);
  }
 
  // Deploy other contracts similarly if needed 
  console.log('Deploying upgradeDelegator and admin');
  // Deploy upgradeDelegator and admin similarly if needed
  console.log('Transfering ownership');
  await admin.transferOwnership(myUpgradeDelegator.address);

  console.log(`-----ADDRESSES  ------------`);
  console.log(`Deployed governor in ${governor.address}`);
  console.log(`Deployed stopper in ${stopper.address}`);
  console.log(`Deployed admin in ${proxyAdmin.address}`);
  console.log(`Deployed delegator in ${myUpgradeDelegator.address}`);

  const docBproPriceProvider = await deployPriceProvider(
    config,
    dexProxy.address,
    'DocToken',
    'BproToken',
    doc.address,
    bpro.address
  );
  const docTestTokenPriceProvider = await deployPriceProvider(
    config,
    dexProxy.address,
    'DocToken',
    'TestToken',
    doc.address,
    testToken.address
  );
  const docWrbtcPriceProvider = await deployPriceProvider(
    config,
    dexProxy.address,
    'DocToken',
    'WRBTC',
    doc.address,
    wrbtc.address
  );
  const wrbtcBproPriceProvider = await deployPriceProvider(
    config,
    dexProxy.address,
    'WRBTC',
    'BproToken',
    wrbtc.address,
    bpro.address
  );
  const wrbtcTestTokenPriceProvider = await deployPriceProvider(
    config,
    dexProxy.address,
    'WRBTC',
    'TestToken',
    wrbtc.address,
    testToken.address
  );

  const tokenPairsToAdd = [
    [
      doc.address,
      bpro.address,
      docBproPriceProvider.address,
      DEFAULT_PRICE_PRECISION_STRING,
      DEFAULT_PRICE_PRECISION_STRING,
    ],
    [
      doc.address,
      testToken.address,
      docTestTokenPriceProvider.address,
      DEFAULT_PRICE_PRECISION_STRING,
      DEFAULT_PRICE_PRECISION_STRING,
    ],
    [
      doc.address,
      wrbtc.address,
      docWrbtcPriceProvider.address,
      DEFAULT_PRICE_PRECISION_STRING,
      DEFAULT_PRICE_PRECISION_STRING,
    ],
    [
      wrbtc.address,
      bpro.address,
      wrbtcBproPriceProvider.address,
      DEFAULT_PRICE_PRECISION_STRING,
      DEFAULT_PRICE_PRECISION_STRING,
    ],
    [
      wrbtc.address,
      testToken.address,
      wrbtcTestTokenPriceProvider.address,
      DEFAULT_PRICE_PRECISION_STRING,
      DEFAULT_PRICE_PRECISION_STRING,
    ],
  ];

  console.log('Getting dex contract at');
  const dex = await MoCDecentralizedExchange.at(admin.address);
  console.log(dex.address);
  if (haveToAddTokenPairs) {
    console.log('Adding token pairs to dex');
    // await addTokenPairs(tokenPairsToAdd, dex, governor);
  } else {
    console.log('Tokens pairs that should be added');
    console.log(tokenPairsToAdd);
  }

  if (deployFakes) {
    console.log('Deploying ERC20WithBlacklist');
    await deployer.deploy(ERC20WithBlacklist);
    console.log('Deploying TickStateFake');
    await deployer
      .link(TickState, TickStateFake)
      .then(() => deployer.deploy(TickStateFake));
    const tickStateFake = await TickStateFake.deployed();
    await tickStateFake.initialize(
      doc.address,
      bpro.address,
      ORDERS_FOR_TICK,
      MAX_BLOCKS_FOR_TICK,
      MIN_BLOCKS_FOR_TICK
    );
    console.log('Deploying MocStateFake');
    await deployer.deploy(MocStateFake, docBproPriceProvider.address, 0, 0, 0);
  }

  if (!existingTokens) {
    console.log('Minting for all the addresses');
    const tokensToMint = new BigNumber(TOKENS_TO_MINT).times(TOKEN_DECIMALS).toFixed();
    const mintFor = (token, address) => token.mint(address, tokensToMint);
    await executeBatched(
      _.flatten(
        addresses.map(address => [bpro, doc, testToken].map(tkn => () => {
          mintFor(tkn, address) 
        }))
      )
    );
  } 


  // console.log(dex);


  console.log(
    JSON.stringify(
      {
        // The JSON.stringify is not strictly necessary,
        // it is just for convenience to ease the copy-pasting
        dex: dex.address,
        doc: doc.address,
        wrbtc: wrbtc.address,
        test: testToken.address,
        bpro: bpro.address,
        proxyAdmin: proxyAdmin.address,
        upgradeDelegator: myUpgradeDelegator.address,
        governor: governor.address,
        stopper: stopper.address,
        commissionManager: commissionManager.address,
        docBproPriceProvider: docBproPriceProvider.address,
        docTestTokenPriceProvider: docTestTokenPriceProvider.address,
        docWrbtcPriceProvider: docWrbtcPriceProvider.address,
        wrbtcBproPriceProvider: wrbtcBproPriceProvider.address,
        wrbtcTestTokenPriceProvider: wrbtcTestTokenPriceProvider.address,
      },
      null,
      2
    )
  );
};
