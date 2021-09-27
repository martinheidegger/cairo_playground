#!/usr/bin/env node
const { destroyProvider, waitForTransaction } = require('./eth.js')

waitForTransaction({
  stateRoot: `0x${process.argv[2]}`,
  sequenceNumber: parseInt(process.argv[3], 10)
})
  .then(data => {
    console.log(JSON.stringify(data, null, 2))
    destroyProvider()
  })
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
