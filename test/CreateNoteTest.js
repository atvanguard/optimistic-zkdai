const ZkDai = artifacts.require("ZkDai");
const fs = require('fs');
const BN = require('bn.js');
const crypto = require('crypto');

contract('createNote', function(accounts) {
  it.only('challenge fails for correct proof', async function() {
    let instance = await ZkDai.deployed();
    const proof = parseProof('./test/createNoteProof.json');

    // console.log('calling verifyTx with proof', proof);
    const submit = await instance.submitNewNote(...proof, {value: 10**18});
    // console.dir(submit, {depth: null})

    const note = submit.logs[1].args.note;
    console.log('note', note)
    const challenge = await instance.challenge(note, ...proof);
    console.dir(challenge, {depth: null})
  })

  it('challenge passes for incorrect proof', async function() {
    let instance = await ZkDai.deployed();
    const proof = parseProof('./test/createNoteProof.json');
    const zkpHigherValue = parseProof('./test/createNoteProof_invalid.json');

    // try sending in a note hash of higher value (invalid proof)
    proof[0] = zkpHigherValue[0]
    const submit = await instance.submitNewNote(...proof, {value: 10**18});
    console.dir(submit, {depth: null})

    const note = submit.logs[1].args.note;
    const challenge = await instance.challenge(note, ...proof, {from: accounts[1]});
    console.dir(challenge, {depth: null})
  })
})

const rx2 = /([0-9]+)[,]/gm
function parseProof(file) {
  let proofJson = fs.readFileSync(file, 'utf8');
  proofJson.match(rx2).forEach(p => {
    proofJson = proofJson.replace(p, `"${p.slice(0, p.length-1)}",`)
  })
  proofJson = JSON.parse(proofJson);

  const proof = proofJson.proof;
  const input = proofJson.input;
  input.forEach((i, key) => {
    if (typeof i == 'number') i = i.toString();
    input[key] = '0x' + new BN(i, 10).toString('hex')
  })

  const _proof = [];
  Object.keys(proof).forEach(key => _proof.push(proof[key]));
  _proof.push(input);
  return _proof;
}