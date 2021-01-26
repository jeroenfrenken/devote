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

    uint public totalVotes;
    Candidate[] public candidates;
    mapping(address => Voter) public voters;

    constructor(string memory _name) public {
        owner = msg.sender;
        electionName = _name;
    }

    // Modifier to check if the user is the owner
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    // check if the current has not voted yet
    modifier hasNotVoted() {
        require(!voters[msg.sender].voted);
        _;
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
    function vote(uint _voteIndex) hasNotVoted public {
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = _voteIndex;

        candidates[_voteIndex].voteCount += 1;
        totalVotes += 1;
    }

    // Voting blank
    function blankVote() hasNotVoted public {
        voters[msg.sender].voted = true;

        totalVotes += 1;
    }
}
