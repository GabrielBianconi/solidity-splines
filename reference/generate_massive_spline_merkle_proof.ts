import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";

// The point to evaluate
let x = BigInt("1500000000000000000");

// Load the tree
const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("massive_spline_merkle_tree.json", "utf8")));

// Find the relevant segment and generate the proof
for (const [i, v] of tree.entries()) {
    if (BigInt(v[4]) <= x && x <= BigInt(v[5])) {
        const proof = tree.getProof(i);
        console.log('Spline Segment:');
        console.log(v);
        console.log('\nMerkle Proof:');
        console.log(proof);
    }
}
