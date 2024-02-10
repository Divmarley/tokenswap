// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/**
 * @notice Get price of a Token. See https://github.com/money-on-chain/OMoC-Decentralized-Oracle
 * @dev Interface of OMoC-Decentralized-Oracle, compatible with MOC.
 */
interface IPriceProvider {
  function peek() external view returns (bytes32, bool);
}
