// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../Governance/ChangeContract.sol";

import "../CommissionManager.sol";


/**
  @notice Changer to change the cancelation penalty rate used in the MoC Decentralized Exchange
 */
contract CancelationPenaltyRateChanger is ChangeContract {
  CommissionManager public commissionManager;
  uint256 public cancelationPenaltyRate;

  /**
    @notice Initialize the changer.
    @param _commissionManager Address of the commission manager to change
    @param _cancelationPenaltyRate New cancelation penalty rate to be set. Must be between 0 and 1(RATE_PRECISION)
   */
  constructor(CommissionManager _commissionManager, uint256 _cancelationPenaltyRate)  {
    commissionManager = _commissionManager;
    cancelationPenaltyRate = _cancelationPenaltyRate;
  }

  /**
    @notice Function intended to be called by the governor when ready to run
  */
  function execute() external {
    commissionManager.setCancelationPenaltyRate(cancelationPenaltyRate);
  }
}
