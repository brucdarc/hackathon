pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// SPDX-License-Identifier: -- 🦉


contract Declarations is ERC20{
    
    
      IERC20 immutable BondToken;
      uint256 immutable RatifierBondAmount;
      uint256 immutable SubmitterBondAmount;
      uint256 immutable currentChainId;
      
      constructor(address _bondToken, uint256 _ratBondAmount, uint256 _subBondAmount, uint256 _chainId)ERC20("CrossGov", "CCG"){
          BondToken = IERC20(_bondToken);
          RatifierBondAmount = _ratBondAmount;
          SubmitterBondAmount = _subBondAmount;
          currentChainId = _chainId;
      }
    
    
      struct Proposal{
          address sendTo;
          bytes transactionData;
          uint256 value;
          uint256 timestamp;
          uint256 votesFor;
          uint256 votesAgainst;
      }
     
      
      struct ChainDecision{
          uint256 chainID;
          uint256 votesFor;
          uint256 votesAgainst;
          uint256 ratificationsFor;
          uint256 ratificationsAgainst;
          bytes32 ProposalHash;
          bytes32 DecisionHash;
      }
      
      struct Submitter{
          bool bondPaid;
          bytes32 ProposalHash;
      }
      
      struct TokenLock{
          uint256 amountLocked;
          uint256 unlockTime;
      }
      
      struct BondInfo{
          uint256 BondEndTimestamp;
          bool Paid;
      }
      
      //use this struct for ratifiers to confirm or deny the sumbitters data
      struct OffChainVoteSubmission{
          address submitter;
          uint256 votesFor;
          uint256 votesAgainst;
          uint256 timestamp;
          uint256 ratificationsFor;
          uint256 ratificationsAgainst;
      }
      
      struct OffChainProposalSubmission{
          address submitter;
          uint256 ratificationsFor;
          uint256 ratificationsAgainst;
      }
      
      
      uint256 subrewardsPerYear;
      uint256 ratrewardsPerYear;
      uint256 constant VotingTime = 7 days;
      uint256 constant RatificationTime = 2 days;
      uint256 constant VotingPlusRatificationTime = 9 days; //use a const instead of using gas to add voting and ratification time when the combination of them is needed
      uint256 constant BondCooldownAfterVoting = 11 days; //add a reasonable delta of 2 days in case there is some delay of submitters submitting proposals to other chains



      uint256[] chainIDs = [1, 1666600000];
      
      mapping(bytes32 => OffChainProposalSubmission) OffChainProposalSubmissions;
      
      mapping(bytes32 => OffChainVoteSubmission) SubmissionsUpForRatification;
      
      mapping(uint256 => bool) chainVotesCounted;
      
      mapping(address => mapping(bytes32 => uint64)) ProposalRatifications; //All proposal Ratifications for a specific ratifier. 0 = no vote, 1 = voted for, 2 = voted against

      mapping(address => mapping(bytes32 => uint64)) VoteRatifications; //All vote Ratifications for a specific ratifier. 0 = no vote, 1 = voted for, 2 = voted against
      
      mapping(address => bytes32) ChainDecisionSubmission; //bytes32 is a hash of the important data of the Decision. chainid, votesFor, votesAgainst, transactionData
      
      mapping(address => BondInfo) RatifierBond;        //bonds protect against spam attacks
      
      mapping(address => BondInfo) SubmitterBond;
      
      mapping(bytes32 => Proposal) Proposals;   //only let submitters propose 1 proposal at a time, and wait for voting and ratification time period before reproposing
      
      //Bytes 32 is a hash of transactionData and block timestamp of that submission
      mapping(address => bytes32) ProposerCurrentProposal;      //only let address with bond up propose 1 proposal at once, protect against spam since spam proposals causes ratifiers to act
     
      mapping(address => TokenLock) UserTokensLockedForVoting;
    
}