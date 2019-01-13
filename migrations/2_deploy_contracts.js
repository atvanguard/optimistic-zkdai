const ZkDai = artifacts.require("TestZkDai.sol");
const MockDai = artifacts.require("MockDai.sol");

module.exports = async function(deployer) {
  await deployer.deploy(MockDai);
  return  deployer.deploy(ZkDai, 10000, 10**18, MockDai.address);
};