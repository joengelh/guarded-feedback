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

## Tools

get records by:

```bash
cargo install snarkos
snarkos developer scan
```

## Notes

Input and output cant be the same twice
a failed transaction that fas failed on-chain costs fees and generates a new fee record

## Deployments

### guarded_feedback_0_8_0.aleo

https://vm.aleo.org/api/testnet3/transaction/

deployed at txID:
at1rw2muj3zhlqz3g006n38zvlrtc0kx5lhhysymn4avdm2v57exsrq85szvv

initialize_contract:
["aleo124ymewxg2pdkln4kmrx4p28hvjclaq6a9f0zf6skkxa49lwrrvpqur629y"]
at1897pyeyr9qjpwerjyeu2gynl322pheasezg4zpkhwqzc3f6f2gpqvrlz2y

submit:
input = ["1field"]
tx = at10gfwsd3za0nupt60exnnh9wzuzt64lwju3wsr5qdflamdzk7kqpqv96d7p

respond:
input = ["1u128","2field","100u64","true"]
tx = at1xf9edj3cn3zpdfqc7daln74whgmw8zdj6qxx0ae6xj3x40qcpsrq3vmtul

claim:
input = ["1u128","1field","100u64"]
tx = at1djprdpp0yqh2fj3de92h5af55ezfznv4lyzqcgnsmzhwd2qanqzqgu8n9e
