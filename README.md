# ![Technical Architecture](<Untitled Diagram.drawio.png>)

# CkMaticDeposit Contract

The CkMaticDeposit contract is designed to facilitate the conversion of MATIC to ckMATIC by handling deposits of MATIC, transferring them to a designated minter address, and allowing for withdrawals under specified conditions. This contract is primarily used in a decentralized finance (DeFi) context on the Polygon blockchain.

## Features

- Deposit Handling: Accepts MATIC deposits to be converted into ckMATIC.
- Minter Management: Allows the designated minter to manage MATIC and handle conversion processes.
- Withdrawal Authorization: Permits the withdrawal of MATIC under certain conditions managed by the minter.

### Smart contract address

- [Polygon Testnet](https://amoy.polygonscan.com/address/0xb4e7369230508f76c1472f1bf2d8e7d54a6c6900)

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeployTokenLock.s.sol:DeployTokenLock --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast

```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
