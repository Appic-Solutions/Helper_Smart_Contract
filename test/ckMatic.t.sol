// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.24;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ckMatic.sol";

contract ckMaticDepositTest is Test {
    CkMaticDeposit public CkMatic;
    function setUp() public {
        // mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.prank(address(111));
        CkMatic = new CkMaticDeposit(address(111));
    }

    function test_transferMinter() public {
        vm.prank(address(111));
        CkMatic.transferMinter(address(123));
        assertEq(CkMatic.getMinterAddress(), address(123));
    }

    function test_RevertTransferMinter() public {
        vm.expectRevert(CkMaticDeposit.Not_Minter.selector);
        vm.prank(address(123));
        CkMatic.transferMinter(address(121));
    }

    function test_deposit() public {
        vm.prank(address(111));
        deal(address(111), 100000000);
        CkMatic.deposit{value: 2000}("123123");
        console.log("balance: ", address(CkMatic).balance);
    }

    function test_unlock() public {
        vm.prank(address(111));
        deal(address(111), 100000000);
        CkMatic.deposit{value: 2000}("123123");
        vm.prank(address(111));
        CkMatic.unlock(payable(address(123)), 100);
        console.log("balance of user: ", address(123).balance);
        console.log("balance of smart contract", address(CkMatic).balance);
    }
}
