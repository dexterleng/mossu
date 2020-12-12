const fs = require('fs');
const assert = require('assert');
const babel = require('@babel/core');
const path = require('path');

main();

function main() {
  const args = process.argv.slice(2);
  assert(args.length === 2);

  const srcFile = args[0];
  const dstFile = args[1];
  const dstEnclosingFolder = path.resolve(dstFile, '..')

  assert(fs.existsSync(srcFile));

  const code = fs.readFileSync(srcFile, 'utf-8').toString();
  const decommentedCode = decomment(code);

  fs.mkdirSync(dstEnclosingFolder, { recursive: true });
  fs.writeFileSync(dstFile, decommentedCode);
}

function decomment(code) {
  return babel.transformSync(code, {
    comments: false,
    babelrc: false,
  }).code;
}
