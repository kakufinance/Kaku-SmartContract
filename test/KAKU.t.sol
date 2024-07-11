// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {KAKU} from "../src/KAKU.sol";

contract KAKUTest is Test {
    KAKU public kaku;

    function setUp() public {
        kaku = new KAKU();
    }

    function test_decimals() public view {
        assertEq(kaku.decimals(), 18);
    }

    function test_name() public view {
        assertEq(kaku.name(), "Kaku Finance");
    }

    function test_symbol() public view {
        assertEq(kaku.symbol(), "KKFI");
    }

    function test_mint() public {
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

    function test_burn() public {
        kaku.mint(address(1), 100_000_000 ether);
        uint256 bal = kaku.balanceOf(address(1));
        vm.prank(address(1));
        kaku.burn(100_000_000 ether);
        assertEq(kaku.balanceOf(address(1)), bal - 100_000_000 ether);
    }

    function testFailERC20InsufficientBalance() public {
        kaku.mint(address(1), 100_000_000 ether);
        vm.prank(address(1));
        kaku.burn(100_000_001 ether);
    }

    function test_meta_tx() public {
        (address alice, uint256 alicePk) = makeAddrAndKey("alice");

        kaku.mint(alice, 100_000_000 ether);

        uint64 nonce = uint64(block.timestamp);

        bytes32 messageHash = keccak256(
            abi.encodePacked(
                alice,
                address(2),
                uint256(1 ether),
                nonce,
                uint256(0)
            )
        );

        bytes32 prefixedMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, prefixedMessage);

        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(address(3));
        kaku.gasLessTransfer(
            alice,
            address(2),
            uint256(1 ether),
            nonce,
            0,
            signature
        );
    }

    function testFailSignatureAlreadyUsed() public {
        (address alice, uint256 alicePk) = makeAddrAndKey("alice");

        kaku.mint(alice, 100_000_000 ether);

        uint64 nonce = uint64(block.timestamp);

        bytes32 messageHash = keccak256(
            abi.encodePacked(
                alice,
                address(2),
                uint256(1 ether),
                nonce,
                uint256(0)
            )
        );

        bytes32 prefixedMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, prefixedMessage);

        bytes memory signature = abi.encodePacked(r, s, v);

        vm.startPrank(address(3));
        kaku.gasLessTransfer(
            alice,
            address(2),
            uint256(1 ether),
            nonce,
            0,
            signature
        );
        kaku.gasLessTransfer(
            alice,
            address(2),
            uint256(1 ether),
            nonce,
            0,
            signature
        );
    }

    function testFailWrongSignature() public {
        (address alice, uint256 alicePk) = makeAddrAndKey("alice");

        kaku.mint(alice, 100_000_000 ether);

        uint64 nonce = uint64(block.timestamp);

        bytes32 messageHash = keccak256(
            abi.encodePacked(
                alice,
                address(2),
                uint256(1 ether),
                nonce,
                uint256(0)
            )
        );

        bytes32 prefixedMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, prefixedMessage);

        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(address(3));
        kaku.gasLessTransfer(
            alice,
            address(2),
            uint256(2 ether),
            nonce,
            0,
            signature
        );
    }
}
