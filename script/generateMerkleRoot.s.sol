    // SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script, console} from "forge-std/Script.sol";
import "../test/utils/Merkle.sol";
contract GenerateMerkleRoot is Script {
    function run() public {
        Merkle m = new Merkle();
        bytes32[] memory data = new bytes32[](4);



        data[0] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0xa74F654CC0f1A0cCf6cBcf1cDC2acc4b3b17bE4d,
                        500 ether
                    )
                )
            )
        );
        data[1] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0x9E3bf1A2641857F607a65e83b5caC76B7831fec2,
                        500 ether
                    )
                )
            )
        );
        data[2] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0xf35B92670483a4912E16b5eA480700fB67E40f77,
                        50 ether
                    )
                )
            )
        );

         data[3] = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        0xf35B92670483a4912E16b5eA480700fB67E40f77,
                        50 ether
                    )
                )
            )
        );

        
    

        // Get Root, Proof, and Verify
        bytes32 root = m.getRoot(data);
        console.log("Merkle root:");
        console.logBytes32(root);
        // console.logBytes32(data[0]);
        // console.logBytes32(data[1]);
        // console.logBytes32(data[2]);
 }
}