const fs = require('fs')
const path = require('path')
const files = fs.readdirSync(__dirname).filter(file => file.slice(-5) === '.wast')

const obj = {}
files.forEach((file) => {
  obj[file] = fs.readFileSync(path.join(__dirname, file)).toString()
})

fs.writeFileSync(path.join(__dirname, 'wast.json'), JSON.stringify(obj))
