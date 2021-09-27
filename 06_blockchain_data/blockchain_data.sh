#!/bin/bash
source ~/cairo_venv/bin/activate

cd "$(dirname $0)"

source ../utils/contract.sh

prepare_and_use_contract "../02_contract/contract"

echo "> Increase contract and wait for transaction pending"

    CONTENT=`contract_invoke increase_balance 1234`
    echo "${CONTENT}"

    TX_ID=`transaction_id "${CONTENT}"`

    echo "TX_ID: ${TX_ID}"

    await_tx_pending ${TX_ID}

echo "> Wait for transaction to arrive at L1"

    BLOCK_ID=`starknet tx_status --id ${TX_ID} | jq .block_id`
    echo "BLOCK_ID: ${BLOCK_ID}"
    BLOCK=`starknet get_block --id ${BLOCK_ID}`
    echo "${BLOCK}"

    STATE_ROOT=`echo "${BLOCK}" | jq -r .state_root`
    SEQUENCE_NUMBER=`echo "${BLOCK}" | jq -r .sequence_number`

    echo "Using Ethereum Provider: $(../utils/get_provider.js)"

    echo "... waiting for transaction to arrive in L1 ..."
    ETH_EVENT=`../utils/wait_for_transaction.js $STATE_ROOT $SEQUENCE_NUMBER`
    echo "${ETH_EVENT}" | jq

    ETH_TRANSACTION=`echo ${ETH_EVENT} | jq -r .transactionHash`
    echo "ETH_TRANSACTION: ${ETH_TRANSACTION}"

echo "> Extract transaction data for L2 transaction"

    ../utils/get_transaction.js ${ETH_TRANSACTION} | jq
