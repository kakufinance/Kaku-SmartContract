// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {KAKU} from "../src/KAKU.sol";

contract KAKUTest is Test {
    KAKU public kaku;
     bytes32 private constant META_TRANSFER_TYPEHASH =
        keccak256("MetaTransfer(address from,address to,uint256 value,uint256 reward,uint256 nonce)");

    error WrongSignature();

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

  

    function test_meta_tx() public {
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
            uint256(1 ether),
            0,
            signature
        );
    }

    function test_fail_when_use_same_sig() public {
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
        vm.expectRevert(WrongSignature.selector);
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
}
