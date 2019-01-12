pragma solidity ^0.4.25;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import "./CreateNotes.sol";
import "./SpendNotes.sol";

contract ZkDai is CreateNotes {
  ERC20 internal DAI_TOKEN_ADDRESS;

  constructor(uint256 _cooldown, uint256 _stake, address daiTokenAddress)
    public {
      cooldown = _cooldown;
      stake = _stake;
      DAI_TOKEN_ADDRESS = ERC20(daiTokenAddress);
  }

  function submitNewNote(
      uint[2] a,
      uint[2] a_p,
      uint[2][2] b,
      uint[2] b_p,
      uint[2] c,
      uint[2] c_p,
      uint[2] h,
      uint[2] k,
      uint[4] input)
    external
    payable {
      require(msg.value == stake, 'Invalid stake amount');
      // require(
      //   DAI_TOKEN_ADDRESS.transfer(msg.sender, uint256(input[2]) /* value */),
      //   'daiToken transfer failed'
      // );
      CreateNotes.submit(a, a_p, b, b_p, c, c_p, h, k, input);
    }

    function liquidateNote() {

    }

}