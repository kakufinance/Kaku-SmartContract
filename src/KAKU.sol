// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {ERC20Capped, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract KAKU is ERC20Capped, ERC20Permit, Ownable, ReentrancyGuard {
    bytes32 private constant META_TRANSFER_TYPEHASH =
        keccak256(
            "MetaTransfer(address from,address to,uint256 value,uint256 reward,uint256 nonce)"
        );

    
    struct MetaTransfer {
        address from;
        address to;
        uint256 value;
        uint256 reward;
        uint256 nonce;
    }

    constructor()
        ERC20("Kaku Finance", "KKFI")
        ERC20Permit("Kaku Finance")
        ERC20Capped(1_000_000_000 ether)
        Ownable(msg.sender)
    {}

    //errors
    error WrongSignature();

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
     * @notice Executes a gasless meta-transfer on behalf of the signer.
     * @dev Transfers tokens from one address to another, with optional reward, using a signature.
     * @param from The address from which the tokens will be transferred.
     * @param to The address to which the tokens will be transferred.
     * @param value The amount of tokens to transfer.
     * @param reward An optional reward amount to be transferred to the relayer.
     * @param signature The cryptographic signature authorizing the transfer.
     */
    function metaTransfer(
        address from,
        address to,
        uint256 value,
        uint256 reward,
        bytes calldata signature
    ) external nonReentrant {
        if (
            !_isValidSignature(
                from,
                getMessageHash(from, to, value, reward, _useNonce(from)),
                signature
            )
        ) {
            revert WrongSignature();
        }

        // transfer the value from signer to to address
        _transfer(from, to, value);
        // if there is a reward, send it to relayer
        if (reward > 0) {
            _transfer(from, msg.sender, reward);
        }
    }

    /**
     * @notice Checks if the signature is valid or not.
     * @param from The address from which the tokens will be transferred.
     * @param hash hash of the message Typed Data V4.
     * @param signature The cryptographic signature authorizing the transfer.
     */
    function _isValidSignature(
        address from,
        bytes32 hash,
        bytes calldata signature
    ) private pure returns (bool) {
        // recover the original signer
        (address signer, , ) = ECDSA.tryRecover(hash, signature);
        // check that the signer is equal to the from address
        return signer == from;
    }

    /**
     * @notice hash the message to Typed Data V4.
     * @param from The address from which the tokens will be transferred.
     * @param to The address to which the tokens will be transferred.
     * @param value The amount of tokens to transfer.
     * @param reward An optional reward amount to be transferred to the relayer.
     * @param nonce unique number to prevent replay attack.
     */
    function getMessageHash(
        address from,
        address to,
        uint256 value,
        uint256 reward,
        uint256 nonce
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        META_TRANSFER_TYPEHASH,
                        MetaTransfer({
                            from: from,
                            to: to,
                            value: value,
                            reward: reward,
                            nonce: nonce
                        })
                    )
                )
            );
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Capped) {
        super._update(from, to, value);
    }
}
