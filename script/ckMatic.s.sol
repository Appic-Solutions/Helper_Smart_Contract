// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/ckMatic.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("DEV_PRIVATE_KEY");
        address account = vm.addr(privateKey);
        console.log("account: ", account);
        vm.startBroadcast(privateKey);

        CkMaticDeposit ckMatic = new CkMaticDeposit(
            0xbAf59B045c6B53bCc849e2a487C14F234435cC51
        );

        vm.stopBroadcast();
    }
}
