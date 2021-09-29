# Tests and findings studying Cairo-lang, SHARP resolvers and StarkNET

State: (ongoing)

## Why?

With the goal of reducing the cost of Ethereum interactions and to
learn techniques to increase privacy I am studying [Cairo Lang](https://www.cairo-lang.org/docs/index.html).

Cairo allows to write code that can be executed regularly with user-input,
or it can be executed with a reduced piece of data (pie) created during the first execution.

In the second execution one can verify that the first execution was done correctly
without knowing the input.

In short: we can proove that the execution of a piece of code happened, that the execution
was done on uncorrupted code without knowing the result.

## Goals

- Gain understanding :wink:.
- Automate the understanding by creating shell scripts that execute on their own, showing how parts of Cairo work.
- Figure out ways to make it easier to interact with the contracts.

## Prerequisites

To run any of the scripts you need to install the cairo version specified in [.cairorc](./.cairorc).

From part 06 on, you will need a modern version of Node.js and run `npm install` in this folder.  It would also be good to specify a `INFURA_PROJECT_ID` environment variable that can be setup at https://infura.io or - if that is a problem - a `ETHERSCAN_API_KEY` variable to avoid error messages when requesting code.

---

- [`01_find-index`](./01_find-index/Readme.md)
- [`02_contract`](./02_contract/Readme.md)
- [`03_authorized_contract`](./03_authorized_contract/Readme.md)
- [`04_proxy_contract`](./04_proxy_contract/Readme.md)
- [`05_stored_list`](./05_stored_list/Readme.md)
- [`06_blockchain_data`](./06_blockchain_data/Readme.md)
