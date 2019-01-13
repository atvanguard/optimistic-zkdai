pragma solidity ^0.4.25;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import "./MintNotes.sol";
import "./SpendNotes.sol";
import "./LiquidateNotes.sol";

contract ZkDai is MintNotes, SpendNotes {
  ERC20 internal DAI_TOKEN_ADDRESS;

  constructor(uint256 _cooldown, uint256 _stake, address daiTokenAddress)
    public {
      cooldown = _cooldown;
      stake = _stake;
      DAI_TOKEN_ADDRESS = ERC20(daiTokenAddress);
  }

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
      // check that the first note (among public params) is valid and unspent 
      bytes32 note = calcNoteHash(input[0], input[1]);
      require(notes[note] == State.Committed, 'Note is either invalid or already spent');
      require(msg.value == stake, 'Invalid stake amount');
      SpendNotes.submit(a, a_p, b, b_p, c, c_p, h, k, input);
  }

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
        if (submission.sType == SubmissionType.Create) {
          MintNotes.challenge(a, a_p, b, b_p, c, c_p, h, k, proofHash);
        } else if (submission.sType == SubmissionType.Spend) {
          SpendNotes.challenge(a, a_p, b, b_p, c, c_p, h, k, proofHash);
        }
    }

    function commit(bytes32 proofHash)
      public {
        Submission storage submission = submissions[proofHash];
        require(submission.sType != SubmissionType.Invalid, 'proofHash is invalid');
        require(submission.submittedAt + cooldown < now, 'Note is still hot');
        if (submission.sType == SubmissionType.Create) {
          mintCommit(proofHash);
        } else if (submission.sType == SubmissionType.Spend) {
          spendCommit(proofHash);
        }
    }

    // function liquidate(
    //     address to,
    //     uint[2] a,
    //     uint[2] a_p,
    //     uint[2][2] b,
    //     uint[2] b_p,
    //     uint[2] c,
    //     uint[2] c_p,
    //     uint[2] h,
    //     uint[2] k,
    //     uint[4] input)
    //   external {
    //     LiquidateNotes.liquidateNote(a, a_p, b, b_p, c, c_p, h, k, input);
    //     require(
    //       DAI_TOKEN_ADDRESS.transfer(to, uint256(input[2]) /* value */),
    //       'daiToken transfer failed'
    //   );
    // }
}