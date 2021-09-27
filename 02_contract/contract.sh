#!/bin/bash
source ~/cairo_venv/bin/activate

cd "$(dirname $0)"

source ../utils/contract.sh

prepare_and_use_contract "contract"

echo "> Receiving the balance at ${CONTRACT_ADDRESS}"

    BALANCE=`contract_call get_balance`
    echo "${BALANCE}"

echo "> Receiving the balance using a key"
    BALANCE_KEY=`derive_key_dec balance`

    echo "Balance Key: ${BALANCE_KEY}"

    BALANCE=`starknet get_storage_at \
        --contract_address ${CONTRACT_ADDRESS} \
        --key ${BALANCE_KEY}`
    
    echo "${BALANCE}"

echo "> Incrementing contract at ${CONTRACT_ADDRESS} at $(date)"
    CONTENT=`contract_invoke increase_balance 1234`

    echo "${CONTENT}"
    TRANSACTION_ID=`transaction_id "${CONTENT}"`

    await_tx $TRANSACTION_ID

echo "> Receiving the balance at ${CONTRACT_ADDRESS}"

    BALANCE=`contract_call get_balance`
    echo "${BALANCE}"
