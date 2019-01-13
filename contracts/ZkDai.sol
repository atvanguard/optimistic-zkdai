pragma solidity ^0.4.25;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import "./MintNotes.sol";
import "./SpendNotes.sol";

contract ZkDai is MintNotes, SpendNotes {
  ERC20 internal DAI_TOKEN_ADDRESS;

  constructor(uint256 _cooldown, uint256 _stake, address daiTokenAddress)
    public {
      cooldown = _cooldown;
      stake = _stake;
      DAI_TOKEN_ADDRESS = ERC20(daiTokenAddress);
  }

  /**
  * @dev Transfers specified number of dai tokens to itself and submits the zkSnark proof to mint a new note
  * @notice params: a, a_p, b, b_p, c, c_p, h, k zkSnark parameters
  * @param input Public inputs of the zkSnark
  */
  function mint(
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
      // check that the first note (among public params) is not already minted 
      bytes32 note = calcNoteHash(input[0], input[1]);
      require(notes[note] == State.Invalid, 'Note was already minted');
      require(msg.value == stake, 'Invalid stake amount');
      require(
        DAI_TOKEN_ADDRESS.transferFrom(msg.sender, address(this), uint256(input[2]) /* value */),
        'daiToken transfer failed'
      );
      MintNotes.submit(a, a_p, b, b_p, c, c_p, h, k, input);
  }

  /**
  * @dev Submits the zkSnark proof to be able to spend a note and create two new notes
  * @notice params: a, a_p, b, b_p, c, c_p, h, k zkSnark parameters
  * @param input Public inputs of the zkSnark
  */
  function spend(
      uint[2] a,
      uint[2] a_p,
      uint[2][2] b,
      uint[2] b_p,
      uint[2] c,
      uint[2] c_p,
      uint[2] h,
      uint[2] k,
      uint[7] input)
    external
    payable {
      // check that the first note (among public params) is committed 
      bytes32 note0 = calcNoteHash(input[0], input[1]);
      require(notes[note0] == State.Committed, 'Note is either invalid or already spent');

      // new notes should not be existing at this point
      bytes32 note1 = calcNoteHash(input[2], input[3]);
      require(notes[note1] == State.Invalid, 'output note1 is already minted');

      bytes32 note2 = calcNoteHash(input[4], input[5]);
      require(notes[note2] == State.Invalid, 'output note2 is already minted');

      require(msg.value == stake, 'Invalid stake amount');
      SpendNotes.submit(a, a_p, b, b_p, c, c_p, h, k, input);
  }

  /**
  * @dev Challenge the mint or spend proofs and claim the stake amount if challenge passes.
  * @notice If challenge passes, the challenger claims the stake amount,
  *         otherwise note(s) are committed/spent and stake is transferred back to proof submitter.
  * @notice params: a, a_p, b, b_p, c, c_p, h, k zkSnark parameters of the challenged proof
  */
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
      require(submission.sType != SubmissionType.Invalid, 'Corresponding hash of proof doesnt exist');
      require(submission.submittedAt + cooldown >= now, 'Note cannot be challenged anymore');
      if (submission.sType == SubmissionType.Mint) {
        MintNotes.challenge(a, a_p, b, b_p, c, c_p, h, k, proofHash);
      } else if (submission.sType == SubmissionType.Spend) {
        SpendNotes.challenge(a, a_p, b, b_p, c, c_p, h, k, proofHash);
      }
  }

  /**
  * @dev Commit a particular proof once the challenge period has ended
  * @param proofHash Hash of the proof that needs to be committed
  */
  function commit(bytes32 proofHash)
    public {
      Submission storage submission = submissions[proofHash];
      require(submission.sType != SubmissionType.Invalid, 'proofHash is invalid');
      require(submission.submittedAt + cooldown < now, 'Note is still hot');
      if (submission.sType == SubmissionType.Mint) {
        mintCommit(proofHash);
      } else if (submission.sType == SubmissionType.Spend) {
        spendCommit(proofHash);
      }
  }

  /**
  * @dev Liquidate a note to transfer the equivalent amount of dai to the recipient
  * @param to Recipient of the dai tokens
  * @notice params: a, a_p, b, b_p, c, c_p, h, k zkSnark parameters
  * @param input Public inputs of the zkSnark
  */
  function liquidate(
      address to,
      uint[2] a,
      uint[2] a_p,
      uint[2][2] b,
      uint[2] b_p,
      uint[2] c,
      uint[2] c_p,
      uint[2] h,
      uint[2] k,
      uint[4] input)
    external {
      // zk circuit for mint and liquidate is same
      // doesnt use the optimist pattern
      require(
        mintVerifyTx(a, a_p, b, b_p, c, c_p, h, k, input),
        'Invalid zk proof'
      );
      bytes32 note = calcNoteHash(input[0], input[1]);
      require(notes[note] == State.Committed, 'Note is either invalid or already spent');
      notes[note] = State.Spent;
      require(
        DAI_TOKEN_ADDRESS.transfer(to, uint256(input[2]) /* value */),
        'daiToken transfer failed'
      );
      emit NoteStateChange(note, State.Spent);
  }
}