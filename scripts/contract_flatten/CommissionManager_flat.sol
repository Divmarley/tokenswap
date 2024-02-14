// File: @openzeppelin/contracts/utils/Context.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)
pragma solidity ^0.8.9;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.9;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: contracts/Governance/ChangeContract.sol


pragma solidity >=0.4.22 <0.9.0;
/**
  @title ChangeContract
  @notice This interface is the one used by the governance system.
  @dev If you plan to do some changes to a system governed by this project you should write a contract
  that does those changes, like a recipe. This contract MUST not have ANY kind of public or external function
  that modifies the state of this ChangeContract, otherwise you could run into front-running issues when the governance
  system is fully in place.
 */
interface ChangeContract {

  /**
    @notice Override this function with a recipe of the changes to be done when this ChangeContract
    is executed
   */
  function execute() external;
}

// File: contracts/Governance/IGovernor.sol


pragma solidity >=0.4.22 <0.9.0;

/**
  @title Governor
  @notice Governor interface. This functions should be overwritten to
  enable the comunnication with the rest of the system
  */
interface IGovernor{

  /**
    @notice Function to be called to make the changes in changeContract
    @dev This function should be protected somehow to only execute changes that
    benefit the system. This decision process is independent of this architechture
    therefore is independent of this interface too
    @param changeContract Address of the contract that will execute the changes
   */
  function executeChange(ChangeContract changeContract) external;

  /**
    @notice Function to be called to make the changes in changeContract
    @param _changer Address of the contract that will execute the changes
   */
  function isAuthorizedChanger(address _changer) external view returns (bool);
}

// File: @openzeppelin/upgrades/contracts/Initializable.sol


pragma solidity ^0.8.17;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: contracts/Governance/Governed.sol


pragma solidity >=0.4.22 <0.9.0;


/**
  @title Governed
  @notice Base contract to be inherited by governed contracts
  @dev This contract is not usable on its own since it does not have any _productive useful_ behaviour
  The only purpose of this contract is to define some useful modifiers and functions to be used on the
  governance aspect of the child contract
  */
contract Governed is Initializable {

  /**
    @notice The address of the contract which governs this one
   */
  IGovernor public governor;

  string constant private NOT_AUTHORIZED_CHANGER = "not_authorized_changer";

  /**
    @notice Modifier that protects the function
    @dev You should use this modifier in any function that should be called through
    the governance system
   */
  modifier onlyAuthorizedChanger() {
    checkIfAuthorizedChanger();
    _;
  }

  /**
    @notice Initialize the contract with the basic settings
    @dev This initialize replaces the constructor but it is not called automatically.
    It is necessary because of the upgradeability of the contracts
    @param _governor Governor address
   */
  function initialize(address _governor) public initializer {
    governor = IGovernor(_governor);
  }

  /**
    @notice Change the contract's governor. Should be called through the old governance system
    @param newIGovernor New governor address
   */
  function changeIGovernor(IGovernor newIGovernor) public onlyAuthorizedChanger {
    governor = newIGovernor;
  }

  /**
    @notice Checks if the msg sender is an authorized changer, reverts otherwise
   */
  function checkIfAuthorizedChanger() internal view {
    require(governor.isAuthorizedChanger(msg.sender), NOT_AUTHORIZED_CHANGER);
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


pragma solidity ^0.8.17;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/CommissionManager.sol


pragma solidity >=0.4.22 <0.9.0; 





/**
  @notice This contract is in charge of keeping track of the charged commissions
  and calculating the commissions to reserve/charge depending on the operation and
  the amount of the order.DESPITE WORKING AS A TRACKER IT DOESN'T KEEP THE FUNDS
  @dev Should only be callable by dex, so this contract inherits from Ownable and should
  have dex as its owner
 */
contract CommissionManager is Governed, Ownable {
  using SafeMath for uint256;

  constructor () Ownable(msg.sender){}
  /** mapping for the commission collected by MOCDEX */
  mapping(address => uint256) public exchangeCommissions;

  address public beneficiaryAddress;
  uint256 public commissionRate;
  uint256 public cancelationPenaltyRate;
  uint256 public expirationPenaltyRate;
  uint256 public constant RATE_PRECISION = uint256(10**18);
  uint256 public minimumCommission;

  /**
    @notice Checks that _rate is a valid rate, i.e. it is between 1(RATE_PRECISION)
    and 0; fails otherwise
    @param _rate Rate to be checked
  */
  modifier isValidRate(uint256 _rate) {
    require(_rate <= RATE_PRECISION, "rate should to be in relation to 1");
    _;
  }

  /**
    @notice Checks that _address is not zero; fails otherwise
    @param _address Address to be checked
  */
  modifier isValidAddress(address _address, string memory message) {
    require(_address != address(0), message);
    _;
  }

  /**
    @notice Calculates the commission to be charged for an order matching, also adds the said
    amount as a charged commission
    IT DOESN'T KEEP THE FUNDS NOR MOVES ANY
    @param _orderAmount order's exchangeableAmount amount
    @param _matchedAmount the order amount that is being exchanged in this iteration
    @param _commission the order reserved commission
    @param _tokenAddress the token that it's being exchanged
    @return the commission amount that its being charged in this iteration
  */
  function chargeCommissionForMatch(uint256 _orderAmount, uint256 _matchedAmount, uint256 _commission, address _tokenAddress)
    external
    onlyOwner
    returns (uint256)
  {
    assert(_orderAmount >= _matchedAmount);
    uint256 finalCommission = _matchedAmount.mul(_commission).div(_orderAmount);
    exchangeCommissions[_tokenAddress] = exchangeCommissions[_tokenAddress].add(finalCommission);
    return finalCommission;
  }

  /**
    @notice Calculates the commission to be charged for an expiration/cancelation, also adds the said
    amount as a charged commission
    IT DOESN'T KEEP THE FUNDS NOR MOVES ANY
    @param _commission The remaining of the commission reserved at the insertion of the order
    @param _tokenAddress The address of the token
    @param _isExpiration If true order is taken as expired; else is taken as cancelled
    @return the commission amount that its being charged in this iteration
  */
  function chargeExceptionalCommission(uint256 _commission, address _tokenAddress, bool _isExpiration) external onlyOwner returns (uint256) {
    return chargeCommission(_commission, _isExpiration ? expirationPenaltyRate : cancelationPenaltyRate, _tokenAddress);
  }

  /**
    @notice Calculates the commission to be reserved in the insertion of an order
    IT DOESN'T KEEP THE FUNDS NOR MOVES ANY NOR TRACKS THE RETURNED AS CHARGED COMMISSION(IT IS JUST RESERVED)
    @param _amount Order locked amount
    @param _price Price equivalent to 1 DOC
   */
  function calculateInitialFee(uint256 _amount, uint256 _price) external view returns (uint256) {
    uint256 _minimumFixed = minimumCommission.mul(RATE_PRECISION).div(_price);
    uint256 _initialFee = _amount.mul(commissionRate).div(RATE_PRECISION);
    return _minimumFixed.add(_initialFee);
  }

  /**
    @param _beneficiaryAddress address to transfer the commission when instructed to
  */
  function setBeneficiaryAddress(address _beneficiaryAddress) external onlyAuthorizedChanger {
    require(_beneficiaryAddress != address(0), "beneficiaryAddress cannot be null");
    beneficiaryAddress = _beneficiaryAddress;
  }

  /**
    @param _commissionRate wad from 0 to 1 that represents the rate of the order amount to be charged as commission
  */
  function setCommissionRate(uint256 _commissionRate) external onlyAuthorizedChanger isValidRate(_commissionRate) {
    commissionRate = _commissionRate;
  }

  /**
    @param _cancelationPenaltyRate wad from 0 to 1 that represents the rate of the commission to charge as cancelation penalty, 1 represents the full commission
  */
  function setCancelationPenaltyRate(uint256 _cancelationPenaltyRate) external onlyAuthorizedChanger isValidRate(_cancelationPenaltyRate) {
    cancelationPenaltyRate = _cancelationPenaltyRate;
  }

  /**
    @param _expirationPenaltyRate wad from 0 to 1 that represents the rate of the commission to charge when the order expire, 1 represents the full commission
  */
  function setExpirationPenaltyRate(uint256 _expirationPenaltyRate) external onlyAuthorizedChanger isValidRate(_expirationPenaltyRate) {
    expirationPenaltyRate = _expirationPenaltyRate;
  }

  /**
    @param _minimumCommission is the minimum commission in DOC reserved in commission
  */
  function setMinimumCommission(uint256 _minimumCommission) external onlyAuthorizedChanger  {
    minimumCommission = _minimumCommission;
  }

  /**
    @notice Sets the charged commissions back to 0 for a given token
    It should be called after a withdrawal of the charged commissions
    IT DOESN'T MOVE ANY FUNDS
    @param _tokenAddress Address of the contract which manages the token
    in which the commissions were charged
   */
  function clearExchangeCommissions(address _tokenAddress) external onlyOwner {
    exchangeCommissions[_tokenAddress] = 0;
  }

  /**
    @dev This function must initialize every variable in storage, this is necessary because of the proxy
    pattern we are using. The initializer modifier disables this function once its called so it prevents
    that someone else calls it without the deployer noticing. Of course they may block your deploys but that
    would be an extremely unlucky scenario. onlyAuthorizedChanger cannot be used here since the governor is not set yet
    @param _beneficiaryAddress address to transfer the commission when instructed to
    @param _commissionRate wad from 0 to 1 that represents the rate of the order amount to be charged as commission
    @param _cancelationPenaltyRate wad from 0 to 1 that represents the rate of the commission to charge as cancelation penalty, 1 represents the full commission
    @param _expirationPenaltyRate wad from 0 to 1 that represents the rate of the commission to charge when the order expire, 1 represents the full commission
    @param _governor Address in charge of determining who is authorized and who is not
    @param _owner Dex contract
 */
  function initialize(
    address _beneficiaryAddress,
    uint256 _commissionRate,
    uint256 _cancelationPenaltyRate,
    uint256 _expirationPenaltyRate,
    address _governor,
    address _owner,
    uint256 _minimumCommission
  )
    external
    initializer
    isValidAddress(_beneficiaryAddress, "beneficiaryAddress cannot be null")
    isValidAddress(_governor, "governor cannot be null")
    isValidAddress(_owner, "owner cannot be null")
  {
    require(_commissionRate <= RATE_PRECISION, "commissionRate should to be in relation to 1");
    require(_cancelationPenaltyRate <= RATE_PRECISION, "cancelationPenaltyRate should to be in relation to 1");
    require(_expirationPenaltyRate <= RATE_PRECISION, "expirationPenaltyRate should to be in relation to 1");

    beneficiaryAddress = _beneficiaryAddress;
    commissionRate = _commissionRate;
    minimumCommission = _minimumCommission;
    cancelationPenaltyRate = _cancelationPenaltyRate;
    expirationPenaltyRate = _expirationPenaltyRate;
    Governed.initialize(_governor);
    Ownable(_owner);
  }

  /**
    @notice Calculates the commission to be charged for a given percentage of the reserved commission,
    also adds the said amount as a charged commission
    IT DOESN'T KEEP THE FUNDS NOR MOVES ANY
    @param _fullCommission The remaining of the commission reserved at the insertion of the order
    @param _tokenAddress The address of the token
    @param _rate Rate of the commission to be charged
    @return the commission amount that its being charged in this iteration
  */
  function chargeCommission(uint256 _fullCommission, uint256 _rate, address _tokenAddress) private returns (uint256) {
    uint256 finalCommission = _fullCommission.mul(_rate).div(RATE_PRECISION);
    exchangeCommissions[_tokenAddress] = exchangeCommissions[_tokenAddress].add(finalCommission);
    return finalCommission;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
