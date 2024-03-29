// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../Governance/ChangeContract.sol";

import "../RestrictiveOrderListing.sol";


/**
  @notice Changer to change the min order amount in the MoC Decentralized Exchange
 */
contract MinOrderAmountChanger is ChangeContract {
  RestrictiveOrderListing public restrictiveOrderListing;
  uint256 public minOrderAmount;

  /**
    @notice Initialize the changer.
    @param _restrictiveOrderListing Address of the restrictiveOrderListing to change(dex)
    @param _minOrderAmount New min order amount in commonBaseToken minimum(tipically wei) currency
   */
  constructor(RestrictiveOrderListing _restrictiveOrderListing, uint256 _minOrderAmount)  {
    restrictiveOrderListing = _restrictiveOrderListing;
    minOrderAmount = _minOrderAmount;
  }

  /**
    @notice Function intended to be called by the governor when ready to run
  */
  function execute() external {
    restrictiveOrderListing.setMinOrderAmount(minOrderAmount);
  }
}
