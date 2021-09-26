  
    pragma solidity ^0.8.7;
    
    // SPDX-License-Identifier: -- 🦉
    
    
    import "./OnChainGovernance.sol";
    
    
    contract CrossChainGov is OnChainGovernance{
      
      
      constructor(address _bondToken, uint256 _ratBondAmount, uint256 _subBondAmount, uint256 _chainId) OnChainGovernance( _bondToken,  _ratBondAmount,  _subBondAmount, _chainId){
          
      }
      
      
      
    
    
      //Functions here need economic incentives for participants to keep system going
      //proposals cross chain spread
    
      function submitOffChainProposal(
          address _sendTo,
          uint256 _value,
          bytes calldata _transactionData,
          bytes32 _id
      ) 
      external
      {
            require(
                SubmitterBond[msg.sender].BondEndTimestamp > block.timestamp,             
                "Submit Bond Period Ended"
                );
                
            
            require(
                SubmitterBond[msg.sender].Paid == true,
                "Bond not paid"
                );
          
          //check timestamp initalization to see if proposal has already been submitted from offchain
            require(
              Proposals[_id].timestamp == 0,
              "Proposal already submitted"
              );
          
          
          OffChainProposalSubmissions[_id] = OffChainProposalSubmission({
              submitter : msg.sender,
              ratificationsFor : 0,
              ratificationsAgainst : 0
          });
          
          
          Proposals[_id] = Proposal({
              sendTo : _sendTo,
              transactionData : _transactionData,
              value : _value,
              timestamp : block.timestamp,
              votesFor : 0,
              votesAgainst : 0
          });
          
          
      }
      
      function ratifyOffChainProposal( bytes32 _id ) external{
          
             require(
                Proposals[_id].timestamp + RatificationTime > block.timestamp,
                "ratification period over"
                );
          
            require(
                RatifierBond[msg.sender].BondEndTimestamp > block.timestamp,             
                "Ratifier Bond Period Ended"
                );
                
            require(
                RatifierBond[msg.sender].Paid == true,
                "Bond not paid"
                );
                
            require(
                ProposalRatifications[msg.sender][_id] == 0,
                "Already ratified"
                );  
                
            ProposalRatifications[msg.sender][_id] = 1;
            
            OffChainProposalSubmissions[_id].ratificationsFor += 1;
            
      }
      
      function negateOffChainProposal( bytes32 _id ) external{
          
             require(
                Proposals[_id].timestamp + RatificationTime > block.timestamp,
                "ratification period over"
                );
          
            require(
                RatifierBond[msg.sender].BondEndTimestamp > block.timestamp,             
                "Ratifier Bond Period Ended"
                );
                
            require(
                RatifierBond[msg.sender].Paid == true,
                "Bond not paid"
                );
                
            require(
                ProposalRatifications[msg.sender][_id] == 0,
                "Already ratified"
                );  
                
            ProposalRatifications[msg.sender][_id] = 2;
            
            OffChainProposalSubmissions[_id].ratificationsAgainst += 1;
            
      }
    
    
      function slashSubmitterBondProposals( bytes32 _id) external{
        
        require(
            Proposals[_id].timestamp + RatificationTime < block.timestamp,
            "Cannot slash before RatificationTime"
            );
            
        require(
            OffChainProposalSubmissions[_id].ratificationsAgainst > OffChainProposalSubmissions[_id].ratificationsFor,
            "No Bad Action"
            );
        
        address submitter = OffChainProposalSubmissions[_id].submitter;
        
        SubmitterBond[submitter].Paid = false;
        
        BondToken.transferFrom(address(this), msg.sender, SubmitterBondAmount);
        
      }
      
      function slashRatifierBondProposals(address _ratifier, bytes32 _id) external{
          
          
          require(
            Proposals[_id].timestamp + RatificationTime < block.timestamp,
            "Cannot slash before RatificationTime"
          );
          
          require(
              ProposalRatifications[_ratifier][_id] != 0,
              "No Bad Action"
          );
          
          require( 
              (ProposalRatifications[_ratifier][_id] == 1)
              && (OffChainProposalSubmissions[_id].ratificationsAgainst > OffChainProposalSubmissions[_id].ratificationsFor),
              "No Bad Action"
          );
              
          require(
              (OffChainProposalSubmissions[_id].ratificationsAgainst < OffChainProposalSubmissions[_id].ratificationsFor)
              && (ProposalRatifications[_ratifier][_id] == 2),
              "No Bad Action"
          );
          
        address ratifier = SubmissionsUpForRatification[_id].submitter;
        
        RatifierBond[ratifier].Paid = false;
        
        BondToken.transferFrom(address(this), msg.sender, RatifierBondAmount);
          
      }
      
      
      //Voting cross chain system
        
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
                SubmissionsUpForRatification[_id].timestamp + RatificationTime > block.timestamp,
                "ratification period over"
                );
          
          
            require(
                RatifierBond[msg.sender].BondEndTimestamp > block.timestamp,             
                "Ratifier Bond Period Ended"
                );
                
            
            require(
                RatifierBond[msg.sender].Paid == true,
                "Bond not paid"
                );
                
            require(
                VoteRatifications[msg.sender][_id] == 0,
                "Already ratified"
                );    
                
            //show that a ratifier voted for this submission    
            VoteRatifications[msg.sender][_id] = 1;    
                
            SubmissionsUpForRatification[_id].ratificationsFor += 1;
            
      }
      
      
      function negateOffChainVotes( bytes32 _id ) external{
          
             require(
                SubmissionsUpForRatification[_id].timestamp + RatificationTime > block.timestamp,
                "ratification period over"
                );
          
          
            require(
                RatifierBond[msg.sender].BondEndTimestamp > block.timestamp,             
                "Ratifier Bond Period Ended"
                );
                
            
            require(
                RatifierBond[msg.sender].Paid == true,
                "Bond not paid"
                );
                
            require(
                VoteRatifications[msg.sender][_id] == 0,
                "Already ratified"
                );
            
            //show that a ratifier voted against this submission    
            VoteRatifications[msg.sender][_id] = 2;   
            
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
      
      function slashRatifierBondVotes(address _ratifier, bytes32 _id) external{
          
          
          require(
            SubmissionsUpForRatification[_id].timestamp + RatificationTime < block.timestamp,
            "Cannot slash before RatificationTime"
          );
          
          require(
              VoteRatifications[_ratifier][_id] != 0,
              "No Bad Action"
          );
          
          require( 
              (VoteRatifications[_ratifier][_id] == 1)
              && (SubmissionsUpForRatification[_id].ratificationsAgainst > SubmissionsUpForRatification[_id].ratificationsFor),
              "No Bad Action"
          );
              
          require(
              (SubmissionsUpForRatification[_id].ratificationsAgainst < SubmissionsUpForRatification[_id].ratificationsFor)
              && (VoteRatifications[_ratifier][_id] == 2),
              "No Bad Action"
          );
          
        address ratifier = SubmissionsUpForRatification[_id].submitter;
        
        RatifierBond[ratifier].Paid = false;
        
        BondToken.transferFrom(address(this), msg.sender, RatifierBondAmount);
          
          
      }
    
    
      
      
      
      function executeTransaction(bytes32 _id) external{
          
        require(
            Proposals[_id].timestamp + VotingTime > block.timestamp,
            "time check"
            );  
          
        require(
            SubmissionsUpForRatification[_id].timestamp + RatificationTime > block.timestamp,
            "time check"
            );   
          
          
        require(
             OffChainProposalSubmissions[_id].ratificationsFor >= OffChainProposalSubmissions[_id].ratificationsAgainst,
             "Proposal Ratification Failed"
             );
             
        require(
             SubmissionsUpForRatification[_id].ratificationsFor >= SubmissionsUpForRatification[_id].ratificationsAgainst,
             "Proposal Ratification Failed"
             );
         
        uint256 totalVotesFor =  SubmissionsUpForRatification[_id].votesFor + Proposals[_id].votesFor;
         
        uint256 totalVotesAgainst =  SubmissionsUpForRatification[_id].votesAgainst + Proposals[_id].votesAgainst; 
         
        require( totalVotesFor >  totalVotesAgainst);
        
         

        (bool success, ) = Proposals[_id].sendTo.call{value: Proposals[_id].value}(
            Proposals[_id].transactionData
        );
        require(success, "tx failed");
        
      }
      
      
      
      
    }