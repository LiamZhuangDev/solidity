// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract StructWithMapping {
    struct Proposal {
        string description;
        uint voteCount;
        uint deadline;
        bool executed;
        mapping(address => bool) voters;
    }

    mapping(uint => Proposal) public proposals; // proposalId => Proposal
    uint public proposalCount;

    function createProposal(string calldata description, uint duration)
        public returns (uint proposalId)
    {
        proposalId = proposalCount++;
        Proposal storage p = proposals[proposalId]; // must create a storage reference to the proposal
        p.description = description;
        p.voteCount = 0;
        p.deadline = block.timestamp + duration;
        p.executed = false;
    }

    function vote(uint proposalId) public {
        require(proposalId < proposalCount, "invalid proposal ID");
        
        Proposal storage p = proposals[proposalId];
        require(block.timestamp < p.deadline, "Voting ended");
        require(!p.voters[msg.sender], "Already voted");

        p.voters[msg.sender] = true;
        p.voteCount++;
    }

    function hasVoted(uint proposalId, address voter)
        public view returns (bool)
    {
        require(proposalId < proposalCount, "invalid proposal ID");
        return proposals[proposalId].voters[voter];
    }
}