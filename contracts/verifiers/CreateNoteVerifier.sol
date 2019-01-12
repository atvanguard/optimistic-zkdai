// This file is LGPL3 Licensed

pragma solidity ^0.4.19;

import "./VerifierBase.sol";

contract Verifier is VerifierBase {
    function verifyingKey() pure internal returns (VerifyingKey vk) {
        vk.A = Pairing.G2Point([0xc770f781f1eafd3175f4a09928b08cb42634d5cda1cac9919f95e3967fbfd21, 0x27b7fc7645e5c6168003432afb0085f5529fa2b44f75213e5b8aa10e744d1b3c], [0x19230efa60fbdda65f858cb8ce7ca930f88a04343c3eac158a831f9ee4d3e9b7, 0x152a29aaf62acc80e05e3c3774eedd7091d2978a452640bd8d40d31345c6dd51]);
        vk.B = Pairing.G1Point(0x1892484cd079946ff4d147d4b93d2e4bee219076b2126fc350a77b642f6abd3e, 0x16462f9888b1beba8d24d9402bd91c9c9a0678ca14c418a760be6d2bfc5c4f63);
        vk.C = Pairing.G2Point([0x2666367b5cbcff8483d2157758d6872c958baf8806f0ce067efea1f9b62975fe, 0x225268e5fc2ba7d029337aca232a1b72016513d33b775d595408d55f44863e5c], [0x26fd5ed504e293f7d96891af79b106b167abf622134c8188301ae4cb0e9df373, 0x26c4bd50b1c45e356b9d30852a14fc68ef8f908d8e23385271c4563f59c18a99]);
        vk.gamma = Pairing.G2Point([0x11b0e0131aa655adcdbf82c02aabad787fe53643510b09bbac04490786123ba0, 0xeddd608c2c5a7988a3bde7bc770b64d479f140af4f8771534300fac07c47eab], [0x1d5b7ed6f518f3c9af7323fc20dd0ad3d8bf5ce04ff39d270684e979a7d68d5e, 0x2711e18d83f766d6dc90c9a0929a8533be25194c1e470229388d0a053d0c4edf]);
        vk.gammaBeta1 = Pairing.G1Point(0x20c4b6c82158a29a96c632c12ca9b27e5d8016666ad1e443090e7b02c9351782, 0xb7b4216ab1553c269863ba1efed080859d7a0337802273cadeb893226cd1456);
        vk.gammaBeta2 = Pairing.G2Point([0x2fe44d74816e8ae602ad30eb829520da10b5d4e416ac63b6fa53c168f271961c, 0x28e503021c8a994454629204ad6e54898b36bfd1d18797fe8c7ac0a857d6fdd9], [0x18d3ce803c88553c4e04b01874564b6158aadc02755268f748914338b1d60751, 0x1e35a4706b30cfeee4ab28b927bf8b8340387a21ed95a88ab8d784b67709028e]);
        vk.Z = Pairing.G2Point([0x235acab265bfc88d807cd4e3b3af66afb09aae176c83a783637592b2e5b120af, 0x304b716f03000664f0e514f3bcda8015022422b358bd38cf98edc37e0240bcf2], [0x240567a802322992045c699063047bc30b5376a3c33f1810ee59f58a8b796352, 0x5f124e2ed1344dbe861e8fc8b52838890d9ae16c34d6a85083dd2985d005e2e]);
        vk.IC = new Pairing.G1Point[](5);
        vk.IC[0] = Pairing.G1Point(0x2f10635c01e7b518ce0c4418b82debd946830ef1cff3314ebfc8523eedcff8, 0x6cd94ee80961d6d288fa7532bef5132fbd40ca53a1753e7895a103399a17eed);
        vk.IC[1] = Pairing.G1Point(0x1488b84f0ea6a564812e344017faddf54f143bc898ba8b80a54b54d2e184f5bf, 0x18076c5df9ecfdbc617e3e97c6fe2cd5985acae71b42aa117cd91d819c6bd7ea);
        vk.IC[2] = Pairing.G1Point(0x26d8d280355bbc710b99d13aa9ef2da6539ac4ac1534c8b914ec5714dac45d6c, 0x2d0100764464e32ca47e87d6ab23134d00f40c7474d7e16b40924cde43643e23);
        vk.IC[3] = Pairing.G1Point(0x2d5e8260117b26cecc19b6a1f4c46a94b2fd512b8ab57955ddc3bc5a39df134, 0xe0a7c0dee166e994dc0834e555f3999486d91b2cde22c1f0766aae0e5d30daa);
        vk.IC[4] = Pairing.G1Point(0x21d90660cc31b978b9c4a3d36a3a325a4fa5c210b1ab44ccbb3c7ee280716dac, 0x289c6309138f7d8e05dd5067511a5c9cfae2f5de0060e4fc2027abb34e491de8);
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
