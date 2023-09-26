#!/usr/bin/env node
const readline = require('readline');

function stringToBigInt(input) {
  const encoder = new TextEncoder();
  const encodedBytes = encoder.encode(input);

  let bigIntValue = BigInt(0);
  for (let i = 0; i < encodedBytes.length; i++) {
    const byteValue = BigInt(encodedBytes[i]);
    const shiftedValue = byteValue << BigInt(8 * i);
    bigIntValue = bigIntValue | shiftedValue;
  }

  return bigIntValue;
}

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question('Enter a string to convert to a field: ', (inputString) => {
  const fieldBigInt = stringToBigInt(inputString);
  console.log('Generated Field:', fieldBigInt.toString() + 'field');
  rl.close();
});
