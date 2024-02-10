// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";  


contract TestToken is ERC20 {
  string _name = "Test Dollar on Chain";
  string _symbol = "TDOC";
  uint8 _decimals = 15;

  constructor() ERC20(_name, _symbol) {}

  //Fallback
  // function() external {}
}
