pragma solidity ^0.4.25;

import {Verifier as MintNoteVerifier} from "./verifiers/MintNoteVerifier.sol";
import "./ZkDaiBase.sol";


contract LiquidateNotes is MintNoteVerifier, ZkDaiBase {
  uint8 internal constant NUM_PUBLIC_INPUTS = 4;

  /**
  * @dev Hashes the submitted proof and adds it to the submissions mapping that tracks
  *      submission time, type, public inputs of the zkSnark and the submitter
  */
  function submit(
      address to,
      uint256[2] a,
      uint256[2] a_p,
      uint256[2][2] b,
      uint256[2] b_p,
      uint256[2] c,
      uint256[2] c_p,
      uint256[2] h,
      uint256[2] k,
      uint256[4] input)
    internal
  {
      bytes32 proofHash = getProofHash(a, a_p, b, b_p, c, c_p, h, k);
      uint256[] memory publicInput = new uint256[](NUM_PUBLIC_INPUTS + 1);
      for(uint8 i = 0; i < NUM_PUBLIC_INPUTS; i++) {
        publicInput[i] = input[i];
      }
      // last element is the beneficiary to whom the liquidated dai will be transferred 
      publicInput[NUM_PUBLIC_INPUTS] = uint256(to);
      submissions[proofHash] = Submission(msg.sender, SubmissionType.Liquidate, now, publicInput);
      emit Submitted(msg.sender, proofHash);
  }

  /**
  * @dev Commits the proof i.e. Mints the note that originally came with the proof.
  * @param proofHash Hash of the proof to be committed
  */
  function liquidateCommit(bytes32 proofHash)
    internal
  {
      Submission storage submission = submissions[proofHash];
      bytes32 note = calcNoteHash(submission.publicInput[0], submission.publicInput[1]);
      require(notes[note] == State.Committed, "Note is either invalid or already spent");

      notes[note] = State.Spent;
      submission.submitter.transfer(stake);
      address to = address(uint160(submission.publicInput[NUM_PUBLIC_INPUTS])); // see submit above
      uint256 value = submission.publicInput[2];
      delete submissions[proofHash];
      require(
        dai.transfer(to, value),
        "daiToken transfer failed"
      );
      emit NoteStateChange(note, State.Spent);
  }

  /**
  * @dev Challenge the proof for mint step
  * @notice params: a, a_p, b, b_p, c, c_p, h, k zkSnark parameters of the challenged proof
  * @param proofHash Hash of the proof
  */
  function challenge(
      uint256[2] a,
      uint256[2] a_p,
      uint256[2][2] b,
      uint256[2] b_p,
      uint256[2] c,
      uint256[2] c_p,
      uint256[2] h,
      uint256[2] k,
      bytes32 proofHash)
    internal
    {
      Submission storage submission = submissions[proofHash];
      uint256[NUM_PUBLIC_INPUTS] memory input;
      for(uint i = 0; i < NUM_PUBLIC_INPUTS; i++) {
        input[i] = submission.publicInput[i];
      }
      // zk circuit for mint and liquidate is same
      if (!mintVerifyTx(a, a_p, b, b_p, c, c_p, h, k, input)) {
        // challenge passed
        delete submissions[proofHash];
        msg.sender.transfer(stake);
        emit Challenged(msg.sender, proofHash);
      } else {
        // challenge failed
        liquidateCommit(proofHash);
      }
  }
}