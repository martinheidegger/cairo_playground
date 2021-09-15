# If not exported as variable, it needs to be set with every starknet command
export STARKNET_NETWORK=alpha

function contract_invoke {
    starknet invoke \
        --address ${CONTRACT_ADDRESS} \
        --abi ${NAME}_abi.json \
        --function $1 \
        --inputs $2
}

function contract_call {
    if [ -z ${2+x} ]; then
        starknet call \
            --address ${CONTRACT_ADDRESS} \
            --abi ${NAME}_abi.json \
            --function $1
    else
        starknet call \
            --address ${CONTRACT_ADDRESS} \
            --abi ${NAME}_abi.json \
            --function $1 \
            --inputs $2
    fi
}

function await_tx {
    while :; do
        STATUS=`starknet tx_status --id $1 | jq -r .tx_status`
        if [[ $STATUS == "ACCEPTED_ONCHAIN" ]]; then
            echo "> ${STATUS} $(date)"
            break
        elif [[ $STATUS == "REJECTED" ]]; then
            echo "> ${STATUS} $(date)"
            starknet tx_status --id $1 | jq .tx_failure_reason
            break
        elif [[ $STATUS == "NOT_RECEIVED" ]]; then
            echo "> ${STATUS} $(date)"
            break
        else
            echo "... ${STATUS} $(date)"
            sleep 10
        fi
    done
}

function create_private_key {
    node -p "require('@consento/bigint-codec').bigUintLE.decode(crypto.randomBytes(31)).toString()"
}

function public_key_from_private_key {
    python3 -c "
from starkware.crypto.signature.signature import (private_to_stark_key)

print(private_to_stark_key($1))"
}

function sign_message {
    python3 -c "
from starkware.crypto.signature.signature import (pedersen_hash, sign)

private_key = $1
message_hash = pedersen_hash($2)
(r, s) = sign(msg_hash=message_hash, priv_key=private_key)
print(f'{r} {s}')"
}

function transaction_id () {
    regex='Transaction ID: ([a-f0-9]*)'
    [[ $1 =~ $regex ]];
    echo ${BASH_REMATCH[1]}
}

function prepare_and_use_contract {
    export NAME=$1
    SHA=`shasum "${NAME}.cairo" 2> /dev/null || echo ""`
    PREV_SHA=`cat "${NAME}.cairo.sha" 2> /dev/null || echo ""`
    export CONTRACT_ADDRESS=`cat "${NAME}.address" 2> /dev/null || echo ""`

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
        export CONTRACT_ADDRESS=$(contract_address "${CONTENT}")

        echo "${CONTRACT_ADDRESS}" > "${NAME}.address"
        echo "${SHA}" > "${NAME}.cairo.sha"
    else
        echo "> Already compiled and deployed at address ${CONTRACT_ADDRESS}"
    fi
}
