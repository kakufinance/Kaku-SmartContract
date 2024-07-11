// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {KAKU} from "../src/KAKU.sol";
contract KAKUScript is Script {
        KAKU public kaku;
    function setUp() public {
              kaku = new KAKU();
    }

    function run() public {
        vm.broadcast();
    }
}
