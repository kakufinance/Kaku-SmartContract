import fs from "fs";
import csv from "csv-parser";
import { MerkleTree } from "merkletreejs";
import keccak256 from "keccak256";
import {  ethers } from "ethers";

const toWei = (value) => ethers.parseEther(value);
function encodeLeaf(address,amount) {
  let abi = ethers.AbiCoder.defaultAbiCoder();
  return "0x"+keccak256(
    abi.encode(
          ['address', 'uint256'],
          [address, amount]
      )
  ).toString("hex");
}
// Read CSV file
const csvFilePath = "kaku_presale.csv";
const rows = [];
fs.createReadStream(csvFilePath)
  .pipe(csv())
  .on("data", (row) => {
    rows.push(row);
  })
  .on("end", () => {
    const leaves = rows.map((row) => {
        const data = `${row.Wallet}${" "}${toWei(row.Amount)}`;
        console.log(data)
      return encodeLeaf(row.Wallet, toWei(row.Amount));
    });
    console.log("leaves",leaves)

// Check if the number of leaves is odd
if (leaves.length % 2 !== 0) {
  // Duplicate the last element
  leaves.push(leaves[leaves.length - 1]);
}

    const merkleTree = new MerkleTree(leaves, keccak256, {
      hashLeaves: true,
      sortPairs: true,
    });
    const root = merkleTree.getHexRoot();
    console.log("root", root);


    // let leaf = keccak256("0x000000000000000000000000a74f654cc0f1a0ccf6cbcf1cdc2acc4b3b17be4d00000000000000000000000000000000000000000000001b1ae4d6e2ef500000");
    // let proof = merkleTree.getHexProof(leaf);
    // console.log(proof)
    
  });



