// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ERC20Capped, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract KAKU is  ERC20Capped, Ownable {
    // mapping for tracking used signatures
    mapping(bytes => bool) private signatureUsed;

    constructor()
        ERC20("Kaku Finance", "KKFI")
        ERC20Capped(1_000_000_000 ether)
        Ownable(msg.sender)
    {}

    //errors
    error WrongSignature();
    error SignatureAlreadUsed();

    /**
     * @dev Function to mint new tokens and assign them to a specified address.
     * @param to The address to which the new tokens are minted.
     * @param amount The amount of tokens to be minted.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        // Call the internal _mint function from ERC20 to create new tokens
        _mint(to, amount);
    }

    /**
     * @dev Function for user to burn there balance.
     * @param amount The amount of tokens to be burned.
     */
    function burn(uint256 amount) external {
        // Call the internal _burn function from ERC20 to destroy tokens
        _burn(msg.sender, amount);
    }

 
    /**
     * @notice Executes a gasless transfer on behalf of the signer.
     * @dev Transfers tokens from one address to another, with optional reward, using a signature.
     * @param from The address from which the tokens will be transferred.
     * @param to The address to which the tokens will be transferred.
     * @param value The amount of tokens to transfer.
     * @param nonce block.timestamp as a unique value to ensure the signature is not reused.
     * @param reward An optional reward amount to be transferred to the relayer.
     * @param signature The cryptographic signature authorizing the transfer.
     */
    function gasLessTransfer(
        address from,
        address to,
        uint256 value,
        uint64 nonce,
        uint256 reward,
        bytes calldata signature
    ) external {
        // check that if the signature is already used
        if (signatureUsed[signature]) {
            revert SignatureAlreadUsed();
        }
        // mark the signature as used
        signatureUsed[signature] = true;
        // construct the message which was signed bt the signer
        bytes32 message = MessageHashUtils.toEthSignedMessageHash( keccak256(abi.encodePacked(from, to, value, nonce, reward)));
        // recover the original signer
        address signer = ECDSA.recover(message, signature);
        // check that the signer is equal to the from address
        if (signer != from) {
            revert WrongSignature();
        }
        // transfer the value from signer to to address
        _transfer(signer, to, value);
        // if there is a reward, send it to relayer
        if (reward > 0) {
            _transfer(signer, msg.sender, reward);
        }
    }


}
