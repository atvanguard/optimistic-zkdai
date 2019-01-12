pragma solidity ^0.4.25;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import {Verifier as CreateNoteVerifier} from "./verifiers/CreateNoteVerifier.sol";

contract ZkDai is CreateNoteVerifier {

  ERC20 internal DAI_TOKEN_ADDRESS;

  uint256 public cooldown;
  uint256 public stake;
  constructor(uint256 _cooldown, uint256 _stake, address daiTokenAddress)
    public {
      cooldown = _cooldown;
      stake = _stake;
      DAI_TOKEN_ADDRESS = ERC20(daiTokenAddress);
  }

  struct Submission {
    bytes32 proofHash;
    uint256 submittedAt;
    address submitter;
  }

  enum State {Invalid, Submitted, Committed, Challenged, Spent}
  struct Note {
    Submission submission;
    State state;
  }
  mapping(bytes32 => Note) public notes;
  
  event NoteStateChange(bytes32 note, State state);
  event Submitted(address submitter, bytes32 note, bytes32 proofHash);

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
      bytes32 proofHash = getProofHash(a, a_p, b, b_p, c, c_p, h, k, input);
      Submission memory submission = Submission(proofHash, now, msg.sender);
      bytes32 note = _calcNoteHash(input[0], input[1]);
      notes[note] = Note(submission, State.Submitted);
      emit NoteStateChange(note, State.Submitted);
      emit Submitted(msg.sender, note, proofHash);
  }

  function commit(bytes32 _note) 
    public {
      Note storage note = notes[_note];
      require(note.state == State.Submitted, 'Note needs to be in the submitted state to be committed');
      require(note.submission.submittedAt + cooldown < now, 'Note is still HOT!');
      _commit(_note);
  }

  function _commit(bytes32 _note)
    internal {
      Note storage note = notes[_note];
      note.state = State.Committed;
      note.submission.submitter.transfer(stake);
      emit NoteStateChange(_note, State.Committed);
  }

  function challenge(
      bytes32 _note,
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
      Note storage note = notes[_note];
      require(note.state == State.Submitted, 'Note needs to be in the Submitted state to be challenged');

      Submission storage submission = note.submission;
      require(submission.submittedAt + cooldown >= now);

      bytes32 proofHash = getProofHash(a, a_p, b, b_p, c, c_p, h, k, input);
      require(submission.proofHash == proofHash, 'Challenged proof is different from what was submitted');
      if (!CreateNoteVerifier.verifyTx(a, a_p, b, b_p, c, c_p, h, k, input)) {
        // challenge passed
        note.state = State.Challenged;
        msg.sender.transfer(stake);
        emit NoteStateChange(_note, State.Challenged);
      } else {
        // challenge failed
        _commit(_note);
      }
  }

  function getProofHash(
      uint[2] a,
      uint[2] a_p,
      uint[2][2] b,
      uint[2] b_p,
      uint[2] c,
      uint[2] c_p,
      uint[2] h,
      uint[2] k,
      uint[4] input)
    internal
    pure
    returns(bytes32) {
      return keccak256(abi.encodePacked(a, a_p, b, b_p, c, c_p, h, k, input));
  }

  function _calcNoteHash(uint _a, uint _b)
    internal
    pure
    returns(bytes32 note) {
      bytes16 a = bytes16(_a);
      bytes16 b = bytes16(_b);
      bytes memory _note = new bytes(32);
      
      for (uint i = 0; i < 16; i++) {
        _note[i] = a[i];
        _note[16 + i] = b[i];
      }
      note = _bytesToBytes32(_note, 0);
  }

  function _bytesToBytes32(bytes b, uint offset)
    internal
    pure
    returns (bytes32 out) {
      for (uint i = 0; i < 32; i++) {
        out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
      }
  }
}