# Guarded Feedback Smart Contract Documentation

## Overview

The Guarded Feedback Smart Contract presented here is built using the Leo language for the Aleo blockchain. It establishes a decentralized feedback system allowing users to submit reports, respond to existing reports, claim rewards, and transfer tokens privately or publicly. The contract incorporates zero-knowledge proof functionality to ensure the privacy and security of user interactions.

## Structures and Mappings

### `Settings` Struct

- `owned_by`: An `address` representing the owner of the Guarded Feedback DApp.

### `Report` Struct

- `id`: A unique `field` representing the report identifier.
- `counter`: An `u128` indicating the report counter.
- `block_height`: An `u32` indicating the block height of the report.
- `content`: A `field` containing the report content.
- `solved`: A `bool` indicating whether the issue has been resolved.
- `comment`: A `field` for additional comments or information.
- `rewards`: An `u64` representing the rewards associated with the report.
- `claimed`: A `bool` indicating whether the rewards have been claimed.

### Mappings

- `settings: u8 => Settings`: A mapping to store DApp configuration settings, where `u8` key represents the configuration version.
- `reports: u128 => Report`: A mapping allowing querying of reports by their counter.
- `ids: field => u128`: A mapping allowing querying of reports by their unique identifier.
- `counter: u8 => u128`: A mapping to enable counting the reports at the key `0u8`.
- `account: address => u64`: On-chain storage of an `account` map, with `address` as the key and `u64` as the value.

### Records

- `token`: A record representing a token with `owner` as `address` and `amount` as `u64`.
- `reported`: A record used to store the reports a user has made in the past privately, with `owner` as `address` and `id` as `field`.

## Smart Contract Functions

### `initialize_contract(public new_owner: address)`

The `initialize_contract` function configures the DApp by setting the initial owner. It is used during contract initialization.

### `transfer_ownership(new_owner: address)`

Allows the current owner to transfer ownership to a new address. Requires verification of the current owner.

### `submit(private content: field) -> (field, reported)`

Allows users to submit content to the DApp. Generates a unique ID for the submission and creates a new report.

### `respond(public number: u128, public comment: field, public rewards: u64, public solved: bool)`

Allows users to respond to a specific report. Users can provide comments, rewards, and indicate if the issue has been solved.

### `claim(private number: u128, private content: field, private rewards: u64) -> token`

Allows users to claim rewards associated with a specific report. Validates the claim and pays out the rewards.

### `transfer_public(public receiver: address, public amount: u64)`

Transfers tokens publicly from the caller's account to the specified receiver's account.

### `transfer_private(sender: token, receiver: address, amount: u64) -> (token, token)`

Transfers tokens privately from the sender's account to the specified receiver's account.

### `transfer_private_to_public(sender: token, public receiver: address, public amount: u64) -> token`

Converts specified tokens from a private token record into public tokens for the specified receiver.

### `transfer_public_to_private(public receiver: address, public amount: u64) -> token`

Converts specified public tokens from the caller's account into private tokens for the specified receiver.

### `burn_public(public amount: u64)`

Burns a specified amount of public tokens from the caller's account.

## Notes

- Ensure proper configuration and ownership management using `initialize_contract` and `transfer_ownership` functions.
- Use `submit`, `respond`, and `claim` functions to interact with the feedback system.
- Token transfers can be made publicly using `transfer_public` and privately using `transfer_private`. Conversion functions are available for public-to-private and private-to-public transfers.
- Use appropriate security measures and validation logic in external applications interacting with this smart contract.

## Installation

```bash
git clone https://github.com/AleoHQ/snarkVM
cd snarkvm
$ cargo install --path .
```

## Deployments

### guarded_feedback_0_0_2.aleo

https://vm.aleo.org/api/testnet3/transaction/

deployed at txID:
https://vm.aleo.org/api/testnet3/transaction/at17fz97878aeu2a5zt5pzxhxaeqlse3x4mgq8zp9q3eekw70v4pc8sa9vg2n

initialize_contract:
["aleo124ymewxg2pdkln4kmrx4p28hvjclaq6a9f0zf6skkxa49lwrrvpqur629y"]
at17cwdu4v0lahs2sch36zfvpqq2tpc0r2exv8r0m43ev34wvpje59qwttkek

submit:
input = ["901305943116055393314107185019430750261130105947222795572321109111376field"]
tx = at1v72se96g50634qsue4ahyqz4892q7ruh95as8k4r228xqtudsuyq49rtx4

respond:
input = ["2u128","230869337133923446780812989509191305324637662730303006842384793784117332field","100u64","true"]
tx = at157rdwjdkmmjxjrh6v6mud4ctx9xhug9v48puqx47p6clgvef0uqs872leu

claim:
input = ["2u128","13752837266785513203645434234054352649775892694779801526508417648field","100u64"]
tx = at1pjx27dsdaeyazvkts9hhu6j54qcmnh2gxcqjvk9u7e3knpcewsrq77ezw6

# TODO

- run through claim process
