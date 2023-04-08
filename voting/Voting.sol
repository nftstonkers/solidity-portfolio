// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Voting {

    bool public votingOpen = false;
    address public leadingCandidate;
    mapping(address => bool) public hasVoted;
    mapping(address => Candidate) public candidates;
    address[] public candidateList;
    address[] public voterList;
    address private admin;

    struct Candidate {
        address name;
        bool registered;
        uint256 votes;
    }
    
    modifier onlyAdmin {
        require(msg.sender == admin, "Insufficient Permission");
        _;
    }

    modifier votingAllowed {
        require(votingOpen, "Voting is closed");
        _;
    }

    modifier registrationAllowed {
        require(!votingOpen, "Registeration is closed");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function toggleVoting() public onlyAdmin {
        if(votingOpen) {
            for (uint256 i = 0; i < candidateList.length; i++) {
                candidates[candidateList[i]].votes = 0;
                candidates[candidateList[i]].registered = false;
            }

            for (uint256 i = 0; i < voterList.length; i++) {
                hasVoted[voterList[i]] = false;
            }
        }
        votingOpen = !votingOpen;
    }

    function vote(address candidate) public votingAllowed {
        require(!hasVoted[msg.sender], "Already Voted");
        require(candidates[candidate].registered, "Candidate not found");
        hasVoted[msg.sender] = true;
        candidates[candidate].votes += 1;
        if (candidates[leadingCandidate].votes < candidates[candidate].votes) {
            leadingCandidate = candidate;
        }
    }

    function registerForVoting(address candidate) public registrationAllowed {
        Candidate memory newCandidate = Candidate(candidate, true, 0);
        candidates[candidate] = newCandidate;
        candidateList.push(candidate);
    }

    function getWinner() public view registrationAllowed returns(address) {
        return leadingCandidate;
    }

}