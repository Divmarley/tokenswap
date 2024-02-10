// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 



contract BProToken is ERC20{
  string _name = "BITPRO";
  string _symbol = "BITPRO"; 
  address _owner;


  constructor() ERC20(_name, _symbol) {}
 
}
