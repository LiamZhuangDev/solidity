# EVM storage, memory and calldata
```
| Location | Where it lives             | Lifetime        | Mutable         | Typical Usage                                        | Gas Cost                  |
| -------- | -------------------------- | --------------- | --------------- | ---------------------------------------------------- | ------------------------- |
| storage  | blockchain state           | permanent       | yes             | state variables, mappings, persistent arrays         | most expensive            |
| memory   | EVM linear temporary RAM   | during the call | yes             | temp variables, return values, function computations | medium                    |
| calldata | transaction input buffer   | during the call | read-only       | external function parameters (arrays, structs)       | cheapest for large inputs |
| stack    | EVM stack (max 1024 slots) | during the call | yes             | local primitives variables (uint, bool, etc)         | cheapest                  |

Only dynamic arrays in storage support push() and pop().
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

# Contract call
In Ethereum, each contract transaction contains:
```
to: contract address
value: some ETH
data: some calldata
```
The `calldata` is the raw bytes sent with the transaction that specify:
1. which function to call
2. the arguments
```
calldata = [4 bytes function selector][encoded arguments]
```

Examples:
```
to: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
value: 1 ETH
data: 0x // empty calldata

to: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
value: 1 ETH
data: 0x12345678 // any data bytes
```

# receive() and fallback()
`receive()` and `fallback()` are special functions that are automatically executed when a contract receives a call that does not match any existing function.
They are mainly used for handling ETH transfers or unknown function calls.

`receive()` is executed when 1) the transaction sends ETH and 2) the calldata is empty.

`fallback()` is triggered when 1) the called function does not exist or 2) calldata exists but doesn't match any function.

```
incoming call
     │
     ▼
function exists?
     │
 ┌───┴───┐
 │       │
yes      no
 │       │
execute  calldata empty?
function │
         ├──── yes → receive()
         │
         └──── no  → fallback()
```

# visibility modifiers
`public`, `external`, `internal`, and `private` are visibility modifiers define where a function or state variable can be accessed from.
```
| Visibility | Same Contract        | Derived Contract     | Other Contracts  | External Users |
| ---------- | -------------------  | -------------------- | ---------------  | -------------- |
| public     | ✅                   | ✅                   | ✅               | ✅             |
| external   | ❌ (must use `this`) | ❌ (must use `this`) | ✅               | ✅             |
| internal   | ✅                   | ✅                   | ❌               | ❌             |
| private    | ✅                   | ❌                   | ❌               | ❌             |

```

# State mutability modifiers/specifiers
`view`, `pure`, and `payable` are state mutability modifiers that specify how a function interacts with blockchan state and Ether.
```
| Modifier  | Read state | Modify state | Receive ETH |
| --------- | ---------- | ------------ | ----------- |
| `pure`    | ❌         | ❌           | ❌          |
| `view`    | ✅         | ❌           | ❌          |
| normal    | ✅         | ✅           | ❌          |
| `payable` | ✅         | ✅           | ✅          |
```

# custom modifiers
Besides visibility modifiers and State mutability modifiers, we can define `custom modifiers` which are reusable piece of code that wraps a function to add pre-conditions, post-conditions, or common logic.
It is mainly used to:
- enforece access control
- validate conditions
- avoid repeating code across functions
Base syntax:
```
modifier modifierName() {
    // code before function
    _; // execute the original function body here
    // code after function
}

modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;
}

function withdraw() public onlyOwner {
    // only owner can execute
}
```