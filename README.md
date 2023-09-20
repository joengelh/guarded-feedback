# guarded_feedback.aleo

## Build Guide

To compile this Aleo program, run:

```bash
leo build
```

To execute this Aleo program, run:

```bash
leo run configure [""]
```

## Deployments

### guarded_feedback_0_4.aleo

https://vm.aleo.org/api/testnet3/transaction/

deployed at txID:
at1su7zn8rnf629pjxn6f2hyv0ww2eyny8kwzpgdmqcj80awul5tvxqtyfkpy

configure:
["100000u32", "100u64"]
at1zcq642054cj98su36t22g79k3whsw3ttywywg4qzcczgx6yqjvxszvxqrd

submit:

input = ["1field","100u64","100000u32"]
tx = at1en3cq6x7npycs6eenrt7c3u6wv0t4rlxgdupas243m80qwgpzszqczx425
output = 6299058510241351640367114846012269074869620680143172774364172560696649935347field
state = {
id: 6299058510241351640367114846012269074869620680143172774364172560696649935347field,
security_deposit: 100u64,
block_height: 620767u32,
content: 1field,
votes_yes: 0u128,
votes_no: 0u128,
voting: 720767u32,
accepted: false,
rejected: false,
solved: false,
comment: 0field,
rewards: 0u64,
claimed: false
}

vote_yes:

input = ["6299058510241351640367114846012269074869620680143172774364172560696649935347field"]
tx = at1tng508pz0v04w0ttc7ra86tsg48ktk0gkqf7l0neh7duyulwwuyssryd5y
state = {
id: 6299058510241351640367114846012269074869620680143172774364172560696649935347field,
security_deposit: 100u64,
block_height: 620767u32,
content: 1field,
votes_yes: 1u128,
votes_no: 0u128,
voting: 720767u32,
accepted: false,
rejected: false,
solved: false,
comment: 0field,
rewards: 0u64,
claimed: false
}

vote_no:

input = ["6299058510241351640367114846012269074869620680143172774364172560696649935347field"]
tx = at1277p40jh5p7yfaa9ptnyqagnx7svt7ju48gerdwhye2mlv6mrqysgqfjdt
state = {
id: 6299058510241351640367114846012269074869620680143172774364172560696649935347field,
security_deposit: 100u64,
block_height: 620767u32,
content: 1field,
votes_yes: 1u128,
votes_no: 1u128,
voting: 720767u32,
accepted: false,
rejected: false,
solved: false,
comment: 0field,
rewards: 0u64,
claimed: false
}

respond:

claim:

## TODO

# prevent multiple voting
