// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../interface/IPriceProvider.sol";

/**
  @notice Price provider that always will return Unity price (one) with 18th precision
          Intended to pairs that has a theoretical equivalent value
 */
contract UnityPriceProvider is IPriceProvider {

  bytes32 constant ONE = bytes32(uint256(10**18));

  function peek() external pure returns (bytes32, bool) {
    return (ONE, true);
  }
}
