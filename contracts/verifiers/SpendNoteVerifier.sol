// This file is LGPL3 Licensed

pragma solidity ^0.4.19;

import "./VerifierBase.sol";

contract Verifier is VerifierBase {
    function spendVerifyingKey() pure internal returns (VerifyingKey vk) {
        vk.A = Pairing.G2Point([0x1d327faabdcd313ce900784b699c21e0da5e2ee8aaae83d6f2e8f58636c58b0d, 0x1d06abbdcd6a955e27f870f2dfdcb43083b8279bc97ac195c67611b73ebd5cc9], [0x1b1446473f546ce67f05a7eb5a3dc0fd8ce0f88971b28747bf16f9f737f5536b, 0xc257b632200996963e8e83c79c1bcb5d84cf69fa0a47005534d00d60f61168]);
        vk.B = Pairing.G1Point(0x1a3665752eb49b25e9f8abadc235a9bea71d332fd5312ce5342d14af4c3577a3, 0x13b71a21e73d1c760f1710873ba2a3440aee02b6c4d32b58fd946ceadcbe5fa6);
        vk.C = Pairing.G2Point([0x2222f41641671aa081a7df8bc91f9e3be63c5697f40ca33b601d2acab2f649f0, 0xb55b6bafc206a93a7b46309845d14c0d053ee5837d71c82be707189fdb78c0b], [0x125eb167f3816c1873a694c2acf0b67b436432ffea56a913a9e125816026d347, 0x186e1473e2bf76fa585186bbde05bd16df21f03714be842014c01b2ecee3f1f7]);
        vk.gamma = Pairing.G2Point([0x213766f7f4bf1198f7f5197a81c1371b07f1bc57a1647b42597240402d4dacd1, 0x2499b12ed3aaf5baade056520e6298fee158bc34dd86919f9037e77d200c9731], [0x877f21e236bf55596b749344576acd69bc60e9cdb2ca9013166c1c53edffdde, 0x22dd67ab1f5ae12276f77ff217f7f6685bd0d1eeb9341c61ed6a74852b0da30f]);
        vk.gammaBeta1 = Pairing.G1Point(0xbd84df5385315c50baeb0fbe618f0c8fe3e7533bd7e821e4b27cf80cd4e1c4b, 0x2e5a1b96761756ce00e7dd12c00182ea7f6d0053d325436b02e33637b1536559);
        vk.gammaBeta2 = Pairing.G2Point([0x473534d2ab3acafeca3522840974d26907ddb6042b8456621d2cf0d83e9e380, 0x219b27d0cc22ca95c926aaef371770ab75a1ef23c8cbef9e5a6d122c434bee36], [0x77a0276ec1d989c8ee0544ec45990939038124c44fb2793a4ad6450d8b8241a, 0xdeb25c3186fa1c85eb0b5723bedc0141c19da5f0fce502fcf67168c7855d484]);
        vk.Z = Pairing.G2Point([0x1056dbb43341a48d8d493689acf126db31a3c43d03af61f1299ce37444c7a721, 0x10cfb02c08cf8ab1d777144cdb646c9887443b1407e1e9c8d03776028dfb2f32], [0xead282c2ca66a7da11d8cbf5ec9fb2cd6ab3d561fe7e1179b277c6f6949af9d, 0x245d9f8563e953fde6f6fcf04d1feb4ed56c4cfc7e5b4d518fb600f01d7eeb4a]);
        vk.IC = new Pairing.G1Point[](8);
        vk.IC[0] = Pairing.G1Point(0x4c9e1c86df8d7025915b272e80115cb849bb8830accad74a552e88dae3c541, 0xbaf69752fbe8343a7c664163ebdf059f56c243203c9bc802284e44a32ffc65c);
        vk.IC[1] = Pairing.G1Point(0x2530fe43b58bb0999262d8ce58267c40dfc9eaf9dad547bd3150b88f70b0055b, 0x2aa6102a05063ee9da8403db97c1f99fd92caf0d48d3b166fc865137127b9f5);
        vk.IC[2] = Pairing.G1Point(0x1be737529ca3705423c6bbb77eb4e233f70936b8e6673ad0e6c8165beb36d19b, 0xf1651b918ef1c54b8bcd5a8e92bb8395b0f66d4dc409ca3bfa8d11ee6d82271);
        vk.IC[3] = Pairing.G1Point(0x18043a36b821c0e040c88a5e9fb3029e6d7a519aea746d968a7908ed8458b1b6, 0x24e104fad79c1563131a267eb712156f49b02c157e2088f4a689a66e3ac14a83);
        vk.IC[4] = Pairing.G1Point(0x7527ae1e14468dedb48c28711a29c07a1033fe971ec6786dec2e860a319d2d8, 0x1481109cea7d2c5da562a6ba7284a0d9c8bb5b3294e8b5cfa64dd7c988707257);
        vk.IC[5] = Pairing.G1Point(0xb5ebc43ab3ba449beaf1e5e4351a5ac81c7568763c3606970bcf948e8d8dfb6, 0x79d9b6ec6031937cbf509ba8affdceb322f189c99d20c5f5cf75978917b75fb);
        vk.IC[6] = Pairing.G1Point(0x41bb0e9a85e6ac5c196af107973049bb1901d3de72ef7e8de65f998eb280057, 0x1cc8a61db6d1f50d101bba5773ac10b61a78cc36921ead8695e17ab8cbd8ae78);
        vk.IC[7] = Pairing.G1Point(0x12cf562865923253ad7956ea07e11d467a496907ec14214b3ceb5519c4fbf5a3, 0x2a635aa619ff56114acb2e8831e3e6b736957a6a228653e14ad7cfd07be1647a);
    }
    event YOYOs(string where);
    function spendVerify(uint[] input, Proof proof) internal returns (uint) {
        // emit YOYOs('in svn');
        VerifyingKey memory vk = spendVerifyingKey();
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
    function spendVerifyTx(
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
        if (spendVerify(inputValues, proof) == 0) {
            emit Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}
