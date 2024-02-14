// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
import "./OwnerBurnableToken.sol";


contract DocToken is ERC20 {
  string _name = "Dollar on Chain";
  string _symbol = "DOC";
  uint8 _decimals = 18;

  constructor() ERC20(_name, _symbol) {}

  //Fallback
  // function() external {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
