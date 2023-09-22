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

### guarded_feedback_0_8.aleo

https://vm.aleo.org/api/testnet3/transaction/

deployed at txID:
at1z0cwlvledvhwrsmhp78j7h9jve6nx46fu4kjftae694e4jykmursvnwj6f

configure:
["aleo124ymewxg2pdkln4kmrx4p28hvjclaq6a9f0zf6skkxa49lwrrvpqur629y"]
at1anw9rvlypxzsmlrpm6dtz04gt0lsgcgasgr7n7d26tq9vp59tv9saaucs8

submit:
input = ["1field"]
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
