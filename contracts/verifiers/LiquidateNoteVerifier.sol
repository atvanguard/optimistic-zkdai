// This file is LGPL3 Licensed

pragma solidity ^0.4.19;

import "./VerifierBase.sol";

contract Verifier is VerifierBase {
    function verifyingKey() pure internal returns (VerifyingKey vk) {
        vk.A = Pairing.G2Point([0x148ae40ef7e2c7bb260d7d4832c7348e5d9f8070f5a0ee4351840d82f1f8f6c3, 0x1c603b711bb29ffa078f53d290240338db9b93a8997743f03a75a3e31006b250], [0x18c17d9d296ca8e97ad4b9ac42197eee9aacb8af2a4f7a0d4938801221e4275d, 0x2f82887f18fd1a3be65648796980e8cc02055cce4d20682a17ed778f38ff0165]);
        vk.B = Pairing.G1Point(0x2829c2e35ae8b3c32269f33ed4851b67e2e9bb6d203cbe99ce668621cd600cfb, 0x2425ec9619661a67c0b375b26b7af9c5686b149a63bced6a2ee75e70a05f2c8c);
        vk.C = Pairing.G2Point([0x2f369e1cb8d8d15f82ca1b0834d74f7624ed60c4ae38cdcda18543921ffe4137, 0x287adddbe9b346500960d69e440a122fccd7b0553cc4d7d16db374410ba1685f], [0x27bbf5172bb1f901507ebd76c2d254b56f9dc7d0a221c2e37b6696b81ca2a0d3, 0x2a71f94c088923b35de86042a16300453110d0578f72b7c413a33db537af4c7f]);
        vk.gamma = Pairing.G2Point([0x105ac5e451807b3c24a2f3fe0ab3ca2282da245954a2570a353e2de5b27639de, 0x15cf6f33c3209d84220a0d9cab9c8ffa72bcc7abb14c55d68936896d35c83d8f], [0x17074220cbf4a839bd621afb28dbae161f531cbc6363ec5cf19765cb8d64d317, 0xefd81beeb86338399dd723dd2ed58ee2ec2a95bba966f6f45a48385abc1c85a]);
        vk.gammaBeta1 = Pairing.G1Point(0x2ac867a275c41c031e3234ff5675c0c91532703292d459fbf8c77ddb8fc657ff, 0x1bbd7d7277ad5d3187a782daca45ebe8ab259c02c502da99ea7141948f086e9c);
        vk.gammaBeta2 = Pairing.G2Point([0xe1fa0a4ac5beba6bc5792a469cfc7ee959a9d9ae9d8a25e0bc5a0067c4e36e0, 0x13d14c39135e1f2bd782f50e471f1d75e0fd278be25b83eec2b7e27ac974f7b6], [0x10fca4dcf7838dffea0a1e9ab535b1c86f3658c1191673f0ca733ca75bb707e8, 0x2619cbaf48291019f416d75d588efa23b93db3acbcffb6101a4ab4934baef40]);
        vk.Z = Pairing.G2Point([0x779c03c580c9141d46740159a0beaaaf3450a8ca5620c3f578443b9bcfa1a, 0x76a9d57635a0121eaa56aa420bfe237c801327342037ed4abc04d29dc2058c1], [0x110f38f7fa77ca5361b5a194b623d537b184c71bf2863fb2fd2f75e61ab3e7d6, 0x102a9736c333faa7b3c343ea5bb0192135ca1ab951ffb7f8c9adee3123561620]);
        vk.IC = new Pairing.G1Point[](5);
        vk.IC[0] = Pairing.G1Point(0x1ad6db83d408f0b144c16258ab2a62e3e219afd90bdc15e136da2b02b2b4e733, 0x25e0879d7f54f64e0a0ae591a43f709c516c9fafdf0031dd14edcaeea7307a0f);
        vk.IC[1] = Pairing.G1Point(0x1fbe5ede1efab129ad2171725dd14edbad66299a72e443911427faf634c362a2, 0xb87a15499a2d78b3ef4064de24b63f4fd90cf663474299207dbe7a03edef881);
        vk.IC[2] = Pairing.G1Point(0x142d1e2fb643d44830d9da3bae4e57be8d2d2f51c1f7dc0afdda9e2da94a0fda, 0x3133edf6867b73e4c9d66dfb03e187b414ca85370f1f7ca6521f084524a0ae3);
        vk.IC[3] = Pairing.G1Point(0x1a2c1c2765d4d960ffe0759c15d1f389b49c629b020bc83e1115a15e9d1de5a9, 0x2beb4572d6c18d9333ecc362e5e96ee36fa70ba2dd875373ced86f3e0c28b6e1);
        vk.IC[4] = Pairing.G1Point(0x1ec6bf59915888ecc0856a82c577c30de1b88974a7f7e7dd5ef8ee60f3a30345, 0x2762a7f688526b21a71fedcfae5327c4054a23215e205c04ea8d38ea240bb2de);
    }
    event YOYOs(string where);
    function verify(uint[] input, Proof proof) internal returns (uint) {
    emit YOYOs('in lvn');
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
        if (verify(inputValues, proof) == 0) {
            emit Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}
