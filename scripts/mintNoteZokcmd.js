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

function getCreateNoteParams(_pubKey, _value, _nonce) {
  console.log(arguments)
  let pubKey = new BN(_pubKey, 16).toString(16); // 32 bytes = 256 bits
  let value = new BN(_value, 16).mul(SCALING_FACTOR).toString(16, 32); // 16 bytes = 128 bits
  let nonce = new BN(_nonce, 16).toString(16, 32); // 16 bytes = 128 bits
  let privateParams = [pubKey.slice(0, 32), pubKey.slice(32), nonce];

  let note = pubKey + value + nonce;
  console.log('note', note);

  let publicParams = getNoteHash(note).concat(value);
  printZokratesCommand(publicParams.concat(privateParams));
}

// this will serve as an invalid proof
getCreateNoteParams(
  '1aba488300a9d7297a315d127837be4219107c62c61966ecdf7a75431d75cc61', // private key,
  '6', // value
  'c517f646255d5492089b881965cbd3da' // nonce
)

// getCreateNoteParams(
//   '1aba488300a9d7297a315d127837be4219107c62c61966ecdf7a75431d75cc61', // private key,
//   '5', // value
//   'c517f646255d5492089b881965cbd3da' // nonce
// )

