// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Election {
    address public owner;
    string public electionName;

    struct Candidate {
        string name;
        uint voteCount;
    }

    struct Voter {
        bool voted;
        uint vote;
    }

    /*
    * Address which are whitelisted
    */
    mapping(address => bool) public whitelist;
    uint public totalVotes;
    Candidate[] public candidates;

    constructor(string memory _name) public {
        owner = msg.sender;
        electionName = _name;
    }

    // Modifier to check if the user is the owner
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    // Modifier to check if the user is whitelisted
    modifier canVote() {
        require(whitelist[msg.sender]);
        _;
    }

    // Add a voter to the whitelist
    function addVoter(address _address) isOwner public {
        whitelist[_address] = true;
    }

    // Add a new candidate to be elected
    function addCandidate(string memory _name) isOwner public {
        candidates.push(Candidate(_name, 0));
    }

    // Get candidate length
    function getCandidateLength() public view returns (uint candidateCount) {
        return candidates.length;
    }

    // Vote on a candidate index
    function vote(uint _voteIndex) canVote public {
        whitelist[msg.sender] = false;
        candidates[_voteIndex].voteCount += 1;
        totalVotes += 1;
    }

    // Voting blank
    function blankVote() canVote public {
        whitelist[msg.sender] = false;
        totalVotes += 1;
    }
}
