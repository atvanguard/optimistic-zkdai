const ZkDai = artifacts.require("ZkDai");
const MockDai = artifacts.require("MockDai");
const util = require('./util')

const SCALING_FACTOR = 10**18;

contract('mintNote', function(accounts) {
  let dai, zkdai;

  // Initial setup
  before(async () => {
    dai = await MockDai.new();
  })

  beforeEach(async () => {
    zkdai = await ZkDai.new(100, 10**18, dai.address);
  })

  it('transfers dai and mints note', async function() {
    // check dai balance and approve the zkdai contract to be able to move tokens
    assert.equal(await dai.balanceOf.call(accounts[0]), 100 * SCALING_FACTOR, '100 dai tokens were not assigned to the 1st account');
    assert.equal(await dai.balanceOf.call(zkdai.address), 0, 'Zkdai contract should have 0 dai tokens');
    await dai.approve(zkdai.address, 5 * SCALING_FACTOR);
    
    const proof = util.parseProof('./test/mintNoteProof.json');
    // the zk proof corresponds to a secret note of value 5
    const mint = await zkdai.mint(...proof, {value: 10**18});
    assert.equal(await dai.balanceOf.call(zkdai.address), 5 * SCALING_FACTOR, 'Zkdai contract should have 5 dai tokens');
    assertEvent(mint.logs[0], 'Submitted', accounts[0], '0x02d554cdd75e795e9e3547843a66321a5ba4ab21c3cb141197b194f410ede8dc')
  })

  it('challenge fails for correct proof', async function() {
    const proof = util.parseProof('./test/mintNoteProof.json');
    await dai.approve(zkdai.address, 5 * SCALING_FACTOR);
    await zkdai.mint(...proof, {value: 10**18});

    const params = proof.slice(0, proof.length - 1);
    const challenge = await zkdai.challenge(...params); // omit sending public params again
    assert.equal(challenge.logs[1].event, 'NoteStateChange')
    // @todo assert on challenge.logs[1].args.note
    assert.equal(challenge.logs[1].args.state, 1 /* committed */)
  })

  it('challenge passes for incorrect proof', async function() {
    const proof = util.parseProof('./test/mintNoteProof.json');
    const zkpHigherValue = util.parseProof('./test/mintNoteProof_invalid.json');
    await dai.approve(zkdai.address, 5 * SCALING_FACTOR);
    
    // try sending in a note hash of higher value (invalid proof)
    proof[0] = zkpHigherValue[0]
    const mint = await zkdai.mint(...proof, {value: 10**18});
    const proofHash = mint.logs[0].args.proofHash;

    const params = proof.slice(0, proof.length - 1);
    const challenge = await zkdai.challenge(...params); // omit sending public params again
    assert.equal(challenge.logs[0].event, 'Challenged')
    assert.equal(challenge.logs[0].args.challenger, accounts[0]);
    assert.equal(challenge.logs[0].args.proofHash, proofHash)
  })

  it('commit', async function() {
    zkdai = await ZkDai.new(0 /* low cooldown */, 10**18, dai.address);
    const proof = util.parseProof('./test/mintNoteProof.json');
    await dai.approve(zkdai.address, 5 * SCALING_FACTOR);
    const mint = await zkdai.mint(...proof, {value: 10**18});
    const proofHash = mint.logs[0].args.proofHash;

    await util.sleep(1);
    const commit = await zkdai.commit(proofHash);
    assert.equal(commit.logs[0].event, 'NoteStateChange')
    assert.equal(commit.logs[0].args.state, 1 /* committed */)
  })

  it('can not be challenged after cooldown period');
  it('can not be committed before cooldown period');
})

function assertEvent(event, type, ...args) {
  assert.equal(event.event, type);
  args.forEach((arg, i) => {
    assert.equal(event.args[i], arg);
  })
}