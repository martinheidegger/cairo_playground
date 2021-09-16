#!/bin/bash
source ~/cairo_venv/bin/activate

cd "$(dirname $0)"

source ../utils/contract.sh

prepare_and_use_contract "proxy_contract"

TARGET_CONTRACT=`cat ../02_contract/contract.address`

echo "> Receiving the balance at ${TARGET_CONTRACT} from ${CONTRACT_ADDRESS}"

    BALANCE=`contract_call call_get_balance ${TARGET_CONTRACT}`
    echo "${BALANCE}"

echo "> Incrementing contract at ${TARGET_CONTRACT} from ${CONTRACT_ADDRESS} at $(date)"
    CONTENT=`contract_invoke call_increase_balance "${TARGET_CONTRACT} 1234"`

    echo "${CONTENT}"
    TRANSACTION_ID=`transaction_id "${CONTENT}"`

    await_tx $TRANSACTION_ID

echo "> Receiving the balance at ${TARGET_CONTRACT} from ${CONTRACT_ADDRESS}"

    BALANCE=`contract_call call_get_balance ${TARGET_CONTRACT}`
    echo "${BALANCE}"
