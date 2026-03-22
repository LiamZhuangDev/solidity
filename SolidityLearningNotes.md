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
| pure      | ❌         | ❌           | ❌          |
| view      | ✅         | ❌           | ❌          |
| normal    | ✅         | ✅           | ❌          |
| payable   | ✅         | ✅           | ✅          |
```

# Custom modifiers
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
# ERC20
ERC20 is a standard for fungible tokens on Ethereum. It defines a set of rules (functions + events) that every token contract must follow.
- ERC = Ethereum Request for Comments
- 20 = proposal number
- fungible tokens = all tokens are identical and interchangable. E.g. USDT, USDC, DAI.
- ERC20 tokens are NOT ETH, they live inside a contract, just numbers in a mapping. So No `.call{value:...}("")`.

Why ERC20 exists?
```
| Before ERC20                                    | After ERC20                                       |
| ------------------------------------------------| ------------------------------------------------- |
| Every token had different interfaces 😵         | ✅ Wallets (MetaMask) understand all tokens       |
| Wallets & exchanges couldn't interact easily    | ✅ DEXs (Uniswap) can trade any token             | 
|                                                 | ✅ Contracts can interact with tokens generically | 
```

1. Important State variables
- `balanceOf`, tracks how many tokens each address owns
```
mapping(address => uint256) public balanceOf;
```

- `allowance`, tracks permission to spend tokens
```
// owner -> spender -> amount
// owner = token holder
// spender = approved account (like a DEX)
// e.g. Alice allows Uniswap to spend 100 tokens
mapping(address => mapping(address => uint256)) public allowance;
```

- `totalSupply`, the total number of tokens in existence
```
uint256 public totalSupply;
```

- Matadata (optional but standard)
```
string public name;
string public symbol;
uint8 public decimals;
```

2. Core Functions (Must Have)
- `transfer`, move tokens from YOUR account to someone.
```
function transfer(address to, uint256 amount) public returns (bool);
```

- `approve`, allow someone else to spend your tokens.
```
function approve(address spender, uint256 amount) public returns (bool);
```

- `transferFrom`, spend tokens on behalf of someone else, used by DEXs, lending protocols, etc.
```
function transferFrom(address from, address to, uint256 amount) public returns (bool);
```

- How `approve` and `tranferFrom` work together
```
1. Alice calls: approve(Uniswap, 100)
2. Uniswap calls: transferFrom(Alice, Pool, 100)
This is how DeFi works.
```

3. Events (Very Important)
- `Transfer`, emitted when tokens move. Wallets rely on this to show balances.
```
event Transfer(address indexed from, address indexed to, uint256 value);
```

- `Approval`, emitted when approval is set.
```
event Approval(address indexed owner, address indexed spender, uint256 value);
```

# Contract Inheritance
- Constructors are executed from most base → most derived (GrandParent -> Parent1 -> Parent2 -> child)
- Solidity resolves inheritance from right to left 
```
Assuming foo exists, the precedence order is:
Child(super.foo()) -> Parent2(foo()) -> Parent1(foo()) -> GrandParent(foo())
```

```
contract GrandParent {}

contract Parent1 is GrandParent {}

contract Parent2 is GrandParent {}

contract Child is Parent1, Parent2 {}
```

# Contract, Abstract Contract and interface
In Solidity, `contract`, `abstract contract`, and `interface` all define blueprints for other contracts, but they differ in how complete they are and what they're allowed to contain.

- Contract (Concrete Contract), a regular contract is a fully implemented contract that can be deployed.
- Abstract Contract, an abstract contract is a partially implemented contract that cannot be deployed.
- Interface, an interface is a strict blueprint with no implementation at all.
```
| Feature             | contract  |  abstract contract  | interface     |
| ------------------- | --------- | ------------------- | ------------- |
| Deployable          | ✅        | ❌                  | ❌            |
| Function bodies     | ✅        | ✅ / ❌             | ❌            |
| State variables     | ✅        | ✅                  | ❌            |
| Constructors        | ✅        | ✅                  | ❌            |
| Inheritance         | ✅        | ✅                  | ✅            |
| Function visibility | any       | any                 | external only |
```

🧠 Intuition
- contract => “Fully built house” 🏠 (ready to live in).
- abstract contract => “Half-built house” 🚧 (needs finishing).
- interface => “Blueprint only” 📐 (no implementation at all).

# Solidity Library
A Solidity library is a specialized, reusable smart contract deployed once at a specific address (except libraries only have internal functions) to provide helper functions, reducing deployment gas costs and promoting modular code.
- `library` functions are referenced directly
- `internal` functions are inlined at compile time
- NO inheritance require

A Solidity library is stateless:
- ❌ cannot have its own persistent storage
- ❌ cannot declare state variables like a contract
- ❌ cannot hold balances or ownership

# using for directive
The Solidity `using for` directive is used to attach library functions as member functions to a specific data type.
```
using LibraryName for Type;
```