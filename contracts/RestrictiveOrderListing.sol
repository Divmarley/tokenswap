// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";



import "./OrderListing.sol";

contract RestrictiveOrderListing is OrderListing {
  uint256 public minOrderAmount;
  uint256 public minMultiplyFactor;
  uint256 public maxMultiplyFactor;
  uint64 public maxOrderLifespan;

  /**
    @notice Checks if the amount is valid given a maximum in commonBaseToken currency; reverts if not
    @param _tokenAddress Address of the token the amount is in
    @param _amount Amount to be checked
    @param _baseToken Address of the base token in the pair being exchanged
   */
  modifier isValidAmount(
    address _tokenAddress,
    uint256 _amount,
    address _baseToken
  ) {
    validateAmount(_tokenAddress, _amount, _baseToken);
    _;
  }

  /**
    @notice Checks if the amount is valid given a minimum; reverts if not
    @param _lifespan Lifespan to be checked
   */
  modifier isValidLifespan(uint64 _lifespan) {
    require(_lifespan <= maxOrderLifespan, "Lifespan too high");
    _;
  }

  /**
    @notice Checks if the _pri a minimum; reverts if not
    @param _price Price to be checked
   */
  modifier isValidPrice(uint256 _price) {
    require(_price != 0, "Price cannot be zero");
    _;
  }

  /**
    @notice Checks if the _multiplyFactor is in a given range; reverts if not
    @param _multiplyFactor MultiplyFactor to be checked
  */
  modifier isValidMultiplyFactor(uint256 _multiplyFactor) {
    validateMultiplyFactor(_multiplyFactor);
    _;
  }

  /**
    @notice Sets the minimum order amount in commonBaseToken currency; only callable through governance
    @param _minOrderAmount New minimum
   */
  function setMinOrderAmount(uint256 _minOrderAmount) external onlyAuthorizedChanger {
    minOrderAmount = _minOrderAmount;
  }

  /**
    @notice Sets the maximum lifespan for an order; only callable through governance
    @param _maxOrderLifespan New maximum
   */

  function setMaxOrderLifespan(uint64 _maxOrderLifespan) external onlyAuthorizedChanger {
    maxOrderLifespan = _maxOrderLifespan;
  }

  function setMinMultiplyFactor(uint256 _minMultiplyFactor) external onlyAuthorizedChanger {
    minMultiplyFactor = _minMultiplyFactor;
  }

  function setMaxMultiplyFactor(uint256 _maxMultiplyFactor) external onlyAuthorizedChanger {
    maxMultiplyFactor = _maxMultiplyFactor;
  }

  /**
    @dev This function must initialize every variable in storage, this is necessary because of the proxy
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
 */
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
  ) public initializer {
    OrderListing.initialize(
      _commonBaseTokenAddress,
      _commissionManager,
      _expectedOrdersForTick,
      _maxBlocksForTick,
      _minBlocksForTick,
      _governor,
      _stopper
    );
    minOrderAmount = _minOrderAmount;
    maxOrderLifespan = _maxOrderLifespan;
    minMultiplyFactor = _minMultiplyFactor;
    maxMultiplyFactor = _maxMultiplyFactor;
  }

  /**
    @notice Inserts an order in the buy orderbook of a given pair with a hint;
    the contract should not be paused. Takes the funds with a transferFrom
    @param _baseToken the base token of the pair
    @param _secondaryToken the secondary token of the pair
    @param _amount Amount to be locked[base]; should have enough allowance
    @param _price Maximum price to be paid [base/secondary]
    @param _lifespan After _lifespan ticks the order will be expired and no longer matched, must be lower or equal than the maximum
    @param _previousOrderIdHint Order that comes immediately before the new order;
    NO_HINT is considered as no hint and the smart contract must iterate from the beginning
    0 is considered to be a hint to put it at the start
  */
  function insertBuyLimitOrderAfter(
    address _baseToken,
    address _secondaryToken,
    uint256 _amount,
    uint256 _price,
    uint64 _lifespan,
    uint256 _previousOrderIdHint
  ) public override isValidAmount(_baseToken, _amount, _baseToken) isValidLifespan(_lifespan) isValidPrice(_price) {
    OrderListing.insertBuyLimitOrderAfter(_baseToken, _secondaryToken, _amount, _price, _lifespan, _previousOrderIdHint);
  }

  /**
    @notice Inserts a market order at start in the buy orderbook of a given pair with a hint;
    the pair should not be disabled; the contract should not be paused. Takes the funds
    with a transferFrom
    @param _baseToken the base token of the pair
    @param _secondaryToken the secondary token of the pair
    @param _amount The quantity of tokens sent
    @param _multiplyFactor Maximum price to be paid [base/secondary]
    @param _lifespan After _lifespan ticks the order will be expired and no longer matched, must be lower or equal than the maximum
    @param _isBuy true if it is a buy market order
    0 is considered as no hint and the smart contract must iterate
  */
  function insertMarketOrder(
    address _baseToken,
    address _secondaryToken,
    uint256 _amount,
    uint256 _multiplyFactor,
    uint64 _lifespan,
    bool _isBuy
  )
    public virtual override
    isValidLifespan(_lifespan)
    isValidMultiplyFactor(_multiplyFactor)
    isValidAmount(_isBuy ? _baseToken : _secondaryToken, _amount, _baseToken)
  {
    OrderListing.insertMarketOrder(_baseToken, _secondaryToken, _amount, _multiplyFactor, _lifespan, _isBuy);
  }

  /**
    @notice Inserts a market order in the buy orderbook of a given pair with a hint;
    the pair should not be disabled; the contract should not be paused. Takes the funds
    with a transferFrom
    @param _baseToken the base token of the pair
    @param _secondaryToken the secondary token of the pair
    @param _amount The quantity of tokens sent
    @param _multiplyFactor Maximum price to be paid [base/secondary]
    @param _previousOrderIdHint Order that comes immediately before the new order;
    NO_HINT is considered as no hint and the smart contract must iterate from the beginning
    0 is considered to be a hint to put it at the start
    @param _lifespan After _lifespan ticks the order will be expired and no longer matched, must be lower or equal than the maximum
    @param _isBuy true if it is a buy market order
  */
  // function insertMarketOrderAfter(
  //   address _baseToken,
  //   address _secondaryToken,
  //   uint256 _amount,
  //   uint256 _multiplyFactor,
  //   uint256 _previousOrderIdHint,
  //   uint64 _lifespan,
  //   bool _isBuy
  // )
  //   public override 
  //   isValidLifespan(_lifespan)
  //   isValidMultiplyFactor(_multiplyFactor)
  //   isValidAmount(_isBuy ? _baseToken : _secondaryToken, _amount, _baseToken)
  // {
  //   OrderListing.insertMarketOrderAfter(_baseToken, _secondaryToken, _amount, _multiplyFactor, _previousOrderIdHint, _lifespan, _isBuy);
  // }

  /**
    @notice Inserts an order in the sell orderbook of a given pair with a hint;
    the contract should not be paused. Takes the funds with a transferFrom
    @param _baseToken the base token of the pair
    @param _secondaryToken the secondary token of the pair
    @param _amount Amount to be locked[secondary]; should have enough allowance
    @param _price Maximum price to be paid [base/secondary]
    @param _lifespan After _lifespan ticks the order will be expired and no longer matched, must be lower or equal than the maximum
    @param _previousOrderIdHint Order that comes immediately before the new order;
    NO_HINT is considered as no hint and the smart contract must iterate from the beginning
    0 is considered to be a hint to put it at the start
   */
  function insertSellLimitOrderAfter(
    address _baseToken,
    address _secondaryToken,
    uint256 _amount,
    uint256 _price,
    uint64 _lifespan,
    uint256 _previousOrderIdHint
  ) public override isValidAmount(_secondaryToken, _amount, _baseToken) isValidLifespan(_lifespan) isValidPrice(_price) {
    OrderListing.insertSellLimitOrderAfter(_baseToken, _secondaryToken, _amount, _price, _lifespan, _previousOrderIdHint);
  }

  /**
    @notice Checks if the amount is valid given a maximum in commonBaseToken currency; reverts if not
    @param _tokenAddress Address of the token the amount is in
    @param _amount Amount to be checked
    @param _baseToken Address of the base token in the pair being exchanged
   */
  function validateAmount(
    address _tokenAddress,
    uint256 _amount,
    address _baseToken
  ) internal view {
    uint256 convertedAmount = convertTokenToCommonBase(_tokenAddress, _amount, _baseToken);
    require(convertedAmount >= minOrderAmount, "Amount too low");
  }

  /**
    @notice Checks if the _multiplyFactor is in a given range; reverts if not
    @param _multiplyFactor MultiplyFactor to be checked
  */
  function validateMultiplyFactor(uint256 _multiplyFactor) internal view {
    require(_multiplyFactor != 0, "MultiplyFactor is zero");
    require(_multiplyFactor >= minMultiplyFactor, "Low MultiplyFactor");
    require(_multiplyFactor <= maxMultiplyFactor, "High MultiplyFactor");
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
