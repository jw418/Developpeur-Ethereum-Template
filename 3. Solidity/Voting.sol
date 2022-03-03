// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Voting is Ownable{
  
  event VoterRegistered(address voterAddress); 
  event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
  event ProposalRegistered(uint proposalId);
  event Voted(address voter, uint proposalId);

  enum WorkflowStatus {
  RegisteringVoters,
  ProposalsRegistrationStarted,
  ProposalsRegistrationEnded,
  VotingSessionStarted,
  VotingSessionEnded,
  VotesTallied
  }
  WorkflowStatus public currentStatus = WorkflowStatus.RegisteringVoters;

  struct Voter {
  bool isRegistered;
  bool hasVoted;
  uint votedProposalId;
  }

  struct Proposal {
  string description;
  uint voteCount;
  }

  mapping(address => Voter) public voters;
  Proposal[] public proposals;
  uint public nomberOfProposals;
  uint winningProposalId;
  uint voteMax;

  function isWhitelisted(address _address) external onlyOwner {
      require(currentStatus == WorkflowStatus.RegisteringVoters, "the registration period for the whitelist is over");
      require(!voters[_address].isRegistered, "This voters is already registered");
      voters[_address].isRegistered = true;
      emit VoterRegistered(_address);    
  }

  function startProposalRegistration() external onlyOwner{
      require(currentStatus == WorkflowStatus.RegisteringVoters,"the current workflow status does not allow you to start registering proposals");
      currentStatus = WorkflowStatus.ProposalsRegistrationStarted;
      emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted); 
  }
  
  function depositProposal(string memory _proposal) external{
      require(voters[msg.sender].isRegistered == true, "this address is not whitelisted");
      require(currentStatus == WorkflowStatus.ProposalsRegistrationStarted, "registration of proposals is not open");      
      proposals.push(Proposal({
        description: _proposal,
        voteCount: 0
      }));
      emit ProposalRegistered(nomberOfProposals);
      nomberOfProposals += 1;
      
  }
  
  function getArrayOfProposals() external view returns(Proposal[] memory){
      Proposal[] memory arrayOfProposals = new Proposal[](proposals.length);
      for(uint i=0; i<proposals.length; i++) {
          arrayOfProposals[i] = proposals[i];
          }
      return arrayOfProposals;    
  }
 
  function endProposalRegistration() external onlyOwner{
      require(currentStatus == WorkflowStatus.ProposalsRegistrationStarted,"the current workflow status does not allow you to stop registering proposals");
      currentStatus = WorkflowStatus.ProposalsRegistrationEnded;
      emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded); 
  }
  
  function startVotingSession() external onlyOwner{
      require(currentStatus == WorkflowStatus.ProposalsRegistrationEnded,"the current workflow status does not allow you to start voting session");
      currentStatus = WorkflowStatus.VotingSessionStarted;
      emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted); 
  }

  function voteFor(uint _proposalId) external {
      require(voters[msg.sender].isRegistered == true, "this address is not whitelisted");
      require(currentStatus == WorkflowStatus.VotingSessionStarted,"the current workflow status does not allow you to vote");
      require(!voters[msg.sender].hasVoted,"this address has already voted");
      proposals[_proposalId].voteCount += 1;
      voters[msg.sender].hasVoted = true;
      voters[msg.sender].votedProposalId = _proposalId;
      emit Voted(msg.sender, _proposalId);
  }

  function endVotingSession() external onlyOwner{
      require(currentStatus == WorkflowStatus.VotingSessionStarted,"the current workflow status does not allow you to stop voting session");
      currentStatus = WorkflowStatus.VotingSessionEnded;   
      emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded); 
  }

  function countedVotes() external onlyOwner{
      require(currentStatus == WorkflowStatus.VotingSessionEnded,"the current workflow status does not allow you to counted the votes");
      
      for(uint i=0; i < proposals.length; i++){     // simplification, ne prends pas en compte la possibilité d'une égalié 
          if (proposals[i].voteCount > voteMax) {
                voteMax = proposals[i].voteCount;
                winningProposalId = i;
          }  
      }
      currentStatus = WorkflowStatus.VotesTallied;
      emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied); 
  }

  function getWinner() external view returns(string memory, uint){
      require(currentStatus == WorkflowStatus.VotesTallied,"the current workflow status does not allow you to get the winner");      
      return (proposals[winningProposalId].description, proposals[winningProposalId].voteCount);
  }
} 