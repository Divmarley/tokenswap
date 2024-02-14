// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 


/**
   @title Owner Burnable Token
   @dev Token that allows the owner to irreversibly burned (destroyed) any token.
 */
contract OwnerBurnableToken is ERC20,Ownable {
  constructor() ERC20("OwnerBurnableToken", "ow") Ownable(msg.sender){}
  
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
   
}
