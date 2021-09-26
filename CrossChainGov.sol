  
    pragma solidity ^0.8.7;
    
    // SPDX-License-Identifier: MIT
    
    
    import "./OnChainGovernance.sol";
    
    
    contract CrossChainGov is OnChainGovernance{
      
      
      constructor(address _bondToken, uint256 _ratBondAmount, uint256 _subBondAmount, uint256 _chainId) OnChainGovernance( _bondToken,  _ratBondAmount,  _subBondAmount, _chainId){
          
      }
      
      
      
    
    
      //Functions here need economic incentives for participants to keep system going
    
      function submitOffChainProposal(
          bytes32 _transactionData,
          bytes32 _id, 
          uint256 _timestamp
      ) 
      external
      {
          
          
          
          
          
          Proposals[_id] = Proposal({
              transactionData : _transactionData,
              timestamp : _timestamp,
              votesFor : 0,
              votesAgainst : 0
          });
          
          
          
          
      }
      
      function ratifyOffChainProposal() external{
          
          
      }
    
    
    
      
        
      //the job or the submitter here is to aggregate all votes from other chains and submitr them for a proposal
      //ratifiers also do this calculation to confirm that the submitted value is correct.
      function submitAllOffChainVotes(
          bytes32 _id, 
          uint256 _votesFor, 
          uint256 _votesAgainst
      ) external
      {
            require(
                SubmitterBond[msg.sender].BondEndTimestamp > block.timestamp,             
                "Submit Bond Period Ended"
                );
                
            
            require(
                SubmitterBond[msg.sender].Paid == true,
                "Bond not paid"
                );
                
            
            SubmissionsUpForRatification[_id] = OffChainVoteSubmission({
                submitter : msg.sender,
                votesFor : _votesFor,
                votesAgainst : _votesAgainst,
                timestamp : block.timestamp,
                ratificationsFor : 0,
                ratificationsAgainst : 0
            });
            
      }
      
      
      function ratifyOffChainVotes( bytes32 _id ) external{
            require(
                RatifierBond[msg.sender].BondEndTimestamp > block.timestamp,             
                "Ratifier Bond Period Ended"
                );
                
            
            require(
                RatifierBond[msg.sender].Paid == true,
                "Bond not paid"
                );
                
            require(
                Ratifications[msg.sender][_id] == 0,
                "Already ratified"
                );    
                
            //show that a ratifier voted for this submission    
            Ratifications[msg.sender][_id] = 1;    
                
            SubmissionsUpForRatification[_id].ratificationsFor += 1;
            
            
            
      }
      
      
      function negateOffChainVotes( bytes32 _id ) external{
            require(
                RatifierBond[msg.sender].BondEndTimestamp > block.timestamp,             
                "Ratifier Bond Period Ended"
                );
                
            
            require(
                RatifierBond[msg.sender].Paid == true,
                "Bond not paid"
                );
                
            require(
                Ratifications[msg.sender][_id] == 0,
                "Already ratified"
                );
            
            //show that a ratifier voted against this submission    
            Ratifications[msg.sender][_id] = 2;   
            
            SubmissionsUpForRatification[_id].ratificationsAgainst += 1;
            
      }
      
      function slashSubmitterBondVotes( bytes32 _id) external{
        
        require(
            SubmissionsUpForRatification[_id].timestamp + RatificationTime < block.timestamp,
            "Cannot slash before RatificationTime"
            );
            
        require(
            SubmissionsUpForRatification[_id].ratificationsAgainst > SubmissionsUpForRatification[_id].ratificationsFor,
            "No Bad Action"
            );
        
        address submitter = SubmissionsUpForRatification[_id].submitter;
        
        SubmitterBond[submitter].Paid = false;
        
        BondToken.transferFrom(address(this), msg.sender, SubmitterBondAmount);
        
      }
      
      function slashRatifierBond(address _ratifier, bytes32 _id) external{
          
          
          require(
            SubmissionsUpForRatification[_id].timestamp + RatificationTime < block.timestamp,
            "Cannot slash before RatificationTime"
          );
          
          require(
              Ratifications[_ratifier][_id] != 0,
              "No Bad Action"
          );
          
          require( 
              (Ratifications[_ratifier][_id] == 1)
              && (SubmissionsUpForRatification[_id].ratificationsAgainst > SubmissionsUpForRatification[_id].ratificationsFor),
              "No Bad Action"
          );
              
          require(
              (SubmissionsUpForRatification[_id].ratificationsAgainst < SubmissionsUpForRatification[_id].ratificationsFor)
              && (Ratifications[_ratifier][_id] == 2),
              "No Bad Action"
           );
          
        address ratifier = SubmissionsUpForRatification[_id].submitter;
        
        RatifierBond[ratifier].Paid = false;
        
        BondToken.transferFrom(address(this), msg.sender, RatifierBondAmount);
          
          
      }
    
    
      
      
      
      function executeTransaction(address _proposer) external{
         
        /* 
        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");
        */
      }
      
      
      
      
    }