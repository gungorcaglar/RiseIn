// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract ProposalContract {
    address owner;

    using Counters for Counters.Counter;
    Counters.Counter private _counter;

    struct Proposal {
        string title;//TASK 2
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
        bool is_active; // This shows if others can vote to our contract
    }

    mapping(uint256 => Proposal) proposal_history;

    address[] private voted_addresses; 

    //constructor
    constructor() {
        owner = msg.sender;
        voted_addresses.push(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier active() {
        require(proposal_history[_counter.current()].is_active == true);
        _;
    }

    modifier newVoter(address _address) {
        require(!isVoted(_address), "Address has not voted yet");
        _;
    }

    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    function create(string calldata _title, string calldata _description, uint256 _total_vote_to_end) external {//TASK 3
            _counter.increment();
            proposal_history[_counter.current()] = Proposal(_title, _description, 0, 0, 0, _total_vote_to_end, false, true);//TASK 3
    }

    function vote(uint8 choice) external active newVoter(msg.sender){
        Proposal storage proposal = proposal_history[_counter.current()];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses.push(msg.sender);

        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 0) {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentState();
        }

        if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0)) {
            proposal.is_active = false;
            voted_addresses = [owner];
        }
    }

    //TASK 4
    function calculateCurrentState() private view returns(bool) {
        Proposal storage proposal = proposal_history[_counter.current()];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;

        if (approve > reject) {
            return true;
        } else {
            return false;
        }
    }
    //TASK 4
}