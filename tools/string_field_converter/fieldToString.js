#!/usr/bin/env node
const readline = require('readline');

function bigIntToString(bigIntValue) {
  const bytes = [];
  let tempBigInt = bigIntValue;

  while (tempBigInt > BigInt(0)) {
    const byteValue = Number(tempBigInt & BigInt(255));
    bytes.push(byteValue);
    tempBigInt = tempBigInt >> BigInt(8);
  }

  const decoder = new TextDecoder();
  const asciiString = decoder.decode(Uint8Array.from(bytes));
  return asciiString;
}

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question('Enter a field to convert to a string: ', (inputField) => {
  // Check if the input string ends with "field"
  if (inputField.endsWith('field')) {
    const numericPart = inputField.slice(0, -5); // Remove "field" suffix
    const fieldBigInt = BigInt(numericPart);
    const resultString = bigIntToString(fieldBigInt);
    console.log('Generated String:', resultString);
  } else {
    console.log('Invalid input. Please provide a field in the format "12345field".');
  }

  rl.close();
});
