# What is a blockchain?
A blockchain is a public database that is updated and sahred across many computers in a network.

# What are blocks?
Blockers are batches of transactions with a hash of the previous block in the chain.

# What is Ethereum?
Ethereum is a blockchain with a single, canonical computer (Ethereum Virtual Machine) embedded in it. It is the foundation for building apps and organizations in a decentralized, permisionless, censorship-resistant way.

# What is ether?
Ether(ETH) is the native cryptocurrency of Ethereum. The purpose of ETH is to allow for a market for computation. Such a market provides an economic incentive for participants to verify and execute transaction requests and provide computational resources to the network.

# What are smart contracts?
Smart contracts are turning complete programs published into EVM state, they can be called with certain parameters, perform some actions or computation if certain condition are satified. They are often also called dApps, or decentralized apps.

# What are Ethereum Accounts?
An Ethereum account is an entity with an ether (ETH) balance that can send messages on Ethereum. Accounts can be user-controlled or deployed as smart contracts.

# What are Transactions?
Transactions are cryptographically signed instructions from accounts. An account will initiate a transaction to update the state of the Ethereum network.

The simplest transaction is transferring ETH from one account to another.

# What is Ethereum virtual machine (EVM)?
The Ethereum Virtual Machine (EVM) is a decentralized virtual environment that executes code consistently and securely across all Ethereum nodes.

When a transaction calls a smart contract, the Ethereum Virtual Machine executes the contract’s compiled bytecode instruction-by-instruction on a stack-based machine across all nodes, consuming gas and updating the blockchain state deterministically if execution succeeds.

# EVM storage, memory and calldata
```
| Location | Where it lives           | Lifetime        |
| -------- | ------------------------ | --------------- |
| storage  | blockchain state         | permanent       |
| memory   | EVM temporary RAM        | during the call |
| calldata | transaction input buffer | during the call |
```
EVM layout when a function runs:
```
┌─────────────────────────────┐
│ Stack (max 1024 items)      │
│ small values, pointers      │
├─────────────────────────────┤
│ Memory                      │
│ temporary arrays/structs    │
│ uint[] memory arr           │
├─────────────────────────────┤
│ Storage                     │
│ contract state variables    │
└─────────────────────────────┘
```

# What is Gas and Gas fee?
Gas refers to the unit that measures the amount of computational effort required to execute specific operations on the Ethereum network.

The gas fee is the amount of gas used to do some operation, multiplied by the cost per unit gas. The fee is paid regardless of whether a transaction succeeds or fails. However, any gas not used in a transaction is returned to the user.

Gas prices are usually quoted in gwei, which is a denomination of ETH.
```
1 gwei = one-billionth of an ETH (10^-9 ETH)
1 wei = one-billionth of gwei (10^-9 gwei)
-or-
1 ETH = 10^9 gwei
1 gwei = 10^9 wei
```

The total fee would now be equal to:
```
unit of gas used * (base fee + priority fee)
```

Because the base fee is not known exactly when sending a transaction. So, we also need to specify:
```
maxFeePerGas
```
The actual price per gas becomes:
```
min(maxFeePerGas, baseFee + priorityFee)
```
So:
If base fee spikes → you are protected
If base fee stays low → you only pay what's needed

# what is gas limit?
The gas limit refers to the maximum amount of gas you are willing to consume on a transaction. More complicated transactions involving smart contracts require more computational work, so they require a higher gas limit than a simple payment. 

A standard ETH transfer requires a gas limit of 21,000 units of gas. If you put a gas limit of 50,000 for a simple ETH transfer, the EVM would consume 21,000, and you would get back the remaining 29,000. However, if you specify too little gas, for example, a gas limit of 20,000 for a simple ETH transfer, the transaction will fail during the validation phase. t will be rejected before being included in a block, and no gas will be consumed.

On the other hand, if a transaction runs out of gas during execution (e.g., a smart contract uses up all the gas halfway), the EVM will revert any changes, but all the gas provided will still be consumed for the work performed.

# What are Ethereum nodes and clients?
A 'node' is any instance of Ethereum client software that is connected to other computers in the Ethereum network.

A node has to run two clients: an execution client and a consensus client.
- The execution client (also known as the Execution Engine, EL client or formerly the Eth1 client) listens to new transactions broadcasted in the network, executes them in EVM, and holds the latest state and database of all current Ethereum data.
- The consensus client (also known as the Beacon Node, CL client or formerly the Eth2 client) implements the proof-of-stake consensus algorithm, which enables the network to achieve agreement based on validated data from the execution client. 

Node types:
- Full node, they do a block-by-block validation of the blockchain, including downloading and verifying the block body and state data for each block. Full nodes only keep a local copy of relatively recent data (typically the most recent 128 blocks), allowing older data to be deleted to save disk space.
- Archive node, verify every block from genesis and never delete any of the downloaded data.
- Light node, only download block headers (contain summary info about the content of the block). Any other info the light node requires gets requested from a full node. The light node can then independently verify the data they receive against the state roots in the block headers.

# What are Ethereum networks?
Ethereum networks are groups of connected computers that communicate using the Ethereum protocol. There is only one Ethereum Mainnet, but independent networks conforming to the same protocol rules can be created for testing and development purpose.

Public networks
- Ethereum Mainnet, the primary public Ethereum production blockchain, where actual-value transactions occur on the distributed ledger.
- Ethereum Testnets, used by protocol developers or smart contract developers to test both protocol upgrades as well as potential smart contracts in a production-like environment before deployment to Mainnet. Sepolia is the recommended default testnet for Dapp development.

Private networks
- Development networks, a local blockchain instance to test dApps.
- Consortium networks, the consensus process is controlled by a pre-defined set of nodes that are trusted.

# What is consensus?
By consensus, we mean that a general agreement has been reached. In regard to the Ethereum blockchain, the process is formalized, and reaching consensus means that at least 66% of the nodes on the network agree on the global state of the network.

# What is consensus mechanism?
It refers to the entire stack of protocols, incentives and ideas that allow a network of nodes to agree on the state of a blockchain.
Ethereum uses a proof-of-stake-based consensus mechanism that derives its cypto-economic security from a set of rewards and penalties applied to capital locked by stakers.
This incentive structure encourages individual stakers to operate honest validators, punishes those who don't, and creates an extremely high cost to attack the network.

# Types of consensus mechanisms
```
| Category                     | Proof-of-Work (PoW)                         | Proof-of-Stake (PoS)                              |
| ---------------------------- | ------------------------------------------- | ------------------------------------------------- |
| Example Networks             | Bitcoin, early Ethereum                     | Modern Ethereum                                   |
| Who Creates Blocks           | Miners compete using computing power        | Validators selected based on staked tokens        |
| How Block Producer Is Chosen | First miner to solve a cryptographic puzzle | Random selection weighted by amount of ETH staked |
| Resource Used                | Massive computational power & electricity   | Locked cryptocurrency stake                       |
| Reward                       | Block reward + transaction fees             | Staking rewards + transaction fees                |
| Security Model               | Attacker needs 51% of global hash power     | Attacker needs large percentage of staked tokens  |
| Cost of Attack               | Buy/operate huge mining hardware and energy | Acquire and risk losing large amounts of crypto   |
| Energy Consumption           | Very high                                   | Low compared to PoW                               |
| Fork Choice Rule             | Chain with most accumulated work            | Chain with highest attestation weight             |
| Penalty for Misbehavior      | Usually none beyond wasted electricity      | Slashing (validators lose part of their stake)    |
| Hardware Requirement         | Specialized mining hardware (ASICs/GPUs)    | Regular servers; stake is the main requirement    |
| Speed & Efficiency           | Slower and energy intensive                 | Faster, more energy efficient                     |
```
```
One-sentence summary:
PoW: security comes from computational work.
PoS: security comes from economic stake at risk.
```