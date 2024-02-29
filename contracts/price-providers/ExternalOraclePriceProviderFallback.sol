// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./PriceProviderFallback.sol";
// import "../interface/IMoCDecentralizedExchange.sol";

/**
  @notice if the externalPriceProvider price source is not available, falls back
          to dex getLastClosingPrice method for the given pair
*/
contract ExternalOraclePriceProviderFallback is PriceProviderFallback {
  IPriceProvider public externalPriceProvider;

  constructor(
    IPriceProvider _externalPriceProvider,
    IMoCDecentralizedExchange _dex,
    address _baseToken,
    address _secondaryToken
  )  PriceProviderFallback(_dex, _baseToken, _secondaryToken) {
    externalPriceProvider = _externalPriceProvider;
  }

  function failablePeek() internal view  override returns (bytes32, bool) {
    return externalPriceProvider.peek();
  }
}
