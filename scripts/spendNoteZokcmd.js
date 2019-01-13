
const crypto = require('crypto');
const BN = require('bn.js');

const SCALING_FACTOR = new BN('1000000000000000000');

function getNoteHash(encodedNote) {
  const buf = Buffer.from(encodedNote, 'hex');
  const digest = crypto.createHash('sha256').update(buf).digest('hex');
  // console.log('digest', digest)
  // split into 128 bits each
  return [digest.slice(0, 32), digest.slice(32)]
}

function printZokratesCommand(params) {
  console.log(params)
  let cmd = '../../zokrates compute-witness -a '
  params.forEach(p => {
    cmd += `${new BN(p, 16).toString(10)} `
  })
  console.log(cmd);
}

function getNoteParams(_key, _val, _nonce) {
  let key = new BN(_key, 16).toString(16); // 32 bytes = 256 bits
  let val = new BN(_val, 16).mul(SCALING_FACTOR).toString(16, 32); // 16 bytes = 128 bits
  let nonce = new BN(_nonce, 16).toString(16, 32);
  return getNoteHash(key + val + nonce).concat([key.slice(0, 32), key.slice(32), val, nonce])
}

function getCreateNoteParams(_sender, _value, _nonce, _receiver, _val, _n0, _n1) {
  let oldNote = getNoteParams(_sender, _value, _nonce);
  let newNote0 = getNoteParams(_receiver, _val, _n0);
  let newNote1 = getNoteParams(_sender, new BN(_value, 16).sub(new BN(_val, 16)).toString(16), _n1); // leftover change
  printZokratesCommand(oldNote.concat(newNote0).concat(newNote1));
}

getCreateNoteParams(
  '1aba488300a9d7297a315d127837be4219107c62c61966ecdf7a75431d75cc61', // private key,
  '5', // value
  'c517f646255d5492089b881965cbd3da', // nonce
  '66e56aa2896ef489e42fdf1d8059a1359bd6b6d67c83c69d7dc2ed726778de85',
  '3',
  'dbff5193726b02ada8c9bc3a44279764', // n0
  'd5ecba971f082d08e1f3024f4f908d4c' // n0
)

// console.log(new BN('5', 16).sub(new BN('3', 16)).toString(16))


