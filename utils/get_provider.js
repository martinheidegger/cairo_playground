#!/usr/bin/env node
const { getEthereumProvider, destroyProvider } = require('./eth.js')

const provider = getEthereumProvider()
console.log(`${provider.constructor.name}#${provider.apiKey}`)
destroyProvider()
