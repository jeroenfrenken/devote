<template>
  <div v-if="electionName === ''">
    Loading....
  </div>
  <div v-else>
    <h1>{{ electionName }}</h1>
    <p>Manager: {{ manager.address }} // FT: {{ ft.address }}</p>
    <p>paused: {{ paused }}</p>
    <p>cap: {{ cap }}</p>
    <p>symbol: {{ symbol }}</p>
    <p>totalSupply: {{ totalSupply }}</p>
  </div>
</template>

<script lang="ts">
import TruffleContract from '@truffle/contract';
import {Component, Vue} from 'vue-property-decorator';
import * as Web3 from 'web3';

@Component
export default class FT extends Vue {
  public electionName = '';
  public paused = false;
  public cap = 0;
  public symbol = '?';
  public totalSupply = 0;

  // This hold's the instance of the smart contract created by truffle
  public manager: TruffleContract | undefined = undefined;
  public ft: TruffleContract | undefined = undefined;

  // Access to the web3 api
  public web3: Web3 | undefined = undefined;

  public async created() {
    await this.initWeb3AndProvider();

    // Fetch our compiled smart contracts
    const managerContract = await this.loadContract('/contracts/ElectionFTManager.json');
    this.manager = await managerContract.deployed();
    const ftAddress = await this.manager.ft();
    const ftContract = await this.loadContract('/contracts/ElectionFT.json');
    this.ft = await ftContract.at(ftAddress);
    console.log(ftAddress);
    this.electionName = await this.ft.name();
    this.paused = await this.ft.paused();
    this.cap = await this.ft.cap();
    this.symbol = await this.ft.symbol();
    this.totalSupply = await this.ft.totalSupply();
  }

  private async loadContract(source: string) {
    const response = await fetch(source);
    const decodedJson = await response.json();

    const contract = TruffleContract(decodedJson);
    contract.setProvider(this.provider);

    return contract;
  }

  private async initWeb3AndProvider() {
    let provider;
    const isValid = await this.isEthApiAvailable();

    // Load provider
    if (isValid) {
      provider = window.ethereum;
    } else {
      provider = new Web3.providers.WebsocketProvider('ws://localhost:8546');
    }

    this.web3 = new Web3(provider);
    this.provider = provider;
  }

  private async fetchAccount(): Promise<string | undefined> {
    try {
      const accounts = await this.web3.eth.getAccounts();
      if (accounts.length > 0) {
        return accounts[0];
      } else {
        return undefined;
      }
    } catch (e) {
      window.alert('Afgebroken door de gebruiker');
      return undefined;
    }
  }

  public async fetchElectionName(): Promise<string> {
    return await this.manager.electionName();
  }

  public async isEthApiAvailable(): Promise<boolean> {
    if (window.ethereum) {
      try {
        await window.ethereum.enable();
        return true;
      } catch (error) {
        return false;
      }
    } else {
      return false;
    }
  }
}
</script>

<style lang="scss" scoped>
</style>
