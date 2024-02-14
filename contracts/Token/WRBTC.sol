// FIXME: this is licensed under gplv3, check that we respect it when releasing the source code
// https://kovan.etherscan.io/address/0xd0A1E359811322d97991E03f863a0C30C2cF029C#contracts
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 


contract WRBTC is ERC20 { 
  event Deposit(address indexed dst, uint256 wad);
  event Withdrawal(address indexed src, uint256 wad);

 
 mapping(address => uint256) public  _balanceOf;
  mapping(address => mapping(address => uint256)) public  _allowance;
  constructor() ERC20("Wrapped RSK Bitcoin","WRBTC"){}

   function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

  function deposit() public payable {
    _balanceOf[msg.sender] += msg.value;
    emit Deposit(msg.sender, msg.value);

  }

  function withdraw(uint256 wad) public {
    require(_balanceOf[msg.sender] >= wad);
    _balanceOf[msg.sender] -= wad;
    // msg.sender.transfer(wad);
    emit Withdrawal(msg.sender, wad);
  }

  function totalSupply() public view override returns (uint256) {
    return address(this).balance;
  }

  function approve(address guy, uint256 wad) public override returns (bool) {
    _allowance[msg.sender][guy] = wad;
    emit Approval(msg.sender, guy, wad);
    return true;
  }

  function transfer(address dst, uint256 wad) public override returns (bool) {
    return transferFrom(msg.sender, dst, wad);
  }

  function transferFrom(address src, address dst, uint256 wad) public override returns (bool) {
    require(_balanceOf[src] >= wad);

    if (src != msg.sender && _allowance[src][msg.sender] != uint256(1)) {
      require(_allowance[src][msg.sender] >= wad);
      _allowance[src][msg.sender] -= wad;
    }

    _balanceOf[src] -= wad;
    _balanceOf[dst] += wad;

    emit Transfer(src, dst, wad);

    return true;
  }
}
