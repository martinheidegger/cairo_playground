# blockchain_data

Example to understand blockchain call data stored for each call.
(based on 02)

## Usage

```
$ ./blockchain_data.sh
```

**Before you run it, this will:**

1. Invoke the contracted created in [02](../02_contract/Readme.md)
2. Wait for the transaction to be commited to L1.
3. Read the transaction data in L1.

## What I learned using this example

- Etherscan is not very reliant or fast in propagating ethereum events - even with API key - use Infura (INFURA_PROJECT_ID) for better results.
- The state in L1 will contain a hash of all the operations, that itself
can only be verified with additional data, only known by L2.
- If the transaction has interaction with L1, the data sent to L1 can naturally be read in L1. _(Note: this example doesn't show this - yet? - but other transactions that are bundled with ours have `L2 -> L1` data that showed this.)_
- Currently the `sequenceNumber` and `block_id` of a starknet transaction are equal but (according to chat) these numbers may differ in future and `sequenceNumber` needs to be used to identify the proper transaction on the block chain.
- Starknet could/should add a function get the related transaction in L1.
- `ethers` - the js ethereum library - doesn't support a streaming API to the event log. It is also not possible to filter events with a parameter property (which would be really useful).
- _(Learned some basic of how ethereum contracts store data and how its accessed)_
