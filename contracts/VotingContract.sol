// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract Voting {
    enum Vote { None, Yes, No, Abstain }

    mapping(address => Vote) public votes;
    uint public yesCount;
    uint public noCount;
    uint public abstainCount;

    event Voted(address indexed voter, Vote vote);

    function vote(Vote _vote) public {
        require(votes[msg.sender] == Vote.None, "You have already voted.");
        votes[msg.sender] = _vote;
        if (_vote == Vote.Yes) {
            yesCount++;
        } else if (_vote == Vote.No) {
            noCount++;
        } else {
            abstainCount++;
        }

        emit Voted(msg.sender, _vote);
    }

    function getVotingCounts() public view returns (uint, uint, uint) {
        return (yesCount, noCount, abstainCount);
    }

    function getMyVote() public view returns (Vote) {
        require(votes[msg.sender] != Vote.None, "You haven't voted.");
        return votes[msg.sender];
    }
}