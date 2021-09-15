#!/bin/bash
source ~/cairo_venv/bin/activate

# The contract address on ethereum can be found at following URL (it used to be necessary for verification)
SHARP_ADDRESS=$((cat "${VIRTUAL_ENV}/lib/python3.9/site-packages/starkware/cairo/sharp/config.json") | jq -r ".verifier_address")

# We need to use a Goerli testnet RPC URL for verification. Why Goerli? Because it is specified in the release notes...
NODE_URL="https://goerli-light.eth.linkpool.io/"

# Preparing parameterization
NAME="find-index"

echo "> Compiling ${NAME}.cairo"
    cairo-compile "${NAME}.cairo" --output "${NAME}_compiled.json"

echo "> Running ${NAME}.cairo with ${NAME}_input.json"
    cairo-run \
        --program="${NAME}_compiled.json" \
        --program_input="${NAME}_input.json" \
        --print_output \
        --layout=small \
        --cairo_pie_output="${NAME}_pie"

echo "> Verifying ${NAME}_pie"
    cairo-run \
        --layout=small \
        --run_from_cairo_pie="${NAME}_pie"

function job_key () {
    regex='Job key: ([a-f0-9-]*)'
    [[ $1 =~ $regex ]];
    echo ${BASH_REMATCH[1]}
}

function fact () {
    regex='Fact: (0x[a-f0-9]*)'
    [[ $1 =~ $regex ]];
    echo ${BASH_REMATCH[1]}
}

echo "> Sharpening ${NAME} at $(date)"
    CONTENT=`cairo-sharp \
        submit \
        --source "${NAME}.cairo" \
        --program_input "${NAME}_input.json"
    `
    echo "$CONTENT"
    JOB_KEY=$(job_key "${CONTENT}")
    FACT=$(fact "${CONTENT}")


echo "> Submitted to goerli ${SHARP_ADDRESS} at $(date) with job: ${JOB_KEY} and fact: ${FACT}"

while :; do
    STATUS=`cairo-sharp status ${JOB_KEY}`
    if [[ $STATUS == "PROCESSED" ]]; then
        echo "> Processed at $(date)"
        break
    else
        echo "... ${STATUS}"
        sleep 10
    fi
done

echo "> Is Fact Verified: $(cairo-sharp is_verified ${FACT} --node_url=${NODE_URL})"
