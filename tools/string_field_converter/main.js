#!/usr/bin/env node
const readline = require('readline');

function splitStringToBigInts(input) {
  const chunkSize = 16; // Chunk size to split the string
  const numChunks = Math.ceil(input.length / chunkSize);
  const bigInts = [];

  for (let i = 0; i < numChunks; i++) {
    const chunk = input.substr(i * chunkSize, chunkSize);
    const bigIntValue = BigInt('0x' + Buffer.from(chunk).toString('hex'));
    bigInts.push(bigIntValue);
  }

  return bigInts;
}

function joinBigIntsToString(bigInts) {
  let result = '';

  for (let i = 0; i < bigInts.length; i++) {
    const chunkString = Buffer.from(bigInts[i].toString(16), 'hex').toString();
    result += chunkString;
  }

  return result;
}

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question('Choose an operation (1 for String to BigInts, 2 for BigInts to String): ', (answer) => {
  if (answer === '1') {
    rl.question('Enter the string to transform: ', (inputString) => {
      const bigInts = splitStringToBigInts(inputString);
      console.log('Transformed BigInts:', bigInts);
      rl.close();
    });
  } else if (answer === '2') {
    rl.question('Enter the BigInts (comma-separated): ', (inputBigInts) => {
      const bigIntArray = inputBigInts.split(',').map(str => BigInt(str.trim()));
      const resultString = joinBigIntsToString(bigIntArray);
      console.log('Transformed String:', resultString);
      rl.close();
    });
  } else {
    console.log('Invalid choice. Please choose 1 or 2.');
    rl.close();
  }
});
