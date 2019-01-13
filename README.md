# optimistic-zkdai


- The zkdai components are based on the latest [spec](https://docs.google.com/document/d/1z3ZRLLD-wvgERe_KO5VhqxEJDqiBd3xxfLO1pYk7Z0k/edit?usp=sharing).
- Learn about the ingredients behind ZkDai from [ZkDai — Private DAI transactions on Ethereum using Zk-SNARKs](https://medium.com/@atvanguard/zkdai-private-dai-transactions-on-ethereum-using-zk-snarks-9e3ef4676e22).
- The _optimistic_ nature of the contracts is inspired from [Optimistic Contracts](https://medium.com/@decanus/optimistic-contracts-fb75efa7ca84).

### Lifecycle of a zkdai note
- To mint a zkdai note worth x Dai, `dai.approve` the zkdai contract to move `x` tokens.
- Generate a zkSnark (using zokrates) with appropriate params. See [mintNoteZokcmd.js](scripts/mintNoteZokcmd.js).
- Send a transaction calling `zkdai.mint` with the proof and send along the required stake. The contract will transfer `x` Dai tokens from user to itself and save the hash of the proof on-chain. The hash will be saved on-chain **instead** of the entire proof to save gas. **The note is not yet committed.**
- Before the challenge period ends, a watchful verifier can challenge the proof if the verifier notices that an invalid zkSnark was submitted. This would entail reading the submitted proof from the transaction above and sending it to `zkdai.challenge`. The challenged proof will then be verified. If the the challenge passes, the submitter's stake would be slashed and transferred to the the challenger; if the challenge fails, the zkdai note will be committed and the stake will be returned to the proof submitter.
- Alternatively, if the proof remained unchallenged during the challenge period, the submitter can **commit** the note by calling `zkdai.commit`.
- Similarly, to _spend_ a zkdai note, the user would need to generate and submit the zkSnark proof to `zkdai.spend`. See [spendNoteZokcmd.js](scripts/spendNoteZokcmd.js). The challenge and commit phases will follow the same mechanism as above.
- At any point, the user can choose to _liquidate_ a zkdai note. The user submits the zkSnark. The contract verifies the proof, marks the note as `Spent` and transfers the equivalent amount of Dai to the specified recepient.

### Tests
```shell
npm test
```

### Development
#### zokrates
Run container
```shell
git clone git@github.com:Zokrates/ZoKrates.git
cd ZoKrates
docker build -t zokrates .
docker run --name zokrates -ti zokrates /bin/bash
```

Setup circuit and export solidity verifier
```shell
docker cp circuits/createNote.code zokrates:/home/zokrates/

(in container)
./zokrates compile -i createNote.code
./zokrates setup
./zokrates export-verifier

docker cp zokrates:/home/zokrates/verifier.sol contracts/verifiers/MintNoteVerifier.sol
```

Generate witness and proof
```shell
node scripts/mintNoteZokcmd.js

(in container)
Paste the command printed above in zokrates container (computes witness)
./zokrates generate-proof

docker cp zokrates:/home/zokrates/proof.json test/mintNoteProof.json
```