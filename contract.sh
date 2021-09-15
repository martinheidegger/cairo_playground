#!/bin/bash
source ~/cairo_venv/bin/activate

NAME="contract"

SHA=`shasum "${NAME}.cairo" 2> /dev/null || echo ""`
PREV_SHA=`cat "${NAME}.cairo.sha" 2> /dev/null || echo ""`
CONTRACT_ADDRESS=`cat "${NAME}.address" 2> /dev/null || echo ""`

# If not exported as variable, it needs to be set with every starknet command
export STARKNET_NETWORK=alpha

if [[ $PREV_SHA != $SHA || $CONTRACT_ADDRESS == "" ]]; then
    echo "> Compiling ${NAME}.cairo"
        starknet-compile ${NAME}.cairo \
            --output ${NAME}_compiled.json \
            --abi ${NAME}_abi.json

        cat ${NAME}_abi.json | jq .

    function contract_address () {
        regex='Contract address: (0x[a-f0-9]*)'
        [[ $1 =~ $regex ]];
        echo ${BASH_REMATCH[1]}
    }

    echo "> Deploying to Starknet: ${STARKNET_NETWORK}"
        CONTENT=$(starknet deploy --contract ${NAME}_compiled.json)

        echo "${CONTENT}"
        CONTRACT_ADDRESS=$(contract_address "${CONTENT}")

    echo "${CONTRACT_ADDRESS}" > "${NAME}.address"
    echo "${SHA}" > "${NAME}.cairo.sha"
else
    echo "> Already compiled and deployed at address ${CONTRACT_ADDRESS}"
fi

function transaction_id () {
    regex='Transaction ID: ([a-f0-9]*)'
    [[ $1 =~ $regex ]];
    echo ${BASH_REMATCH[1]}
}

echo "> Receiving the balance at ${CONTRACT_ADDRESS}"

    BALANCE=`starknet call \
        --address ${CONTRACT_ADDRESS} \
        --abi ${NAME}_abi.json \
        --function get_balance
    `
    echo "${BALANCE}"

echo "> Receiving the balance using a key"
    BALANCE_KEY=`python3 -c "from starkware.starknet.public.abi import get_storage_var_address

print(get_storage_var_address('balance'))"`

    echo "Balance Key: ${BALANCE_KEY}"

    BALANCE=`starknet get_storage_at \
        --contract_address ${CONTRACT_ADDRESS} \
        --key ${BALANCE_KEY}`
    
    echo "${BALANCE}"

echo "> Incrementing contract at ${CONTRACT_ADDRESS} at $(date)"
    CONTENT=`starknet invoke \
        --address ${CONTRACT_ADDRESS} \
        --abi ${NAME}_abi.json \
        --function increase_balance \
        --inputs 1234`

    echo "${CONTENT}"
    TRANSACTION_ID=`transaction_id "${CONTENT}"`

while :; do
    STATUS=`starknet tx_status --id ${TRANSACTION_ID} | jq -r .tx_status`
    if [[ $STATUS == "ACCEPTED_ONCHAIN" ]]; then
        echo "> ${STATUS} $(date)"
        break
    elif [[ $STATUS == "NOT_RECEIVED" || $STATUS == "REJECTED" ]]; then
        echo "> ${STATUS} $(date)"
        exit 1
    else
        echo "... ${STATUS} $(date)"
        sleep 10
    fi
done

echo "> Receiving the balance at ${CONTRACT_ADDRESS}"

    BALANCE=`starknet call \
        --address ${CONTRACT_ADDRESS} \
        --abi ${NAME}_abi.json \
        --function get_balance
    `
    echo "${BALANCE}"
