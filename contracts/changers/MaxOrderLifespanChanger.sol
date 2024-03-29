// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "../Governance/ChangeContract.sol";

import "../RestrictiveOrderListing.sol";


/**
  @notice Changer to change the max order lifespan in the MoC Decentralized Exchange
 */
contract MaxOrderLifespanChanger is ChangeContract {
  RestrictiveOrderListing public restrictiveOrderListing;
  uint64 public maxOrderLifespan;

  /**
    @notice Initialize the changer.
    @param _restrictiveOrderListing Address of the restrictiveOrderListing to change(dex)
    @param _maxOrderLifespan New max order lifespan.
   */
  constructor(RestrictiveOrderListing _restrictiveOrderListing, uint64 _maxOrderLifespan)  {
    restrictiveOrderListing = _restrictiveOrderListing;
    maxOrderLifespan = _maxOrderLifespan;
  }

  /**
    @notice Function intended to be called by the governor when ready to run
  */
  function execute() external {
    restrictiveOrderListing.setMaxOrderLifespan(maxOrderLifespan);
  }
}
