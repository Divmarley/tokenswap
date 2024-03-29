// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../interface/IPriceProvider.sol";

contract TokenPriceProviderFake is IPriceProvider {
  bytes32 tokenPrice;
  bool has;

  constructor()  {
    tokenPrice = bytes32(uint256(2 * 10**18));
    has = true;
  }

  function peek() external view returns (bytes32, bool) {
    return (tokenPrice, has);
  }

  function poke(uint256 _tokenPrice) external {
    tokenPrice = bytes32(_tokenPrice);
  }

  function pokeValidity(bool _has) external {
    has = _has;
  }
}
