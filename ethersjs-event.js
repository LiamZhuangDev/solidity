const { ethers } = require("ethers");

// HTTP 也可以
const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");

const contract = new ethers.Contract(
  "0xaee14B4a0d1e3A98CBb6DA0c509E5aD21B349Fa0", // contract address
  ["event Transfer(address indexed from, address indexed to, uint256 value)"],
  provider
);

// 查询历史
async function main() {
  const events = await contract.queryFilter("Transfer", 0, "latest");

  for (const e of events) {
    console.log("历史事件:");
    console.log("from:", e.args.from);
    console.log("to:", e.args.to);
    console.log("value:", e.args.value.toString());
  }
}

main();