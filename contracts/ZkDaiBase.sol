pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";


contract ZkDaiBase {
  uint256 public cooldown;
  uint256 public stake;
  ERC20 public dai;

  enum SubmissionType {Invalid, Mint, Spend, Liquidate}
  struct Submission {
    address submitter;
    SubmissionType sType;
    uint256 submittedAt;
    uint256[] publicInput;
  }
  // maps proofHash to Submission
  mapping(bytes32 => Submission) public submissions;

  enum State {Invalid, Committed, Spent}
  // maps note to State
  mapping(bytes32 => State) public notes;

  event NoteStateChange(bytes32 note, State state);
  event Submitted(address submitter, bytes32 proofHash);
  event Challenged(address indexed challenger, bytes32 proofHash);

  /**
  * @dev Calculates the keccak256 of the zkSnark parameters
  * @return proofHash
  */
  function getProofHash(
      uint256[2] a,
      uint256[2] a_p,
      uint256[2][2] b,
      uint256[2] b_p,
      uint256[2] c,
      uint256[2] c_p,
      uint256[2] h,
      uint256[2] k)
    internal
    pure
    returns(bytes32 proofHash)
  {
      proofHash = keccak256(abi.encodePacked(a, a_p, b, b_p, c, c_p, h, k));
  }
  
  /**
  * @dev Concatenates the 2 chunks of the sha256 hash of the note
  * @notice This method is required due to the field limitations imposed by the zokrates zkSnark library
  * @param _a Most significant 128 bits of the note hash
  * @param _b Least significant 128 bits of the note hash
  */
  function calcNoteHash(uint _a, uint _b)
    internal
    pure
    returns(bytes32 note)
  {
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
    returns (bytes32 out)
  {
      for (uint i = 0; i < 32; i++) {
        out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
      }
  }
}