pragma solidity ^0.4.25;

contract ZkDaiBase {
  uint256 public cooldown;
  uint256 public stake;

  enum SubmissionType {Invalid, Create, Spend}
  struct Submission {
    address submitter;
    SubmissionType sType;
    uint256 submittedAt;
    uint256[] publicInput;
  }
  mapping(bytes32 => Submission) public submissions;

  enum State {Invalid, Committed, Spent}
  mapping(bytes32 => State) public notes;
  
  event NoteStateChange(bytes32 note, State state);
  event Submitted(address submitter, bytes32 proofHash);

  function getProofHash(
      uint[2] a,
      uint[2] a_p,
      uint[2][2] b,
      uint[2] b_p,
      uint[2] c,
      uint[2] c_p,
      uint[2] h,
      uint[2] k)
    internal
    pure
    returns(bytes32) {
      return keccak256(abi.encodePacked(a, a_p, b, b_p, c, c_p, h, k));
  }
  
  function calcNoteHash(uint _a, uint _b)
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