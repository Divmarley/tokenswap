// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "../Governance/ChangeContract.sol";

import "../MoCDecentralizedExchange.sol";

/**
  @notice Changer that adds one or more pair of tokens to be listed in the MoC Decentralized Exchange
*/
contract AddTokenPairChanger is ChangeContract {
  MoCDecentralizedExchange public dex;
  address[] public baseTokens;
  address[] public secondaryTokens;
  address[] public priceProviders;
  uint256[] public precisions;
  uint256[] public prices;

  /**
    @notice Initialize the changer Each list must have the same length and have related
    data in the same index
    @param _dex Address of the decentralized exchange
    @param _baseTokens Array of the base token to be used in each pair
    @param _secondaryTokens Array of the secondary token to be used in each pair
    @param _precisions Array of the precisision to be used in the price of each pair
    @param _prices Array of the initial price to be used in each pair
   */
  constructor(
    MoCDecentralizedExchange _dex,
    address[] memory _baseTokens,
    address[] memory _secondaryTokens,
    address[] memory _priceProviders,
    uint256[] memory _precisions,
    uint256[] memory _prices
  )  {
    require(
      _baseTokens.length == _secondaryTokens.length && _baseTokens.length == _precisions.length && _baseTokens.length == _priceProviders.length,
      "All three arrays must have the same length"
    );
    dex = _dex;
    baseTokens = _baseTokens;
    secondaryTokens = _secondaryTokens;
    priceProviders = _priceProviders;
    precisions = _precisions;
    prices = _prices;
  }

  /**
    @notice Function intended to be called by the governor when ready to run
  */
  function execute() external {
    uint256 i;
    for (i = 0; i < baseTokens.length; i++) {
      dex.addTokenPair(baseTokens[i], secondaryTokens[i], priceProviders[i], precisions[i], prices[i]);
    }
  }
}
