// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BondMarkBase.sol";

contract Deploy is Script {
    function run() external {
        address arbiter = vm.envAddress("ARBITER");
        uint256 unit = vm.envOr("TIME_UNIT", uint256(3600));
        bool allowEoa = vm.envOr("ALLOW_EOA_ARBITER", false);
        require(allowEoa || arbiter.code.length > 0, "arbiter must be a multisig contract (set ALLOW_EOA_ARBITER=true only on testnets)");
        vm.startBroadcast();
        new BondMarkBase(arbiter, unit);
        vm.stopBroadcast();
    }
}
