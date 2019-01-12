const ZkDai = artifacts.require("ZkDai.sol");
const MockDai = artifacts.require("MockDai.sol");
// const CreateNoteVerifier = artifacts.require("CreateNoteVerifier.sol");

module.exports = async function(deployer) {
  // await deployer.link(IterableMapping, User);
  // await deployer.deploy(MockDai);
  // return  deployer.deploy(ZkDai, 10000, 10**18, MockDai.address);
  return  deployer.deploy(ZkDai, 10000, 10**18, 0x0);
};
