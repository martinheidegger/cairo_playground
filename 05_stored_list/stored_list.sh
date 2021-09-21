#!/bin/bash
source ~/cairo_venv/bin/activate

cd "$(dirname $0)"

source ../utils/contract.sh

prepare_and_use_contract "stored_list"

KEY=`create_private_key`
KEY2=`create_private_key`
KEY3=`create_private_key`
KEY4=`create_private_key`

function add_key {
    CONTENT=`contract_invoke push_key "${USER} ${1}"`
    TRANSACTION_ID=`transaction_id "${CONTENT}"`

    echo "${CONTENT}"

    await_tx_pending "${TRANSACTION_ID}"
}

echo "> Creating a user"

    USER=`create_private_key`

echo "> Finding the index of unknown key"

    MINUS_ONE=`contract_call get_minus_one ""`
    INDEX=`contract_call get_key_index "${USER} $(create_private_key)"`

    echo "   -1: ${MINUS_ONE}"
    echo "INDEX: ${INDEX}"

echo "> Receiving count of keys at ${CONTRACT_ADDRESS} for ${USER}"

    KEYS=`contract_call get_key_count ${USER}`
    echo "${KEYS}"

echo "> Adding key ${KEY} to the user ${USER}"

    add_key "${KEY}"
    contract_get_list "key" "${USER}" | jq


echo "> Adding another key '${KEY2}' to the list"

    add_key "${KEY2}"

    contract_get_list "key" "${USER}" | jq

echo "> Replacing key at index 1 with '${KEY3}'"

    CONTENT=`contract_invoke set_key_at "${USER} ${KEY3} 1"`
    TRANSACTION_ID=`transaction_id "${CONTENT}"`

    echo "${CONTENT}"

    await_tx_pending "${TRANSACTION_ID}"

    contract_get_list "key" "${USER}" | jq

echo "> Removing the last entry from the list"

    CONTENT=`contract_invoke pop_key "${USER}"`
    TRANSACTION_ID=`transaction_id "${CONTENT}"`

    echo "${CONTENT}"

    await_tx_pending "${TRANSACTION_ID}"

    contract_get_list "key" "${USER}" | jq

echo "> Adding a few keys"

    add_key "${KEY2}"
    add_key "${KEY3}"
    add_key "${KEY4}"

    contract_get_list "key" "${USER}" | jq

echo "> Finding the index of ${KEY3}"

    contract_call get_key_index "${USER} ${KEY3}"

echo "> Finding the index of a unknown key"

    contract_call get_key_index "${USER} abcd"

echo "> Removing key at 1"

    CONTENT=`contract_invoke remove_key_at "${USER} 1"`
    TRANSACTION_ID=`transaction_id "${CONTENT}"`

    echo "${CONTENT}"

    await_tx_pending "${TRANSACTION_ID}"

    contract_get_list "key" "${USER}" | jq
