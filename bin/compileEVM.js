#!/usr/bin/env node
const transcompiler = require('../index.js')
const ethUtil = require('ethereumjs-util')

transcompiler.compile(ethUtil.toBuffer(process.argv[2]))
