# contract

Example cairo contract using the StarkNet (mostly taken from documentation).

## Usage

```
$ ./contract.sh
```

**Before you run it, this will:**

1. Prepare and publish the cairo contract
2. Receive a public balance
3. Receive a public balance using a key identifier
4. Increase that public balance
5. Receive the changed public balance

## What I learned using this example

- StarkNet will publish the same contract over and over again, allowing for the same contract to have different storages.
- Each contract not just has storage addresses, but those storage addresses are using hashes of the name internally.
- StarkNet's vocabulary differentiates between a `invoke`(invocation) and a `call`. Invocations cause transactions where calls dont.
    Calls contain the changes that invocations cause **before** the invocations are anchored in Ethereum (State: PENDING).
    (It takes about 2 minutes to enter PENDING state but ~10 for it to enter ACCEPTED_ONCHAIN).

## Open Questions

- What is the exact structure of blockchain transactions for an `invocation`?
- Could there be notification system for changes?
- What is the "storage" cost/limitations of StarkNet?
- Will this be free forever?
