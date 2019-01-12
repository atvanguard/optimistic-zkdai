pragma solidity ^0.4.25;

import {Verifier as LiquidateNoteVerifier} from "./verifiers/LiquidateNoteVerifier.sol";

contract LiquidateNotes is LiquidateNoteVerifier {
  function liquidateNote(
      uint[2] a,
      uint[2] a_p,
      uint[2][2] b,
      uint[2] b_p,
      uint[2] c,
      uint[2] c_p,
      uint[2] h,
      uint[2] k,
      uint[4] input)
    internal {
      require(verifyTx(a, a_p, b, b_p, c, c_p, h, k, input), 'invalid zk proof');
  }
}