const ZkDai = artifacts.require("TestZkDai");
const MockDai = artifacts.require("MockDai");
const util = require('./util')

const SCALING_FACTOR = 10**18;

contract('LiquidateNote', function(accounts) {
  let dai, zkdai;

  // Initial setup
  before(async () => {
    dai = await MockDai.new();
  })

  beforeEach(async () => {
    zkdai = await ZkDai.new(0, 10**18, dai.address);
  })

  it('transfers dai when note is liquidated', async function() {
    // check dai balance and approve the zkdai contract to be able to move tokens
    assert.equal(await dai.balanceOf.call(accounts[0]), 100 * SCALING_FACTOR, '100 dai tokens were not assigned to the 1st account');
    assert.equal(await dai.balanceOf.call(zkdai.address), 0, 'Zkdai contract should have 0 dai tokens');
    assert.equal(await dai.balanceOf.call(accounts[0]), 100 * SCALING_FACTOR, 'user should have 100 dai tokens');
    await dai.approve(zkdai.address, 5 * SCALING_FACTOR);
    
    const proof = util.parseProof('./test/mintNoteProof.json');
    // the zk proof corresponds to a secret note of value 5
    const mint = await zkdai.mint(...proof, {value: 10**18});
    const proofHash = mint.logs[0].args.proofHash;
    assert.equal(await dai.balanceOf.call(zkdai.address), 5 * SCALING_FACTOR, 'Zkdai contract should have 5 dai tokens');
    assert.equal(await dai.balanceOf.call(accounts[0]), 95 * SCALING_FACTOR, 'user should have 95 dai');
    await util.sleep(1);
    await zkdai.commit(proofHash);

    const liquidate = await zkdai.liquidate(accounts[1], ...proof, {value: 10**18}); // liquidate to 2nd account
    const liquidateProofHash = liquidate.logs[0].args.proofHash;
    await util.sleep(1);
    const commit = await zkdai.commit(liquidateProofHash);

    assert.equal(await dai.balanceOf.call(zkdai.address), 0, 'Zkdai contract should have 0 dai tokens');
    assert.equal(await dai.balanceOf.call(accounts[1]), 5 * SCALING_FACTOR, 'user should have 5 dai');
    assert.equal(commit.logs[0].event, 'NoteStateChange')
    assert.equal(commit.logs[0].args.state, 2 /* Spent */)
  })

  it('challenge fails for correct proof', async function() {
    await dai.approve(zkdai.address, 5 * SCALING_FACTOR);
    
    const proof = util.parseProof('./test/mintNoteProof.json');
    // the zk proof corresponds to a secret note of value 5
    const mint = await zkdai.mint(...proof, {value: 10**18});
    const proofHash = mint.logs[0].args.proofHash;
    await util.sleep(1);
    await zkdai.commit(proofHash);

    const to = accounts[1];
    await zkdai.liquidate(to, ...proof, {value: 10**18}); // liquidate to 2nd account

    await zkdai.setCooldown(10); // larger cooldown, otherwise challenge period ends

    const params = proof.slice(0, proof.length - 1); // cut public params
    const challenge = await zkdai.challenge(...params);
    assert.equal(challenge.logs[1].event, 'NoteStateChange');
    assert.equal(challenge.logs[1].args.state, 2 /* spent */);
  })

  it('challenge passes if invalid proof was submitted', async function() {
    await dai.approve(zkdai.address, 5 * SCALING_FACTOR);
    
    const proof = util.parseProof('./test/mintNoteProof.json');
    const zkpHigherValue = util.parseProof('./test/mintNoteProof_invalid.json');
    // try sending in a note hash of higher value (invalid proof)
    proof[0] = zkpHigherValue[0]

    const mint = await zkdai.mint(...proof, {value: 10**18});
    const proofHash = mint.logs[0].args.proofHash;
    await util.sleep(1);
    await zkdai.commit(proofHash);
    await zkdai.liquidate(accounts[1], ...proof, {value: 10**18}); // liquidate to 2nd account

    await zkdai.setCooldown(10); // larger cooldown, otherwise challenge period ends

    const params = proof.slice(0, proof.length - 1); // cut public params
    const challenge = await zkdai.challenge(...params);
    assert.equal(challenge.logs[0].event, 'Challenged');
  })
})