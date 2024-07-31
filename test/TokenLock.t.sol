// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TokenLock.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }
}

contract TokenLockTest is Test {
    TokenLock public tokenLock;
    MockERC20 public token;
    address public minter = address(1);
    address public user = address(2);

    function setUp() public {
        // Deploy the contract
        tokenLock = new TokenLock();

        // Deploy the mock token and assign balances
        token = new MockERC20("Mock Token", "MTKN");

        // Set the minter role to minter address
        tokenLock.grantMinterRole(minter);

        // Allocate tokens to user for testing
        token.transfer(user, 1000 * 10 ** token.decimals());
    }

    function testGrantMinterRole() public {
        // Act
        tokenLock.grantMinterRole(minter);
        bool hasMinterRole = tokenLock.hasRole(tokenLock.MINTER_ROLE(), minter);

        // Assert
        assertTrue(hasMinterRole);
    }

    function testLockTokens() public {
        // Arrange
        uint256 amount = 100 * 10 ** token.decimals();
        vm.startPrank(user);
        token.approve(address(tokenLock), amount);

        // Act
        bytes memory principalId = "testPrincipalId";
        tokenLock.lockTokens(address(token), amount, principalId);

        // Assert
        assertEq(token.balanceOf(minter), amount);
        assertEq(tokenLock.tokenAmount(address(token)), amount);
    }

    function testLockNativeCurrency() public {
        // Arrange
        uint256 amount = 1 ether;

        // Act
        bytes memory principalId = "testPrincipalId";
        vm.deal(user, amount);
        vm.prank(user);
        tokenLock.lockTokens{value: amount}(address(0), amount, principalId);

        // Assert
        assertEq(address(minter).balance, amount);
        assertEq(tokenLock.tokenAmount(address(0)), amount);
    }

    function testAddFee() public {
        // Arrange
        uint256 feeAmount = 0.1 ether;
        vm.deal(user, feeAmount);

        // Act
        vm.prank(user);
        tokenLock.addFee{value: feeAmount}();

        // Assert
        assertEq(address(minter).balance, feeAmount);
        assertEq(tokenLock.feeTank(user), feeAmount);
    }

    function testWithdrawTokens() public {
        // Arrange
        uint256 amount = 100 * 10 ** token.decimals();
        uint256 fee = 0;
        vm.startPrank(user);
        token.approve(address(tokenLock), amount);
        tokenLock.lockTokens(address(token), amount, "");

        // Act
        vm.stopPrank();
        vm.startPrank(minter);
        token.transfer(address(tokenLock), amount);
        uint256 balBefore = token.balanceOf(user);
        tokenLock.withdrawTokens(user, address(token), amount, fee);
        uint256 balAfter = token.balanceOf(user);

        // Assert
        assertEq(balAfter - balBefore, amount);
        assertEq(tokenLock.tokenAmount(address(token)), 0);
    }

    function testWithdrawNativeCurrency() public {
        // Arrange
        uint256 amount = 1 ether;
        uint256 fee = 0.1 ether;
        vm.deal(user, amount + fee);
        vm.prank(user);
        tokenLock.lockTokens{value: amount}(address(0), amount, "");

        // Act
        vm.prank(user);
        tokenLock.addFee{value: fee}();

        vm.startPrank(minter);
        tokenLock.withdrawTokens{value: amount}(user, address(0), amount, fee);

        // Assert
        assertEq(user.balance, amount);
        assertEq(tokenLock.tokenAmount(address(0)), 0);
    }

    function testGrantMinterRoleByOwner() public {
        // Act
        tokenLock.grantMinterRole(minter);
        bool hasMinterRole = tokenLock.hasRole(tokenLock.MINTER_ROLE(), minter);

        // Assert
        assertTrue(hasMinterRole);
    }

    function testGrantMinterRoleByNonOwner() public {
        // Arrange
        address nonOwner = address(3);
        vm.prank(nonOwner); // Set the next call's sender to nonOwner

        // Act & Assert
        vm.expectRevert();
        tokenLock.grantMinterRole(minter);
    }

    function testRevokeMinterRoleByOwner() public {
        // Arrange
        tokenLock.grantMinterRole(minter);
        assertTrue(tokenLock.hasRole(tokenLock.MINTER_ROLE(), minter));

        // Act
        tokenLock.rovokeMinterRole(minter);
        bool hasMinterRole = tokenLock.hasRole(tokenLock.MINTER_ROLE(), minter);

        // Assert
        assertFalse(hasMinterRole);
    }

    function testRevokeMinterRoleByNonOwner() public {
        // Arrange
        tokenLock.grantMinterRole(minter);
        address nonOwner = address(3);
        vm.prank(nonOwner); // Set the next call's sender to nonOwner

        // Act & Assert
        vm.expectRevert();
        tokenLock.rovokeMinterRole(minter);
    }
}
