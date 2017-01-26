const fs = require('fs')
const path = require('path')

const files = fs.readdirSync(__dirname).filter((file) => file.endsWith('.json'))

files.forEach((file) => {
  const json = require(path.join(__dirname, '/') + file)
  for (let testKey in json) {
    const test = json[testKey]
    if (!test.environment) {
      test.environment = {}
    }

    test.message.from = test.environment.origin
    delete test.environment.origin
  }
  console.log(file)
  fs.writeFileSync(path.join(__dirname, '/') + file, JSON.stringify(json, null, 2))
})
