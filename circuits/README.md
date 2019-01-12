```shell
C(outputNote, v, pk, n) { // outputNote and v are the public inputs
    outputNote == H(pk, v, n)
    return 1
}
```
outputNote: bytes32
v: bytes16
pk: bytes32 // compressed ethereum public key, 1st byte sliced
nonce: bytes16

