# stored_list

Example starknet contract that contains a list of entries.
_(This has been tricky, as lists by keys are not native in cairo/starknet)_

## Usage

```
$ ./stored_list.sh
```

**Before you run it, this will:**

1. Prepare and publish the cairo contract
2. Receive the public balance of the contract created in 02
4. Increase the public balance of the contract created in 02
5. Receive the changed public balance of the contract created in 02

## What I learned using this example

- Running cairo code really takes alot of time. Using Python test code to make sure that the contract works before testing it in the live network, gives a great advantage. However, unlike all other pieces of code, the test system is requiring **exactly** python 3.7 - not python 3.9! So you need to make sure that the venv is of the exact version.
- Negative integers _can_ be used in cairo code but are treated in the API as number overflows. `-1` would be 
- Natively cairo doesn't help to store arrays or sets of data for a given item, but by using a hash of a key location we can use a similar structure in a contract.
- Instead of removing data it is enough to just reduce the size. In blockchain the history is preserved and the old entries won't go away. So we just keep them but the reader is not directly made aware of.
- There is a relatively good pattern of `get_<X>_count` for the length, `get_<X>_at` use `push_<X>` and `pop_<X>` to add/remove entries. `set_<X>_at` can be effective to remove/add a key in one operation. `get_<X>_index` is an easy operation that is helpful for other operations.
- Operations like `remove_<X>_at` or `remove_key` are a lot more complex to execute (ether cost).
