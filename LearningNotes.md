# What is a blockchain?
A blockchain is a public database that is updated and sahred across many computers in a network.

# What are blocks?
Blockers are batches of transactions with a hash of the previous block in the chain.

# What is Ethereum?
Ethereum is a blockchain with a single, canonical computer (Ethereum Virtual Machine) embedded in it. It is the foundation for building apps and organizations in a decentralized, permisionless, censorship-resistant way.

# What is ether?
Ether(ETH) is the native cryptocurrency of Ethereum. The purpose of ETH is to allow for a market for computation. Such a market provides an economic incentive for participants to verify and execute transaction requests and provide computational resources to the network.

# What are smart contracts?
Smart contracts are turning complete programs published into EVM state, they can be called with certain parameters, perform some actions or computation if certain condition are satified. They are often also called dapps, or decentralized apps.

# What are Ethereum Accounts?
An Ethereum account is an entity with an ether (ETH) balance that can send messages on Ethereum. Accounts can be user-controlled or deployed as smart contracts.

# What are Transactions?
Transactions are cryptographically signed instructions from accounts. An account will initiate a transaction to update the state of the Ethereum network.

The simplest transaction is transferring ETH from one account to another.

# What is Ethereum virtual machine (EVM)?
The Ethereum Virtual Machine (EVM) is a decentralized virtual environment that executes code consistently and securely across all Ethereum nodes.

When a transaction calls a smart contract, the Ethereum Virtual Machine executes the contract’s compiled bytecode instruction-by-instruction on a stack-based machine across all nodes, consuming gas and updating the blockchain state deterministically if execution succeeds.

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