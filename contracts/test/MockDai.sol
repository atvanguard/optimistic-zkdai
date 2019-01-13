pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';

contract MockDai is ERC20 {
  constructor() public {
    _mint(msg.sender, 100 * 10**18);
  }
}