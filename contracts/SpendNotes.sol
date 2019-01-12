pragma solidity ^0.4.25;

import {Verifier as SpendNoteVerifier} from "./verifiers/SpendNoteVerifier.sol";
import "./ZkDaiBase.sol";

contract SpendNotes is SpendNoteVerifier, ZkDaiBase {
  uint8 internal constant NUM_PUBLIC_INPUTS = 7;

  event Submitted(address indexed submitter, bytes32 proofHash);
  function submit(
      uint[2] a,
      uint[2] a_p,
      uint[2][2] b,
      uint[2] b_p,
      uint[2] c,
      uint[2] c_p,
      uint[2] h,
      uint[2] k,
      uint[7] input)
    internal {
      // check first note (among public params) is valid and unspent 
      bytes32 note = calcNoteHash(input[0], input[1]);
      require(notes[note] == State.Committed, 'Note is either invalid or already spent');
      
      bytes32 proofHash = getProofHash(a, a_p, b, b_p, c, c_p, h, k);
      uint256[] memory publicInput = new uint256[](7);
      for(uint8 i = 0; i < NUM_PUBLIC_INPUTS; i++) {
        publicInput[i] = input[i];
      }
      submissions[proofHash] = Submission(now, msg.sender, publicInput);
      emit Submitted(msg.sender, proofHash);
  }

  function commit(bytes32 proofHash)
    internal {
      Submission storage submission = submissions[proofHash];
      require(submission.submitter != address(0x0), 'Corresponding hash of proof doesnt exist');
      require(submission.submittedAt + cooldown < now, 'Note is still hot');
      _commit(proofHash);
  }

  function _commit(bytes32 proofHash)
    internal {
      Submission storage submission = submissions[proofHash];
      bytes32[3] memory _notes = get3Notes(submission.publicInput);
      notes[_notes[0]] = State.Spent;
      notes[_notes[1]] = State.Committed;
      notes[_notes[2]] = State.Committed;

      delete submissions[proofHash];
      submission.submitter.transfer(stake);
      emit NoteStateChange(_notes[0], State.Spent);
      emit NoteStateChange(_notes[1], State.Committed);
      emit NoteStateChange(_notes[2], State.Committed);
  }

  function get3Notes(uint[] input) internal pure returns(bytes32[3] notes) {
    notes[0] = calcNoteHash(input[0], input[1]);
    notes[1] = calcNoteHash(input[2], input[3]);
    notes[2] = calcNoteHash(input[4], input[5]);
  }

  event Challenged(address indexed challenger, bytes32 proofHash);
  function challenge(
      uint[2] a,
      uint[2] a_p,
      uint[2][2] b,
      uint[2] b_p,
      uint[2] c,
      uint[2] c_p,
      uint[2] h,
      uint[2] k)
    external {
      bytes32 proofHash = getProofHash(a, a_p, b, b_p, c, c_p, h, k);
      Submission storage submission = submissions[proofHash];
      require(submission.submitter != address(0x0), 'Corresponding hash of proof doesnt exist');
      require(submission.submittedAt + cooldown >= now, 'Note cannot be challenged anymore');
      uint256[NUM_PUBLIC_INPUTS] memory input;
      for(uint i = 0; i < NUM_PUBLIC_INPUTS; i++) {
        input[i] = submission.publicInput[i];
      }
      if (!SpendNoteVerifier.verifyTx(a, a_p, b, b_p, c, c_p, h, k, input)) {
        // challenge passed
        delete submissions[proofHash];
        msg.sender.transfer(stake);
        emit Challenged(msg.sender, proofHash);
      } else {
        // challenge failed
        _commit(proofHash);
      }
  }
}