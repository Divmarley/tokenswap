// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../Governance/ChangeContract.sol";

import "../CommissionManager.sol";


/**
  @notice Changer to change the expiration penalty rate used in the MoC Decentralized Exchange
 */
contract ExpirationPenaltyRateChanger is ChangeContract {
  CommissionManager public commissionManager;
  uint256 public expirationPenaltyRate;

  /**
    @notice Initialize the changer.
    @param _commissionManager Address of the commission manager to change
    @param _expirationPenaltyRate New expiration penalty rate to be set. Must be between 0 and 1(RATE_PRECISION)
   */
  constructor(CommissionManager _commissionManager, uint256 _expirationPenaltyRate)  {
    commissionManager = _commissionManager;
    expirationPenaltyRate = _expirationPenaltyRate;
  }

  /**
    @notice Function intended to be called by the governor when ready to run
  */
  function execute() external {
    commissionManager.setExpirationPenaltyRate(expirationPenaltyRate);
  }
}
