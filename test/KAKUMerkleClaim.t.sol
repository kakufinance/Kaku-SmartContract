// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ClaimKAKU.sol";
import "../src/KAKU.sol";
import "./utils/Merkle.sol";

contract TestClaim is Test {
    KAKU public kaku;
    ClaimKAKU public claim;
    Merkle public m;
    bytes32[] public data;

    function setUp() public {
        kaku = new KAKU();
        // Initialize
        m = new Merkle();
        // Toy Data
        data = new bytes32[](4);
        data[0] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0xDf6Fa9A3e89A31f942F543ad88C934eaC1672594,
                        5 ether
                    )
                )
            )
        );
        data[1] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0x3a3cEE190139F70B98CC10fa24E50624cFeaDf07,
                        5 ether
                    )
                )
            )
        );
        data[2] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0x32b0B0DCA1348Eb281F30B7430f1957eCaE700A3,
                        5 ether
                    )
                )
            )
        );
        data[3] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0x0211ED1831046A907c0Bb03F206FE4F85667E942,
                        5 ether
                    )
                )
            )
        );

        // Get Root, Proof, and Verify
        bytes32 root = m.getRoot(data);

        claim = new ClaimKAKU(address(kaku), root);
        kaku.mint(address(claim), 11000 ether);
    }

    function testClaim() public {
        bytes32[] memory proof = m.getProof(data, 2); // will get proof for 0x2 value
        assertEq(kaku.balanceOf(0x32b0B0DCA1348Eb281F30B7430f1957eCaE700A3),0);
        uint256 bal = kaku.balanceOf(address(claim));
        vm.prank(address(0x32b0B0DCA1348Eb281F30B7430f1957eCaE700A3));
        claim.claimKAKU(5 ether, proof);
        assertEq(kaku.balanceOf(0x32b0B0DCA1348Eb281F30B7430f1957eCaE700A3),5 ether);
        assertEq(kaku.balanceOf(address(claim)),bal - 5 ether);

    }

    function testFailInvalidMarkleProof() public {
        bytes32[] memory proof = m.getProof(data, 2); // will get proof for 0x2 value
        claim.claimKAKU(5 ether, proof);
    }

    function testFailAlreadyClaimed() public {
        bytes32[] memory proof = m.getProof(data, 2); // will get proof for 0x2 value
        claim.claimKAKU(5 ether, proof);
        claim.claimKAKU(5 ether, proof);
    }

    function testWithdraw() public {
        uint256 bal = kaku.balanceOf(address(claim));
        claim.withdrawTokens();
        assertEq(kaku.balanceOf(address(this)),bal);
    }

    function testFailNoTokensToWithdraw() public {
        claim.withdrawTokens();
        claim.withdrawTokens();
    }

    function testFailOwnableUnauthorizedAccount_withdrawTokens() public {
        vm.prank(address(1));
        claim.withdrawTokens();
    }

    function testUpdateMerkleRoot() public {
        m = new Merkle();
        // Toy Data
        data = new bytes32[](4);
        data[0] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0xDf6Fa9A3e89A31f942F543ad88C934eaC1672594,
                        1 ether
                    )
                )
            )
        );
        data[1] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0x3a3cEE190139F70B98CC10fa24E50624cFeaDf07,
                        1 ether
                    )
                )
            )
        );
        data[2] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0x32b0B0DCA1348Eb281F30B7430f1957eCaE700A3,
                        1 ether
                    )
                )
            )
        );
        data[3] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0x0211ED1831046A907c0Bb03F206FE4F85667E942,
                        1 ether
                    )
                )
            )
        );
        // Get Root, Proof, and Verify
        bytes32 root = m.getRoot(data);
        claim.updateMerkleRoot(root);
        assertEq(claim.merkleRoot(),root);
    }

    function testFailOwnableUnauthorizedAccount() public {
        m = new Merkle();
        // Toy Data
        data = new bytes32[](4);
        data[0] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0xDf6Fa9A3e89A31f942F543ad88C934eaC1672594,
                        1 ether
                    )
                )
            )
        );
        data[1] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0x3a3cEE190139F70B98CC10fa24E50624cFeaDf07,
                        1 ether
                    )
                )
            )
        );
        data[2] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0x32b0B0DCA1348Eb281F30B7430f1957eCaE700A3,
                        1 ether
                    )
                )
            )
        );
        data[3] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0x0211ED1831046A907c0Bb03F206FE4F85667E942,
                        1 ether
                    )
                )
            )
        );
        // Get Root, Proof, and Verify
        bytes32 root = m.getRoot(data);
        vm.prank(address(1));
        claim.updateMerkleRoot(root);
    }
}
