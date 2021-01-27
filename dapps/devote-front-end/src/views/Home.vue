<template>
  <div v-if="electionName === ''">
    Loading....
  </div>
  <div v-else>
    <h1>{{ electionName }}</h1>
    <h2>total aantal stemmen: {{ totalVotes }}</h2>
    <div class="candidates">
      <div v-for="(candidate, index) in candidates" :key="index" class="candidate">
        <h4>{{ candidate.name }}</h4>
        <h5>stemmen: {{ candidate.voteCount }} / {{ totalVotes }}</h5>
        <button :disabled="disableVote" @click.prevent="vote(index)">Stem</button>
      </div>
      <div class="candidate">
        <h4>Lege stem</h4>
        <h5>stemmen: {{ remainingVotes }} / {{ totalVotes }}</h5>
        <button :disabled="disableVote" @click.prevent="voteBlank()">Stem</button>
      </div>
    </div>
    <div v-if="isContractOwner">
      <h1>Admin</h1>
      <p>Voeg een nieuwe kandidaat toe</p>
      <input v-model="candidateInput" type="text" placeholder="Kandidaat naam"><br>
      <button @click.prevent="addCandidate">Aanmaken</button>
    </div>
  </div>
</template>

<script lang="ts">
import TruffleContract from '@truffle/contract';
import { Component, Vue } from 'vue-property-decorator';
import * as Web3 from 'web3';

interface Candidate {
  name: string;
  voteCount: number;
}

@Component
export default class Home extends Vue {
  public totalVotes = 0;
  public disableVote = false;
  public electionName = '';
  public candidateInput = '';
  public isContractOwner = false;
  public candidates: Candidate[] = [];

  // This hold's the instance of the smart contract created by truffle
  public instance: TruffleContract | undefined = undefined;

  // Access to the web3 api
  public web3: Web3 | undefined = undefined;

  public async created() {
    let provider;
    const isValid = await this.isEthApiAvailable();

    // Load provider
    if ( isValid ) {
      provider = window.ethereum;
    } else {
      this.disableVote = true;
      provider = new Web3.providers.WebsocketProvider('ws://localhost:8546');
    }

    this.web3 = new Web3(provider);

    // Fetch our compiled smart contract
    const response = await fetch('/contracts/Election.json');
    const decodedJson = await response.json();

    const Election = TruffleContract(decodedJson);
    Election.setProvider(provider);

    this.instance = await Election.deployed();

    // Set the total vote's and election name
    this.totalVotes = await this.fetchTotalVotes();
    this.electionName = await this.fetchElectionName();

    // Load candidates and check if user is contract owner
    await this.loadCandidates();
    await this.checkIsContractOwner();
  }

  public get remainingVotes() {
    let count = 0;

    this.candidates.forEach(c => count += c.voteCount);
    return this.totalVotes - count;
  }

  private async fetchAccount(): Promise<string | undefined> {
    try {
      const accounts = await this.web3.eth.getAccounts();
      if ( accounts.length > 0 ) {
        return accounts[ 0 ];
      }

      return undefined;
    } catch (e) {
      window.alert('Afgebroken door de gebruiker');
      return undefined;
    }
  }

  public async checkIsContractOwner(): Promise<void> {
    const account = await this.fetchAccount();
    if ( account === undefined ) return;

    const ownerAccount = await this.instance.owner();
    this.isContractOwner = ownerAccount === account;
  }

  /**
   * @isOwner
   *
   * Adds a new candidate to vote on
   */
  public async addCandidate(): Promise<void> {
    const account = await this.fetchAccount();
    if ( account === undefined ) return;

    await this.instance.addCandidate(this.candidateInput, {
      from: account
    });

    this.candidateInput = '';
  }

  /**
   * This will cast a vote on the blockchain
   *
   * @param id
   */
  public async vote(id: number): Promise<void> {
    if ( this.disableVote ) return;
    const account = await this.fetchAccount();
    if ( account === undefined ) return;

    await this.instance.vote(id, {
      from: account
    });
  }

  // This will cast a blank vote on the blockchain
  public async voteBlank(): Promise<void> {
    const account = await this.fetchAccount();
    if ( account === undefined ) return;

    await this.instance.blankVote({
      from: account
    });
  }

  // Load's all the candidate's from the blockchain
  public async loadCandidates(): Promise<void> {
    // Get the length of how many candidate's
    const candidateLength = await this.instance.getCandidateLength();
    const length = candidateLength.toNumber();

    // // For loop which fetches all the candidates by index
    for (let i = 0; i < length; i++) {
      const c = await this.instance.candidates(i);

      this.candidates.push({
        name: c.name,
        voteCount: c.voteCount.toNumber()
      });
    }
  }

  public async fetchElectionName(): Promise<string> {
    return await this.instance.electionName();
  }

  public async fetchTotalVotes(): Promise<number> {
    const vote = await this.instance.totalVotes();
    return vote.toNumber();
  }

  public async isEthApiAvailable(): Promise<boolean> {
    if ( window.ethereum ) {
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
h1 {
  color: #5695f4;
  margin: 0;
}

input {
  border: none;
  outline: none;
  padding: 10px;
  border-radius: 5px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24);
}

button {
  padding: 10px;
  border: none;
  outline: none;
  margin-top: 10px;
  border-radius: 5px;
  width: 100px;
  background-color: #5695f4;
  cursor: pointer;
  color: #ffffff;
  transition: background-color 0.3s ease-out;

  &:disabled {
    opacity: .7;
    cursor: not-allowed;
  }

  &:not(:disabled):hover {
    background-color: #16056b;
    color: #fff;
  }
}

.candidates {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr 1fr;
  max-width: 1000px;
  margin: 0 auto;

  .candidate {
    margin: 20px;
    padding: 20px 5px;
    border-radius: 5px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24);
    transition: all 0.3s cubic-bezier(.25, .8, .25, 1);

    h4,
    h5 {
      padding: 0;
      margin: 0;
    }
  }
}
</style>
