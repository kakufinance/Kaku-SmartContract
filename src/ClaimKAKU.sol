// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev This contract allows users to claim KAKU tokens if they are part of a Merkle tree whitelist.
 * The contract uses OpenZeppelin's SafeERC20 for safe token transfers and Ownable for access control.
 */
contract ClaimKAKU is Ownable {
    using SafeERC20 for IERC20;

    bytes32 public merkleRoot; // Root of the Merkle tree
    address public immutable token; // Address of the KAKU token contract
    mapping(address => bool) public isClaimed; // Tracks whether an address has claimed their tokens

    // events
    event LogClaimedKAKU(address indexed sender, uint256 indexed _amount);

    // errors
    error ZeroAddress();
    error AlreadyClaimed();
    error InvalidMarkleProof();
    error NoTokensToWithdraw();

    /**
     * @notice Constructor to initialize the contract with the KAKU token address and the Merkle root
     * @param _token The address of the KAKU token contract
     * @param _merkleRoot The root hash of the Merkle tree for bonus eligibility
     */
    constructor(
        address _token,
        bytes32 _merkleRoot
    ) payable Ownable(msg.sender) {
         if (_token == address(0)) {
            revert ZeroAddress();
        }
        token = _token;
        merkleRoot = _merkleRoot;
    }

    /**
     * @notice Allows eligible addresses to claim their presale KAKU tokens
     * @dev Verifies the caller's address and claim amount against the Merkle root. If the proof is valid, tokens are transferred.
     * @param _amount The amount of KAKU tokens to claim
     * @param _merkleProof The Merkle proof verifying the claimant's eligibility
     */
    function claimKAKU(
        uint256 _amount,
        bytes32[] calldata _merkleProof
    ) external {
        if (isClaimed[msg.sender]) {
            revert AlreadyClaimed();
        }
        // hash twice to prevent second preimage attack 
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, _amount))));
        if (!MerkleProof.verify(_merkleProof, merkleRoot, leaf)) {
            revert InvalidMarkleProof();
        }

        isClaimed[msg.sender] = true;
        emit LogClaimedKAKU(msg.sender, _amount);
        IERC20(token).safeTransfer(msg.sender, _amount);
    }

    /**
     * @notice Updates the Merkle root to a new value
     * @dev Only callable by the contract owner. This allows updating the whitelist without deploying a new contract.
     * @param _merkleRoot The new root of the Merkle tree
     */
    function updateMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    /**
     * @notice Allows the contract owner to withdraw any tokens remaining in the contract
     * @dev This function is intended for emergency use to recover tokens from the contract.
     */
    function withdrawTokens() external onlyOwner {
        uint256 bal = IERC20(token).balanceOf(address(this));
        if (bal > 0) {
            IERC20(token).safeTransfer(owner(), bal);
        }else{
            revert NoTokensToWithdraw();
        }
    }


}
