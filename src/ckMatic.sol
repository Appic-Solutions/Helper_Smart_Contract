// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.18;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

/**
 * @title Token Locking Smart Contract
 * @notice This contract allows users to lock their tokens, with the contract owner having the exclusive right to withdraw the locked tokens.
 */
contract TokenLock is Ownable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address public minter;
    mapping(address => uint256) public tokenAmount;
    uint256 public immutable withdrawGasCost;

    // Custom errors for specific revert reasons
    error NotOwner();
    error TransferFailed(address _user, uint256 _amount);

    // Event to log token deposits into the contract
    event TokensLocked(
        address user,
        address indexed token,
        uint256 indexed amount,
        bytes indexed principalId
    );

    /**
     * @dev Constructor sets the contract deployer as the owner.
     * @dev Constructor sets the deployer as the default admin.
     */
    constructor(uint256 _gasCost) Ownable(msg.sender) {
        minter = msg.sender;
        withdrawGasCost = _gasCost;
        _grantRole(MINTER_ROLE, msg.sender);
    }

    /**
     * @dev Grants `MINTER_ROLE` to the specified user.
     * Can only be called by the contract owner.
     */
    function grantMinterRole(address user) public onlyOwner {
        minter = user;
        _grantRole(MINTER_ROLE, user);
    }

    /**
     * @dev Revokes `MINTER_ROLE` from the specified user.
     * Can only be called by the contract owner.
     */
    function rovokeMinterRole(address user) public onlyOwner {
        _revokeRole(MINTER_ROLE, user);
    }

    /**
     * @dev Locks the specified amount of tokens from the user.
     * @param token The address of the token to lock.
     * @param amount The amount of tokens to lock.
     */
    function lockTokens(
        address token,
        uint256 amount,
        bytes memory principalId
    ) external payable {
        if (token == address(0)) {
            require(msg.value >= amount + withdrawGasCost, "Amount is less");
            tokenAmount[token] = tokenAmount[token] + amount;
            (bool success, ) = minter.call{value: withdrawGasCost}("");
            if (!success) {
                revert TransferFailed(minter, withdrawGasCost);
            }
            emit TokensLocked(msg.sender, address(0), msg.value, principalId);
        } else {
            IERC20 tokenContract = IERC20(token);
            tokenAmount[token] = tokenAmount[token] + amount;
            bool success = tokenContract.transferFrom(
                msg.sender,
                address(this),
                amount
            );
            if (!success) {
                revert TransferFailed(msg.sender, amount);
            }

            // Emit the TokensLocked event
            emit TokensLocked(msg.sender, token, amount, principalId);
        }
    }

    /**
     * @dev withdraw the locked tokens.
     * @param token The address of the token to withdraw.
     * @param amount The amount of tokens to withdraw.
     */
    function withdrawTokens(
        address user,
        address token,
        uint256 amount
    ) external {
        require(hasRole(MINTER_ROLE, msg.sender), "MINTER_ROLE require");
        if (token == address(0)) {
            (bool success, ) = user.call{value: amount}("");
            if (!success) {
                revert TransferFailed(user, amount);
            }
        } else {
            IERC20 tokenContract = IERC20(token);

            bool success = tokenContract.transfer(user, amount);
            if (!success) {
                revert TransferFailed(user, amount);
            }
        }
    }
}
