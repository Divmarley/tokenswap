// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 


/**
   @title Owner Burnable Token
   @dev Token that allows the owner to irreversibly burned (destroyed) any token.
 */
contract OwnerBurnableToken is Ownable {
  constructor() Ownable(msg.sender){}
  /**
     @dev Burns a specific amount of tokens for the address.
     @param who who's tokens are gona be burned
     @param value The amount of token to be burned.
   */
   
}
