Contracts
1.[RestrictiveOrderListing](contracts/RestrictiveOrderListing.sol)
2.[TokenPairListing](contracts/TokenPairListing.sol)
3.[OrderListing](contracts/OrderListing.sol)
4.[RestrictiveOrderListing](contracts/RestrictiveOrderListing.sol)
5.[OrderIdGenerator](contracts/OrderIdGenerator.sol)
6.[TokenPairConverter](contracts/TokenPairConverter.sol) 
7.[CommissionManager](contracts/CommissionManager.sol)
8.[ConfigurableTick](contracts/ConfigurableTick.sol)
9.[Blockable](../PED/testpair/contracts/Blockability/Blockable.sol)


1[RestrictiveOrderListing]
    isValidAmount
    isValidLifespan
    isValidPrice
    setMinOrderAmount
    setMaxOrderLifespan
    initialize




    -Checks if the _multiplyFactor is in a given range; reverts if not
        @notice Checks if the amount is valid given a maximum in commonBaseToken currency; reverts if not
        @param _tokenAddress Address of the token the amount is in
        @param _amount Amount to be checked
        @param _baseToken Address of the base token in the pair being exchanged
        modifier isValidAmount(
            address _tokenAddress,
            uint256 _amount,
            address _baseToken
        )
    
    - Checks if the amount is valid given a minimum; reverts if not
        @param _lifespan Lifespan to be checked
        modifier isValidLifespan(uint64 _lifespan)

    - Checks if the _pri a minimum; reverts if not
        @param _price Price to be checked
        modifier isValidPrice(uint256 _price) 

    - Sets the minimum order amount in commonBaseToken currency; only callable through governance
        @param _minOrderAmount New minimum
        function setMinOrderAmount(uint256 _minOrderAmount) 

    - Sets the maximum lifespan for an order; only callable through governance
        @param _maxOrderLifespan New maximum
        function setMaxOrderLifespan(uint64 _maxOrderLifespan) 

    - @dev This function must initialize every variable in storage, this is necessary because of the proxy
    pattern we are using. The initializer modifier disables this function once its called so it prevents
    that someone else calls it without the deployer noticing. Of course they may block your deploys but that
    would be an extremely unlucky scenario. onlyAuthorizedChanger cannot be used here since the governor is not set yet
        @param _commonBaseTokenAddress address of the common base token, necessary to convert amounts to a known scale

        @param _commissionManager Address of the contract that manages all the fee related things

        @param _expectedOrdersForTick amount of orders expected to match in each tick

        @param _maxBlocksForTick the max amount of blocks to wait until allowing to run the tick

        @param _minBlocksForTick the min amount of blocks to wait until allowing to run the tick

        @param _minOrderAmount the minimal amount in common base that every order should cover

        @param _maxOrderLifespan the maximal lifespan in ticks for an order

        @param _governor Address in charge of determining who is authorized and who is not

        @param _stopper Address that is authorized to pause the contract

        function initialize(
            address _commonBaseTokenAddress,
            CommissionManager _commissionManager,
            uint64 _expectedOrdersForTick,
            uint64 _maxBlocksForTick,
            uint64 _minBlocksForTick,
            uint256 _minOrderAmount,
            uint256 _minMultiplyFactor,
            uint256 _maxMultiplyFactor,
            uint64 _maxOrderLifespan,
            address _governor,
            address _stopper
        )

    - @notice Inserts an order in the buy orderbook of a given pair with a hint;
    the contract should not be paused. Takes the funds with a transferFrom
        @param _baseToken the base token of the pair
        @param _secondaryToken the secondary token of the pair
        @param _amount Amount to be locked[base]; should have enough allowance
        @param _price Maximum price to be paid [base/secondary]
        @param _lifespan After _lifespan ticks the order will be expired and no longer matched, must be lower or equal than the maximum
        @param _previousOrderIdHint Order that comes immediately before the new order;
        NO_HINT is considered as no hint and the smart contract must iterate from the beginning
        0 is considered to be a hint to put it at the start

        function insertBuyLimitOrderAfter(
            address _baseToken,
            address _secondaryToken,
            uint256 _amount,
            uint256 _price,
            uint64 _lifespan,
            uint256 _previousOrderIdHint
        )


    - @notice Inserts a market order at start in the buy orderbook of a given pair with a hint;
    the pair should not be disabled; the contract should not be paused. Takes the funds
    with a transferFrom
        @param _baseToken the base token of the pair
        @param _secondaryToken the secondary token of the pair
        @param _amount The quantity of tokens sent
        @param _multiplyFactor Maximum price to be paid [base/secondary]
        @param _lifespan After _lifespan ticks the order will be expired and no longer matched, must be lower or equal than the maximum
        @param _isBuy true if it is a buy market order
        0 is considered as no hint and the smart contract must iterate
        function insertMarketOrder(
            address _baseToken,
            address _secondaryToken,
            uint256 _amount,
            uint256 _multiplyFactor,
            uint64 _lifespan,
            bool _isBuy
        )

    -  Inserts an order in the sell orderbook of a given pair with a hint;
    the contract should not be paused. Takes the funds with a transferFrom
        @param _baseToken the base token of the pair
        @param _secondaryToken the secondary token of the pair
        @param _amount Amount to be locked[secondary]; should have enough allowance
        @param _price Maximum price to be paid [base/secondary]
        @param _lifespan After _lifespan ticks the order will be expired and no longer matched, must be lower or equal than the maximum
        @param _previousOrderIdHint Order that comes immediately before the new order;
        NO_HINT is considered as no hint and the smart contract must iterate from the beginning
        0 is considered to be a hint to put it at the start

        function insertSellLimitOrderAfter(
            address _baseToken,
            address _secondaryToken,
            uint256 _amount,
            uint256 _price,
            uint64 _lifespan,
            uint256 _previousOrderIdHint
        )

    - @notice Checks if the amount is valid given a maximum in commonBaseToken currency; reverts if not
        @param _tokenAddress Address of the token the amount is in
        @param _amount Amount to be checked
        @param _baseToken Address of the base token in the pair being exchanged

        function validateAmount(
            address _tokenAddress,
            uint256 _amount,
            address _baseToken
        ) 

    - @notice Checks if the _multiplyFactor is in a given range; reverts if not
    @param _multiplyFactor MultiplyFactor to be checked
    function validateMultiplyFactor(uint256 _multiplyFactor)

    // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;



2.[TokenPairListing]
    tokenPairAddresses stores the addresses of every listed pair
    tokenPairs stores the Pair structures, indexed by
    the hash of both addresses:
    pairHash = sha256(abi.encodePacked(baseAddress, secondarAddress))
    this is necessary to be able to know how many pairs there are and which token pairs are listed.



 


    @notice Check if the new pair is valid; i.e. it or its inverse is not listed already, and
    that the tokens are different; fails otherwise

    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair

    modifier isNewPairValid(address _baseToken, address _secondaryToken)  
 


    @notice Disable the insertion of orders in a pair; the pair must have been added before and must not be disabled currently
    Emits an event
    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair
 
    function disableTokenPair(address _baseToken, address _secondaryToken) 

 
    @notice Re-enable the insertion of orders in a pair; the pair must have been added
    and disabled first
    Emits an event
    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair

    function enableTokenPair(address _baseToken, address _secondaryToken) public onlyAuthorizedChanger {
        MoCExchangeLib.Pair storage pair = getTokenPair(_baseToken, _secondaryToken);
        require(pair.disabled, "Pair already enabled");
        pair.disabled = false;
        emit TokenPairEnabled(_baseToken, _secondaryToken);
    }

 
    @dev Sets the smoothing factor for a specific token pair
    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair
    @param _smoothingFactor wad from 0 to 1 that represents the smoothing factor for EMA calculation
 
    function setTokenPairSmoothingFactor(
        address _baseToken,
        address _secondaryToken,
        uint256 _smoothingFactor
    )  

 
    @dev Sets the EMA Price for a specific token pair
    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair
    @param _emaPrice The new EMA price for the token pair
 
    function setTokenPairEmaPrice(
        address _baseToken,
        address _secondaryToken,
        uint256 _emaPrice
    ) 
 


    @dev Sets a price provider for a specific token pair
    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair
    @param _priceProvider Address of the price provider
 
    function setPriceProvider(
        address _baseToken,
        address _secondaryToken,
        address _priceProvider
    ) 

    @notice Adds a token pair to be listed; the base token must be the commonBaseToken or be listed against it; the pair
    or its inverse must not be listed already

    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair
    @param _priceComparisonPrecision Precision to be used in the pair price
    @param _initialPrice Price used initially until a new tick with matching orders is run
    
    function addTokenPair(
        address _baseToken,
        address _secondaryToken,
        address _priceProvider,
        uint256 _priceComparisonPrecision,
        uint256 _initialPrice
    )  


    @notice Returns the tick context of a given pair
    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair
    @return tickNumber Current tick number
    @return nextTickBlock The first block on which the next tick will be runnable
    @return lastTickBlock The first block on which the last tick was run

    function getNextTick(address _baseToken, address _secondaryToken)
        public
        view
        returns (
        uint64 tickNumber,
        uint256 nextTickBlock,
        uint256 lastTickBlock
        )



    @notice Returns the amount of pairs that have been added
    function tokenPairCount() 



    @notice Returns all the pairs that have been added
        function getTokenPairs() 


    @notice Hashes a pair of tokens
    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair
    @return Returns an id that can be used to identify the pair

        function hashAddresses(address _baseToken, address _secondaryToken) 


    @notice Sets last closing price of a pair
    @dev Intended to keep a price updated if the pair is no longer enabled or not sufficiently active
    and it affects negatively other pairs that depend on this
    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair
    @param _price New price to set[base/secondary]
    
        function setLastClosingPrice(
            address _baseToken,
            address _secondaryToken,
            uint256 _price
        ) 


    @notice Returns the status of a pair
    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair
    @return tickNumber Number of the current tick
    @return nextTickBlock Block in which the next tick will be able to run
    @return lastTickBlock Block in which the last tick started to run
    @return lastClosingPrice Emergent price of the last tick
    @return disabled True if the pair is disabled(it can not be inserted any orders); false otherwise
        function getStatus(address _baseToken, address _secondaryToken)
         


    @notice returns the struct for the given pair, reverts if the pair does not exist
    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair
        function getTokenPair(address _baseToken, address _secondaryToken) 



    @notice returns the TokenPair struct for the given id, reverts if the pair does not exist
    @param _id Id of the pair
        function getTokenPair(bytes32 _id)  


    @notice returns the TokenPair struct for the given pair, the returned struct is empty if the pair does not exist
    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair
        function tokenPair(address _baseToken, address _secondaryToken)  


    @notice Returns true if the given pair has been added previously. It does not affect if the pair has been disabled
    Returns true if not
      function validPair(address _baseToken, address _secondaryToken) 

    // Leave a gap betweeen inherited contracts variables in order to be
    // able to add more variables in them later
    uint256[50] private upgradeGap;
    