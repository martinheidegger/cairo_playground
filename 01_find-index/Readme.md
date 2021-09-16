# find-index

Example cairo program, prooved using the SHARP

## Usage

```
$ ./find-index.sh
```

**Before you run it, this will:**

1. Compile the cairo program
2. Execute it with input variables
3. Verify the execution locally (without the input variables!)
4. Verify the execution using SHARP (stored on Ethereum)

## What I learned using this example

- We _could_ use arbritary python code to execute **but** for things to work we need to be able to verify in cairo code that work done by python was correct.
- `cairo-run` has many options, not all of them are suited to get the output. The example here works.
- The `.pie` files optionally created by `cairo-run` are essential to prooving. We can proove locally using `.pie` files.
- Once submitted, the SHARP proover will take a while (~5min) to process the statement.
- The SHARP proover's ethereum address is stored in the `starkware/cairo/sharp/config.json` of the python code
- The ethereum net which the SHARP proover uses can be found in the release notes.

## Open Questions

- Given the fact it is possible to verify that the execution was correct but how can the output of the cairo contract (2.) be tied to the created fact?
