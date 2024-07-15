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
      return encodeLeaf(row.Wallet, toWei(row.Amount));
    });
    
    // Check if the number of leaves is odd
    if (leaves.length % 2 !== 0) {
      // Duplicate the last element
      leaves.push(leaves[leaves.length - 1]);
    }
    
    console.log("leaves",leaves)
    
    
   
    const obj = {};
    rows.forEach((value, _) => {
      obj[`key${value.Wallet}`] = value.Amount;
    });
    
    fs.writeFileSync("output.json",JSON.stringify({leaves,leaf:obj}))
    // const merkleTree = new MerkleTree(leaves, keccak256, {
    //   hashLeaves: true,
    //   sortPairs: true,
    // });
    // const root = merkleTree.getHexRoot();
    // console.log("root", root);


    // let leaf = keccak256("0xb0b161a0fe749a1de718fd703072d9f3cb567596deea60c7bebb36eb29ae34df");
    // let proof = merkleTree.getHexProof(leaf);
    // console.log(proof)
    
  });



