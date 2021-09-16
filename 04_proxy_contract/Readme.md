# proxy_contract

Example cairo contract calling the contract created in [02_contract](../02_contract)

_Note:_ This is an example how to call **any** other L2 contract, not just such a simple one.

## Usage

```
$ ./proxy_contract.sh
```

**Before you run it, this will:**

1. Prepare and publish the cairo contract
2. Receive the public balance of the contract created in 02
4. Increase the public balance of the contract created in 02
5. Receive the changed public balance of the contract created in 02

## What I learned using this example

- Calling contracts is not strict, you can call any contract. You could also call contracts that could implement the same abi but do different things and the use would be transparent
