// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./PriceProviderFallback.sol";
import "../interface/IMocState.sol";

/**
  @notice gets the BproUsd Price from MocState contract
  @dev as bproUsdPrice function revers in case no price available in
       BtcPriceProvider, we first peek() for it directly.
*/
contract MocBproUsdPriceProviderFallback is PriceProviderFallback {
  IMocState public mocState;

  constructor(
    IMocState _mocState,
    IMoCDecentralizedExchange _dex,
    address _baseToken,
    address _secondaryToken
  ) public PriceProviderFallback(_dex, _baseToken, _secondaryToken) {
    mocState = _mocState;
  }

  function failablePeek() internal view override returns (bytes32, bool) {
    // MocState BtcPriceProvider is complient with IPriceProvider interface
    IPriceProvider priceProvider = IPriceProvider(mocState.getBtcPriceProvider());
    (bytes32 btcPrice, bool isValid) = priceProvider.peek();
    // Only if MocState BtcPriceProvider has a valid price, we query for the bproUsdPrice
    if (isValid && btcPrice != bytes32(0)) {
      uint256 bproUsdPrice = mocState.bproUsdPrice();
      return (bytes32(bproUsdPrice), bproUsdPrice != 0);
    }
    return (btcPrice, false);
  }
}
