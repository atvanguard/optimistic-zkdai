// This file is LGPL3 Licensed

pragma solidity ^0.4.19;
import "./VerifierBase.sol";

contract Verifier is VerifierBase {
    function mintVerifyingKey() pure internal returns (VerifyingKey vk) {
        vk.A = Pairing.G2Point([0xaf94d88c7ee3eb1857133f16145b2dd5228c42e0af215051e24cb01f8342079, 0xc0cbe78d972a093330d724c10b8b306f770504f55539007c3c5c57ca54ea183], [0x16e36fd792fc512c6249ca78f1f3655bd41c4a5d1e45fa07a904a62d5c6f234d, 0x2c73ecd86ceb47cb3c79cb5f8fe32deeda3e64f14033c8c9b83338573f23e2cb]);
        vk.B = Pairing.G1Point(0x27c8ca5a92af01438d067f210c70a9eeaf4f48a0fa30c96df8326e3382924aaa, 0x5ebb7076a7244dde6073ac46e3c15d6a8a60cac5ae3d499f7c62ce5065d858b);
        vk.C = Pairing.G2Point([0xb963075039c22ffea35656e5c659cc3fa1afce2e21141ea0b16493d15e5a356, 0xa61377289f3ab18cf62e4707b595696891921f8a385933079d6dffd18962169], [0x16b6c4b3426c81ce680956b2e68e6fdccacd967f38197098d4af176f535d69dd, 0x1ea176a578d2f362a9855477455d46386bd18f0d3eb0b6214635ce0a3631274e]);
        vk.gamma = Pairing.G2Point([0x1bb9cfd82096924786237d0d8ddfd507bf11eebb32dfb3979cbc156c0d02422, 0x5b89ef7c258edd6cccad0fa63e288eda13b1169fafee259c0658d16ba965ca3], [0x2a9fe49c226c6ba0df879801d214a577af2ddd00860bbbdd2b7db98237fb1789, 0x152686da1a0354b91d96eb5823e1f6fd61fad84b80ad7d80cf3360813a4097f6]);
        vk.gammaBeta1 = Pairing.G1Point(0x1f70ca1ba953f1bec281de62a53c300d104e31ff603f05c5e69b9f5a8a51bd9, 0x2206d105a7c7026c14ef0957a9e030201c66c943ba98a52b2e1ceed5e75c53a6);
        vk.gammaBeta2 = Pairing.G2Point([0x1fe8cbca6e6ebee38e5d5280f6271a7dcf17e511cb654a51fd1495d87276e501, 0x2a724194816289b9b6cfe91b25f1105f3e1a961b734b38292c1f2a51398a6922], [0x1c9cdba476c5dafc57988549a960061c705c1913f07b78ab55a8c6e18b68ad45, 0x219678f0f0356b98090bcec286371c4e73dcd087c61339bab1fb670cf779da90]);
        vk.Z = Pairing.G2Point([0x19a4673bcce496c99d989bd99d28a721b02709710202379e0d215b80025595cb, 0xdee840b715a5c15b89bb4c12c3e28252c9234712fc537c0c5b5418d7805367], [0xe1e388405dd9abe144af08b1b741065e912aa10f2abe809d72105b0f4c1ef97, 0x12bbed62bb8a7127bf9fc77128cf156bac2cd715ebff0a444fbccc90230ae045]);
        vk.IC = new Pairing.G1Point[](5);
        vk.IC[0] = Pairing.G1Point(0xf6fb6347b415ad44d22845aae96908a083a0802713ce6dfea1a1189d9232ddb, 0x1fbb2a9837baf535f54f5bd3f760f0c8efcb4e9d21281ba1f247cdd13224f326);
        vk.IC[1] = Pairing.G1Point(0x1c08edc8ce0a0277d05f83fed33e67b548ca568da6b746c7c68311f082e36e98, 0x10e7c0e9cca8d2a7a0f4134f67fdad4d3de46b785834711f90ba3e1aebd83cff);
        vk.IC[2] = Pairing.G1Point(0x30235ea402a4b8fa7a14a2c56daa65228cfe04a0abe7ff3da7c0fcaffa4bd6fd, 0x15f07c5dd25f2d8bbacc624425bdfd559e3aee7b72fe7ce014b439664036ff86);
        vk.IC[3] = Pairing.G1Point(0x1fbe62533414b2acbda5d9db6d5f7934168e28c4ea28c63372bd9159fed3e931, 0x1d60419c1593e2f26fd4d39d35e6aa73c827fd9bbbc5b60f8c6db39df8bfd99c);
        vk.IC[4] = Pairing.G1Point(0x488e5e37b4d04e4cb2c34764dabd34c920d79a5f732b317adbfbb9ae56c25ca, 0x70016aaef023cb4c440232363ecf50f009d07c6e2b15eea57318236daaa17b);
    }
    event YOYO(string where);
    function mintVerify(uint[] input, Proof proof) internal returns (uint) {
        // emit YOYO('in mvn');
        VerifyingKey memory vk = mintVerifyingKey();
        require(input.length + 1 == vk.IC.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd2(proof.A, vk.A, Pairing.negate(proof.A_p), Pairing.P2())) return 1;
        if (!Pairing.pairingProd2(vk.B, proof.B, Pairing.negate(proof.B_p), Pairing.P2())) return 2;
        if (!Pairing.pairingProd2(proof.C, vk.C, Pairing.negate(proof.C_p), Pairing.P2())) return 3;
        if (!Pairing.pairingProd3(
            proof.K, vk.gamma,
            Pairing.negate(Pairing.addition(vk_x, Pairing.addition(proof.A, proof.C))), vk.gammaBeta2,
            Pairing.negate(vk.gammaBeta1), proof.B
        )) return 4;
        if (!Pairing.pairingProd3(
                Pairing.addition(vk_x, proof.A), proof.B,
                Pairing.negate(proof.H), vk.Z,
                Pairing.negate(proof.C), Pairing.P2()
        )) return 5;
        return 0;
    }
    event Verified(string s);
    function mintVerifyTx(
            uint[2] a,
            uint[2] a_p,
            uint[2][2] b,
            uint[2] b_p,
            uint[2] c,
            uint[2] c_p,
            uint[2] h,
            uint[2] k,
            uint[4] input
        ) public returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.A_p = Pairing.G1Point(a_p[0], a_p[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.B_p = Pairing.G1Point(b_p[0], b_p[1]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        proof.C_p = Pairing.G1Point(c_p[0], c_p[1]);
        proof.H = Pairing.G1Point(h[0], h[1]);
        proof.K = Pairing.G1Point(k[0], k[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (mintVerify(inputValues, proof) == 0) {
            emit Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}
