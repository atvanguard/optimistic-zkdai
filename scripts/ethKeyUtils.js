const eccrypto = require("eccrypto");
const crypto = require("crypto");
const secp256k1 = require('secp256k1')
const BN = require('bn.js');
function privateToPublicCompressed(privKey) {
  return secp256k1.publicKeyCreate(privKey, true /* compress */);
}

function decompressPublicKey(pubKey) {
  return secp256k1.publicKeyConvert(pubKey, false /* compress */);
}

var privateKey = crypto.randomBytes(32);
var pubKeyCompressed = privateToPublicCompressed(privateKey);
console.log('pubKeyCompressed', pubKeyCompressed.toString('hex'))
console.log('decompressPublicKey', decompressPublicKey(pubKeyCompressed).toString('hex'))

console.log('pubKey', eccrypto.getPublic(privateKey).toString('hex'));


// 03938497172bd3c6706a066b77fb7f877910349af36d93e91978c80a69c1241316
// 0292608ccab8c0d4e7cdc1ce6e4dd962c8a3d95e88e6e83028006125696101d633