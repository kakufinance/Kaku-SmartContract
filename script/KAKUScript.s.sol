// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";
import {KAKU} from "../src/KAKU.sol";
contract KAKUScript is Script {
    

    function run() public {
        vm.startBroadcast();
        new KAKU();
        vm.stopBroadcast();
    }
}
