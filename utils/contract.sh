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

function contract_get_list {
    COUNT=`contract_call get_${1}_count "${2}"`
    INDEX=0
    JSON='['
    while [[ $INDEX < $COUNT ]]; do
        ENTRY=`contract_call get_${1}_at "${2} ${INDEX}"`
        if [[ $INDEX != 0 ]]; then
            JSON="${JSON}, \"${ENTRY}\""
        else
            JSON="${JSON}\"${ENTRY}\""
        fi
        INDEX=$(( $INDEX + 1 ))
    done
    echo "${JSON}]"
}

function await_tx_pending {
    while :; do
        STATUS=`starknet tx_status --id $1 | jq -r .tx_status`
        if [[ $STATUS == "ACCEPTED_ONCHAIN" || $STATUS == "PENDING" ]]; then
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
    # This function is unsafe and should only be used in tests
    # https://github.com/starkware-libs/cairo-lang/blob/7526bffb78ba64976c4f019b04d059992b43c734/src/starkware/python/utils.py#L121
    python3 -c "
from starkware.python.utils import (get_random_instance)

print(get_random_instance().getrandbits(250))"
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

function derive_key () {
    python3 -c "from starkware.starknet.public.abi import get_storage_var_address

print(hex(get_storage_var_address('${1}')))"
}

function derive_key_dec () {
    python3 -c "from starkware.starknet.public.abi import get_storage_var_address

print(get_storage_var_address('${1}'))"
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
            
            if [[ $? != 0 ]]; then
                exit 1
            fi

            cat ${NAME}_abi.json | jq .

        function contract_address () {
            regex='Contract address: (0x[a-f0-9]*)'
            [[ $1 =~ $regex ]];
            echo ${BASH_REMATCH[1]}
        }

        echo "> Deploying to Starknet: ${STARKNET_NETWORK}"
        CONTENT=$(starknet deploy --contract ${NAME}_compiled.json)

        echo "${CONTENT}"
        TX_ID=$(
            transaction_id "${CONTENT}")

        await_tx_pending $TX_ID

        export CONTRACT_ADDRESS=$(contract_address "${CONTENT}")

        echo "${CONTRACT_ADDRESS}" > "${NAME}.address"
        echo "${SHA}" > "${NAME}.cairo.sha"
    else
        echo "> Already compiled and deployed at address ${CONTRACT_ADDRESS}"
    fi
}
