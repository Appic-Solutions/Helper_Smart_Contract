// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.24;

/**
 * @title A helper smart contract for converting MATIC to ckMATIC.
 * @notice This contract handles the deposit of MATIC, transferring it to a designated minter address, and allows for the withdrawal under certain conditions.
 */
contract CkMaticDeposit {
    // This is the main minter address for ckMATIC.
    address private ckMATIC_minter_main_address;

    // Custom errors to provide more specific revert reasons.
    error UnlockFailed(address _user, uint256 _amount);
    error NotMinter();

    // Event to log MATIC deposits into the contract.
    event ReceivedMATIC(
        address indexed from,
        uint256 value,
        bytes32 indexed principal
    );

    /**
     * @dev Constructor sets the main minter address.
     * @param _ckMATIC_minter_main_address The initial minter address.
     */
    constructor(address _ckMATIC_minter_main_address) {
        ckMATIC_minter_main_address = _ckMATIC_minter_main_address;
    }

    /**
     * @dev Returns the current minter address.
     * @return The address of the current minter.
     */
    function getMinterAddress() public view returns (address) {
        return ckMATIC_minter_main_address;
    }

    /**
     * @dev Allows the current minter to transfer minter role to a new address.
     * @param newAddress The new minter address.
     */
    function transferMinter(address newAddress) public {
        if (msg.sender != ckMATIC_minter_main_address) {
            revert NotMinter();
        }
        ckMATIC_minter_main_address = newAddress;
    }

    /**
     * @dev Accepts MATIC deposits and logs the event.
     * @param _principal Identifier for the deposit.
     */
    function deposit(bytes32 _principal) public payable {
        emit ReceivedMATIC(msg.sender, msg.value, _principal);
    }

    /**
     * @dev Allows the minter to unlock specified amount of MATIC to a user.
     * @param user The recipient of the MATIC.
     * @param amount The amount of MATIC to send.
     */
    function unlock(address payable user, uint256 amount) public {
        if (msg.sender == ckMATIC_minter_main_address) {
            revert NotMinter();
        }
        (bool success, ) = user.call{value: amount}("");
        if (!success) {
            revert UnlockFailed(user, amount);
        }
    }
}
