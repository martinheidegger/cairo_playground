const ethers = require('ethers')

// from https://goerli.etherscan.io/address/0x5e6229F2D4d977d20A50219E521dE6Dd694d45cc
// via https://www.cairo-lang.org/docs/hello_starknet/index.html
const STARKNET_CONTRACT_ADDRESS = '0x5e6229F2D4d977d20A50219E521dE6Dd694d45cc'

// We know this because it is written like this in the documentation
const STARKNET_NETWORK = 'goerli'

// The LogStateUpdate abi from the STARKnet smart contract is the only one relevant.
const LOG_STATE_UPDATE = new ethers.utils.Interface([ `event LogStateUpdate (uint256 globalRoot, int256 sequenceNumber)` ])

let provider

function getEthereumProvider () {
  if (provider !== undefined) {
    return provider
  }
  if (process.env.INFURA_PROJECT_ID) {
    provider = new ethers.providers.InfuraWebSocketProvider(STARKNET_NETWORK, {
      projectId: process.env.INFURA_PROJECT_ID,
    })
  } else {
    provider = new ethers.providers.EtherscanProvider(STARKNET_NETWORK, process.env.ETHERSCAN_API_KEY)
  }
  provider.on('error', err => {
    console.log({ err })
  })
  return provider
}

function destroyProvider () {
  if (provider === undefined) {
    return
  }
  if (provider.destroy) {
    provider.destroy()
  }
  provider = undefined
}

function getStarknetUpdateContract () {
  return new ethers.Contract(
    STARKNET_CONTRACT_ADDRESS,
    LOG_STATE_UPDATE,
    getEthereumProvider()
  )
}

async function getTransaction (updateStateTransactionID) {
  const tx = await getEthereumProvider().getTransaction(updateStateTransactionID)

  // Note: the arguments are taken from the contract, these are the
  // input variables of the startnet "updateState" write interface
  //
  // https://github.com/ethers-io/ethers.js/issues/423#issuecomment-462914041
  const [
    sequence_number, program_output, data_availability_fact
  ] = ethers.utils.defaultAbiCoder.decode(
    [ 'int256', 'uint256[]', '(uint256,uint256)' ],
    ethers.utils.hexDataSlice(tx.data, 4)
  )
  return {
    sequence_number: sequence_number.toBigInt().toString(),
    program_output: program_output.map(entry => entry.toBigInt().toString()),
    data_availability_fact: {
      onchainDataHash: data_availability_fact[0].toBigInt().toString(),
      onchainDataSize: data_availability_fact[1].toNumber()
    }
  }
}

function waitForTransaction (input) {
  return new Promise((resolve, reject) => {
    const contract = getStarknetUpdateContract()
    contract.on('error', reject)
    contract.on(
      {
        address: STARKNET_CONTRACT_ADDRESS,
        topics: [
          // To get the correct transaction topic we are NOT allowed to specify spaces or argument names!
          ethers.utils.id('LogStateUpdate(uint256,int256)')
        ]
      },
      (...data) => {
        try {
          const [globalRootRaw, sequenceNumberRaw, eventData] = data
          if (
            globalRootRaw.toHexString() === input.stateRoot &&
            sequenceNumberRaw.toNumber() === input.sequenceNumber
          ) {
            resolve(eventData)
          }
        } catch (err) {
          reject(err)
        }
      },
    )
  })
}

module.exports = {
  getTransaction,
  waitForTransaction,
  getStarknetUpdateContract,
  getEthereumProvider,
  destroyProvider
}
