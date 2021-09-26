
pragma solidity ^0.8.7;

// SPDX-License-Identifier: -- 🦉

import "./Declarations.sol";

contract OnChainGovernance is Declarations{
    
      constructor(address _bondToken, uint256 _ratBondAmount, uint256 _subBondAmount, uint256 _chainId) Declarations( _bondToken,  _ratBondAmount,  _subBondAmount, _chainId){
          
      }
    
    
      function sendBondRatifier(uint256 _bondLockTime) 
      external
      {
          require(
              RatifierBond[msg.sender].Paid == false,
              "Bond Already Sent"
              );
              
          RatifierBond[msg.sender].BondEndTimestamp = _bondLockTime + block.timestamp;
                    
          BondToken.transferFrom(msg.sender, address(this), RatifierBondAmount);
          
          RatifierBond[msg.sender].Paid = true;
      }
      
      function sendBondSumbitter(uint256 _bondLockTime)
      external
      {
          require(
              SubmitterBond[msg.sender].Paid == false,
              "Bond Already Sent"
              );
              
          SubmitterBond[msg.sender].BondEndTimestamp = _bondLockTime + block.timestamp;
          BondToken.transferFrom(msg.sender, address(this), SubmitterBondAmount);
          
          SubmitterBond[msg.sender].Paid = true;
      }
      
      function redeemBondRatifier() external{
          
          require(
              RatifierBond[msg.sender].Paid == true,
              "Bond not Paid"
              );
              
          require(
              RatifierBond[msg.sender].BondEndTimestamp + BondCooldownAfterVoting < block.timestamp,
              "Bond Unlock Time Not Expired"
              );
              
          RatifierBond[msg.sender].Paid = false;
              
          BondToken.transferFrom(address(this), msg.sender, RatifierBondAmount);
      }
      
      function redeemBondSubmitter() external{
          
          require(
              SubmitterBond[msg.sender].Paid == true,
              "Bond not Paid"
              );
              
          require(
              SubmitterBond[msg.sender].BondEndTimestamp + BondCooldownAfterVoting < block.timestamp,
              "Bond Unlock Time Not Expired"
              );
              
          SubmitterBond[msg.sender].Paid = false;
              
          BondToken.transferFrom(address(this), msg.sender, SubmitterBondAmount);
      }
      
      
      
      function submitProposal(
      bytes calldata _transactionData,
      address _sendTo,
      uint256 _value
      )
      external
      {
          
          
          bytes32 id = keccak256(
                  abi.encode(
                      msg.sender, 
                      currentChainId,
                      block.timestamp
                      )
                  );
          
          //prevent proposal spam by making proposer addresses offer bond
          require(
              SubmitterBond[msg.sender].Paid == true,
              "Proposal: User has no Bond"
              );
              
          //more spam prevention by only allowing 1 proposal per user per timer period, ie users current proposal must finish before submitting new one
          require(
              Proposals[id].timestamp + VotingPlusRatificationTime <= block.timestamp,
              "User has Proposal in progress"
          );
          
          
          
          Proposals [id] = Proposal({
              sendTo : _sendTo,
              transactionData : _transactionData,
              value : _value,
              timestamp : block.timestamp,
              votesFor : 0,
              votesAgainst : 0
          });
      }
      

      
      //use the proposers address as a key so we dont use more variables and we save gas.
      //Will require front end abstraction to display what proposal a proposer currently has proposed
      function voteForProposal(
      bytes32 _id, 
      uint256 _amount
      ) 
      external
      {
          
          require(
              Proposals[_id].timestamp + VotingTime >= block.timestamp,
              "Proposal expired"
          );
          
          _votingHelper(_id, _amount);
          
          Proposals[_id].votesFor += _amount;
          
      }
      
      function voteAgainstProposal(
      bytes32 _id, 
      uint256 _amount
      )
      external
      {
              
          require(
              Proposals[_id].timestamp + VotingTime >= block.timestamp,
              "Proposal expired"
          );
          
          _votingHelper(_id, _amount);
          
          Proposals[_id].votesAgainst += _amount;
      }
      
      
      function _votingHelper(
      bytes32 _id, 
      uint256 _amount
      ) 
      internal
      {
          
          transferFrom(msg.sender, address(this), _amount);
          UserTokensLockedForVoting[msg.sender].unlockTime = Proposals[_id].timestamp + VotingTime;
          UserTokensLockedForVoting[msg.sender].amountLocked += _amount;
          
      }
      

      
      function reclaimVotingTokens()
      external
      {
          
          require(
          UserTokensLockedForVoting[msg.sender].unlockTime < block.timestamp,
          "Voting Period not finished"
          );
          
          uint256 tokensToReturn = UserTokensLockedForVoting[msg.sender].amountLocked;
          UserTokensLockedForVoting[msg.sender].amountLocked = 0;
          
          transfer(msg.sender, tokensToReturn);
          
      }
     
    
}