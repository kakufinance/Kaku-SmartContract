// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {KAKU} from "../src/KAKU.sol";

contract KAKUTest is Test {
    KAKU public kaku;
     bytes32 private constant META_TRANSFER_TYPEHASH =
        keccak256("MetaTransfer(address from,address to,uint256 value,uint256 reward,uint256 nonce)");


    function setUp() public {
        kaku = new KAKU();
    }

    function testDecimals() public view {
        assertEq(kaku.decimals(), 18);
    }

    function testName() public view {
        assertEq(kaku.name(), "Kaku Finance");
    }

    function testSymbol() public view {
        assertEq(kaku.symbol(), "KKFI");
    }

    function testMint() public {
        kaku.mint(address(1), 10_000 ether);
        assertEq(kaku.balanceOf(address(1)), 10_000 ether);
    }

    function testFailOwnableUnauthorizedAccount() public {
        vm.prank(address(1));
        kaku.mint(address(1), 10_000 ether);
    }

    function testFailERC20ExceededCap() public {
        kaku.mint(address(1), 1_000_000_001 ether);
    }

  

    function testMetaTransaction() public {
        (address alice, uint256 alicePk) = makeAddrAndKey("alice");

        kaku.mint(alice, 100_000_000 ether);

        uint256 transferAmount = 1 ether;
        bytes32 messageHash = kaku.getMessageHash(
                alice,
                address(2),
                transferAmount,
                uint256(0),
                kaku.nonces(alice)
            );

       

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, messageHash);

        bytes memory signature = abi.encodePacked(r, s, v);
        uint256 bal = kaku.balanceOf(alice);
        vm.prank(address(3));
        kaku.metaTransfer(
            alice,
            address(2),
            transferAmount,
            0,
            signature
        );

        assertEq(kaku.balanceOf(alice),bal - transferAmount);
        assertEq(kaku.balanceOf(address(2)),transferAmount);
    }

    function testFailWrongSignature_metaTransaction() public {
        (address alice, uint256 alicePk) = makeAddrAndKey("alice");

        kaku.mint(alice, 100_000_000 ether);


        bytes32 messageHash = kaku.getMessageHash(
            alice,
            address(2),
            uint256(1 ether),
            0,
            kaku.nonces(alice)
        );


        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, messageHash);

        bytes memory signature = abi.encodePacked(r, s, v);

        vm.startPrank(address(3));
        kaku.metaTransfer(
            alice,
            address(2),
            uint256(1 ether),
            0,
            signature
        );
      
        kaku.metaTransfer(
            alice,
            address(2),
            uint256(1 ether),
            0,
            signature
        );
    }

    function testFailWrongSignature() public {
        (address alice, uint256 alicePk) = makeAddrAndKey("alice");

        kaku.mint(alice, 100_000_000 ether);


        bytes32 messageHash = kaku.getMessageHash(
                alice,
                address(2),
                uint256(1 ether),
                uint256(0),
                kaku.nonces(alice)
            
        );

 

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, messageHash);

        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(address(3));
        kaku.metaTransfer(
            alice,
            address(2),
            uint256(2 ether),
            0,
            signature
        );
    }



        function testMetaTransactionRelayerFee() public {
        (address alice, uint256 alicePk) = makeAddrAndKey("alice");

        kaku.mint(alice, 100_000_000 ether);

        uint256 transferAmount = 1 ether;
        uint256 relayerFee = 0.01 ether;
        bytes32 messageHash = kaku.getMessageHash(
                alice,
                address(2),
                transferAmount,
                relayerFee,
                kaku.nonces(alice)
            );

       

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, messageHash);

        bytes memory signature = abi.encodePacked(r, s, v);
        uint256 bal = kaku.balanceOf(alice);
        vm.prank(address(3));
        kaku.metaTransfer(
            alice,
            address(2),
            transferAmount,
            relayerFee,
            signature
        );

        assertEq(kaku.balanceOf(alice),bal - transferAmount - relayerFee);
        assertEq(kaku.balanceOf(address(2)),transferAmount);
        assertEq(kaku.balanceOf(address(3)),relayerFee);
    }
}
