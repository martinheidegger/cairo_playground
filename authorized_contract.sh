#!/bin/bash
source ~/cairo_venv/bin/activate
source ./utils/contract.sh

prepare_and_use_contract "authorized_contract"

echo "> Create User"

    PRIVATE_KEY=`create_private_key`
    PUBLIC_KEY=`public_key_from_private_key $PRIVATE_KEY`

    echo "PRIVATE_KEY: ${PRIVATE_KEY}"
    echo "PUBLIC_KEY: ${PUBLIC_KEY}"

echo "> Receiving the balance at ${CONTRACT_ADDRESS} for ${PUBLIC_KEY}"

    BALANCE=`contract_call get_balance ${PUBLIC_KEY}`
    echo "${BALANCE}"

echo "> Increase balance (invalid signature)"

    CHANGE="4321"
    SIGNATURE="1 1"

    CONTENT=`contract_invoke increase_balance "${PUBLIC_KEY} ${CHANGE} ${SIGNATURE}"`
    echo "${CONTENT}"

    await_tx `transaction_id "${CONTENT}"`

echo "> Increase balance of ${PUBLIC_KEY} at ${CONTRACT_ADDRESS}"

    CHANGE="4321"
    SIGNATURE=`sign_message ${PRIVATE_KEY} ${CHANGE}`
    echo "Signature: $SIGNATURE"

    CONTENT=`contract_invoke increase_balance "${PUBLIC_KEY} ${CHANGE} ${SIGNATURE}"`
    echo "${CONTENT}"

    await_tx `transaction_id "${CONTENT}"`

echo "> Receiving the balance at ${CONTRACT_ADDRESS} for ${PUBLIC_KEY}"

    BALANCE=`contract_call get_balance ${PUBLIC_KEY}`
    echo "${BALANCE}"
