# Commands

```bash
# Start Besu
./start.sh

# Stop Besu
./stop.sh

# Be sure to execute the following commands in the smart_contracts folder
cd smart_contracts

# Compile all smart contracts
truffle compile

# After creating the migration file
truffle migrate --network besu

# Accessing the console
truffle console --network besu

# Example accessing your smart contract based on (MyContract)
# Creating a shadow variable to your contract
const contract = await MyContract.deployed();

# access feature's on the contract
contract.set(1234)

# getting feature's on the contract
contract.get()
```
