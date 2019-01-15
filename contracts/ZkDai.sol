pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./MintNotes.sol";
import "./SpendNotes.sol";
import "./LiquidateNotes.sol";


contract ZkDai is MintNotes, SpendNotes, LiquidateNotes {

  modifier validStake(uint256 _stake)
  {
      require(_stake == stake, "Invalid stake amount");
      _;
  }

  constructor(uint256 _cooldown, uint256 _stake, address daiTokenAddress)
    public
  {
      cooldown = _cooldown;
      stake = _stake;
      dai = ERC20(daiTokenAddress);
  }

  /**
  * @dev Transfers specified number of dai tokens to itself and submits the zkSnark proof to mint a new note
  * @notice params: a, a_p, b, b_p, c, c_p, h, k zkSnark parameters
  * @param input Public inputs of the zkSnark
  */
  function mint(
      uint256[2] a,
      uint256[2] a_p,
      uint256[2][2] b,
      uint256[2] b_p,
      uint256[2] c,
      uint256[2] c_p,
      uint256[2] h,
      uint256[2] k,
      uint256[4] input)
    external
    payable
    validStake(msg.value)
  {
      require(
        dai.transferFrom(msg.sender, address(this), uint256(input[2]) /* value */),
        "daiToken transfer failed"
      );
      MintNotes.submit(a, a_p, b, b_p, c, c_p, h, k, input);
  }

  /**
  * @dev Submits the zkSnark proof to be able to spend a note and create two new notes
  * @notice params: a, a_p, b, b_p, c, c_p, h, k zkSnark parameters
  * @param input Public inputs of the zkSnark
  */
  function spend(
      uint256[2] a,
      uint256[2] a_p,
      uint256[2][2] b,
      uint256[2] b_p,
      uint256[2] c,
      uint256[2] c_p,
      uint256[2] h,
      uint256[2] k,
      uint256[7] input)
    external
    payable
    validStake(msg.value)
  {
      SpendNotes.submit(a, a_p, b, b_p, c, c_p, h, k, input);
  }

  /**
  * @dev Liquidate a note to transfer the equivalent amount of dai to the recipient
  * @param to Recipient of the dai tokens
  * @notice params: a, a_p, b, b_p, c, c_p, h, k zkSnark parameters
  * @param input Public inputs of the zkSnark
  */
  function liquidate(
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
    external
    payable
    validStake(msg.value)
  {
      LiquidateNotes.submit(to, a, a_p, b, b_p, c, c_p, h, k, input);
  }

  /**
  * @dev Challenge the mint or spend proofs and claim the stake amount if challenge passes.
  * @notice If challenge passes, the challenger claims the stake amount,
  *         otherwise note(s) are committed/spent and stake is transferred back to proof submitter.
  * @notice params: a, a_p, b, b_p, c, c_p, h, k zkSnark parameters of the challenged proof
  */
  function challenge(
      uint256[2] a,
      uint256[2] a_p,
      uint256[2][2] b,
      uint256[2] b_p,
      uint256[2] c,
      uint256[2] c_p,
      uint256[2] h,
      uint256[2] k)
    external
  {
      bytes32 proofHash = getProofHash(a, a_p, b, b_p, c, c_p, h, k);
      Submission storage submission = submissions[proofHash];
      require(submission.sType != SubmissionType.Invalid, "Corresponding hash of proof doesnt exist");
      require(submission.submittedAt + cooldown >= now, "Note cannot be challenged anymore");
      if (submission.sType == SubmissionType.Mint) {
        MintNotes.challenge(a, a_p, b, b_p, c, c_p, h, k, proofHash);
      } else if (submission.sType == SubmissionType.Spend) {
        SpendNotes.challenge(a, a_p, b, b_p, c, c_p, h, k, proofHash);
      } else if (submission.sType == SubmissionType.Liquidate) {
        LiquidateNotes.challenge(a, a_p, b, b_p, c, c_p, h, k, proofHash);
      }
  }

  /**
  * @dev Commit a particular proof once the challenge period has ended
  * @param proofHash Hash of the proof that needs to be committed
  */
  function commit(bytes32 proofHash)
    public
  {
      Submission storage submission = submissions[proofHash];
      require(submission.sType != SubmissionType.Invalid, "proofHash is invalid");
      require(submission.submittedAt + cooldown < now, "Note is still hot");
      if (submission.sType == SubmissionType.Mint) {
        mintCommit(proofHash);
      } else if (submission.sType == SubmissionType.Spend) {
        spendCommit(proofHash);
      } else if (submission.sType == SubmissionType.Liquidate) {
        liquidateCommit(proofHash);
      }
  }
}