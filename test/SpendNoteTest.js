const ZkDai = artifacts.require("TestZkDai");
const MockDai = artifacts.require("MockDai");
const util = require('./util')

const SCALING_FACTOR = 10**18;

contract('SpendNote', function(accounts) {
  let dai, zkdai;

  // Initial setup
  before(async () => {
    dai = await MockDai.new();
  })

  beforeEach(async () => {
    zkdai = await ZkDai.new(0, 10**18, dai.address);
    // populate the contract with a valid note
    const proof = util.parseProof('./test/mintNoteProof.json');
    await dai.approve(zkdai.address, 5 * SCALING_FACTOR);
    const mint = await zkdai.mint(...proof, {value: 10**18});
    const proofHash = mint.logs[0].args.proofHash;
    await util.sleep(1); // wait out the cooldown period
    await zkdai.commit(proofHash);
  })

  it('spend', async function() {
    const spendProof = util.parseProof('./test/spendNoteProof.json');
    const spend = await zkdai.spend(...spendProof, {value: 10**18});
    assertEvent(spend.logs[0], 'Submitted', accounts[0], '0x610aa7aab595bcefc8d10d9039d1f24c1c771bb09d253b268ac43e42545b4a36')
  })

  it('challenge fails if valid proof was submitted', async function() {
    const spendProof = util.parseProof('./test/spendNoteProof.json');
    await zkdai.spend(...spendProof, {value: 10**18});
    
    await zkdai.setCooldown(10); // larger cooldown, otherwise challenge period ends

    const params = spendProof.slice(0, spendProof.length - 1); // cut public params
    const challenge = await zkdai.challenge(...params);
    assert.equal(challenge.logs[1].event, 'NoteStateChange')
    // @todo assert on challenge.logs[1].args.note
    assert.equal(challenge.logs[1].args.state, 2 /* spent */)

    assert.equal(challenge.logs[2].event, 'NoteStateChange')
    // @todo assert on challenge.logs[2].args.note
    assert.equal(challenge.logs[2].args.state, 1 /* committed */)

    assert.equal(challenge.logs[3].event, 'NoteStateChange')
    // @todo assert on challenge.logs[3].args.note
    assert.equal(challenge.logs[3].args.state, 1 /* committed */)
  })

  it('challenge passes if invalid proof was submitted', async function() {
    const spendProof = util.parseProof('./test/spendNoteProof.json');

    // introduce invalid-ness to the proof
    spendProof[spendProof.length - 1][2] = spendProof[spendProof.length - 1][4];
    spendProof[spendProof.length - 1][3] = spendProof[spendProof.length - 1][5];
    const spend = await zkdai.spend(...spendProof, {value: 10**18});
    const proofHash = spend.logs[0].args.proofHash;
    
    await zkdai.setCooldown(10); // larger cooldown, otherwise challenge period ends

    const params = spendProof.slice(0, spendProof.length - 1); // cut public params
    const challenge = await zkdai.challenge(...params);
    assert.equal(challenge.logs[0].event, 'Challenged')
    assert.equal(challenge.logs[0].args.challenger, accounts[0]);
    assert.equal(challenge.logs[0].args.proofHash, proofHash);
  })
})

function assertEvent(event, type, ...args) {
  assert.equal(event.event, type);
  args.forEach((arg, i) => {
    assert.equal(event.args[i], arg);
  })
}