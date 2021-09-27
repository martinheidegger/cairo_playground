#!/usr/bin/env node
const { getTransaction, destroyProvider } = require('./eth.js')

getTransaction(process.argv[2])
  .then(data => {
    console.log(JSON.stringify(data, null, 2))
    destroyProvider()
  })
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
