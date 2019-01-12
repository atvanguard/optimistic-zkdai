// This file is LGPL3 Licensed

pragma solidity ^0.4.19;

import "./VerifierBase.sol";

contract Verifier is VerifierBase {
    function verifyingKey() pure internal returns (VerifyingKey vk) {
        vk.A = Pairing.G2Point([0x193a25522e4666a16dfb4f7285a05b1642818245d89273aed37fc0554a199290, 0xc747f047f62d5d6037b1a1373f56deaee0323ce06208821425b3950e62affc8], [0xdf86086ba0df055cbe87617880d4a80db90bf75f2253e6e7a900b595702fb2, 0xf1d114525dac6628347abe1b2fa7032f53bf977615c38c3c985562b78d75bb4]);
        vk.B = Pairing.G1Point(0xa49150c2f12e4475359561b161a1b14230e2fb46972bd5ce8aa06b195eede98, 0x25bd56a0be2ecb00e5a836baa8fff578a26bf062db3f4cd5ef436ed7a4a113ae);
        vk.C = Pairing.G2Point([0x13b3172fc045b8808d759a1c1262f1e5be7b9114326ef5cc56336e14653a51c, 0x28e424f2815a6cc35ce44b50d00d1805d450728eb4853ca9910a49476ea4f90a], [0x2dd6b3e21c4a3d1a4319ce32b0e2f09e180b7b014dfd4a67eae878d030163669, 0x20139f0c751eaba04c14ab26730df9aff3068994d91b0a3fe2dfcfb55154baef]);
        vk.gamma = Pairing.G2Point([0x828f19db4539148a4f07947163b0242dd72f25e06eb8ad2cbc9fa488b1bfe1e, 0x4a9df99d198fa8634a3572d31eadce16c31c351f0882c887ed789df7372f9b9], [0x2387511b0115f67ede26df960f030e19af91ebba65943237490600102360c621, 0xe28b84fab39670d72afddeb6589626f467bf60f95a58d7d863bb94b95fc34db]);
        vk.gammaBeta1 = Pairing.G1Point(0x3005e6f3679f159494fb97e1117677a30335ef2efdd612f9cac9cb70eb308617, 0x22b2956b603e3a01a0e16e5cfa6376e51025c8be0e1cd7885a78790a015c179);
        vk.gammaBeta2 = Pairing.G2Point([0x24a7beec4d2fc40ac83f55ab12f7f4f76436dbef426bc85f5cce1ca733c548da, 0xc5222c60db498ea696eef14a7afd245a4266a0b9e5c58368052192e92340bd8], [0x24c34a907ad6e4338f1136a1e68ee27f8241983f6ed23cf1601084909f98537b, 0xb281f97055eb9073355a79ff4ecf11ce75a1b6952a8c9cb2820e7fe538326a]);
        vk.Z = Pairing.G2Point([0x16799ce641d3812bd353a07616f7b1669a1e6f6981374b4e48243e2d58c2340c, 0x1ff97c5647e0c07539e94d1d10b9bfea56d70870df3661a21eae16e43190f2d1], [0x6657a58e2024c46b4a45741bfae02ef5530e23c8b10ce143d409dcf6141eb79, 0x2bf27f97fcfcd69ff82a2e6bf38342a76507eb9db5a0e1aa8cdd3f4ace00400]);
        vk.IC = new Pairing.G1Point[](8);
        vk.IC[0] = Pairing.G1Point(0x2b9960329508e6e5be855233284583c2d4212906d5bbbcc59f8ffe8d9e69143f, 0x2735f9eae5e6190b1472873b3458c8dd284eef5598c6306085f0d4a3ae84bd18);
        vk.IC[1] = Pairing.G1Point(0xecc849f6cdd7ffd2f2563b790fa9d4c54758ef4b17d8ce1e2aae6682339427d, 0x2c82f03ab227d00cafb5091baecad656a7a40b93aa3fbb137be2dea4e157d7da);
        vk.IC[2] = Pairing.G1Point(0x287b1036cf4de356434e7a2f62a12e81aac6958d7de494b8e4e253fb27a61f1c, 0x226ca75f070a9050bb5c0881e1ef9830f16ea1b13e7eec1c552acc37c31dfd8);
        vk.IC[3] = Pairing.G1Point(0x1dc9dd2854149a43e69e418cbe0d0e0de476b4320b7b1ab96fc360bc031ab3e, 0x3b554217dd514082cc350964706b86267281d2ec542749b87a68be2576d4a2f);
        vk.IC[4] = Pairing.G1Point(0x2b0c9de8769907551420b2ae76345e629acf8442536a75d0f11b770c803b6f7b, 0x1f1461d83a03ff3080cce0e10afbe5a23b8b6cd8a64cc93f1c851f1f83a6d287);
        vk.IC[5] = Pairing.G1Point(0x275b1b0e9f08a785c70518fe32f9b0aa113f98b739b43221e8be76e67f4106c3, 0x2315efbfd8b12606ef096e3777b7a08d56bec6ec66285d94ec3fc23d32ba77);
        vk.IC[6] = Pairing.G1Point(0xd9c28df7c3490fb38c875f57dba43f0f9ca42ff5b37cd21f5ed7670abbf92b6, 0x1417e85eb61c94e33bcfc3de4ad77bd94f4c0766550000cb0753833543f534af);
        vk.IC[7] = Pairing.G1Point(0x101b79a69c007e945b2273f09b9250406a01ba20b2fff42d39a06a5dccf00f63, 0x209d7dca4d5fa97f3c19fe74018c2efd908c303f3e189c8ff3e1f307b1c2bda8);
    }
    function verify(uint[] input, Proof proof) internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
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
    function verifyTx(
            uint[2] a,
            uint[2] a_p,
            uint[2][2] b,
            uint[2] b_p,
            uint[2] c,
            uint[2] c_p,
            uint[2] h,
            uint[2] k,
            uint[7] input
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
        if (verify(inputValues, proof) == 0) {
            emit Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}
