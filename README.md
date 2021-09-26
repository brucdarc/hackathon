##Overview

Often in the cross chain ecosystem of the present, we see tokens easily able to migrate to different chains, but very rarely able to retain all their functionality. One of the most common token use cases is governance. We have designed and implemented a system for cross chain governance. This system allows voters to vote on the same proposal on any chain. All votes are aggregated across all chains and governance execution is mirror on every chain in the system simultaneously. We accomplish this through a system utilizing two participant roles: Ratifiers and Submitters. Each role is given an economic incentive to participate non-maliciously, and a disincentive for malicious behavior. 
The jobs of Submitters is to aggregate and communicate data from other chains. Ratifiers vote to confirm the legitimacy of this data. Both Submitters and Ratifiers offer a bond that can be slashed by the system in the case where behavior is presumed to be malicious. Ratifiers will have their bonds slashed when they vote in opposition to the majority of other Ratifiers. Submitters will have their bond slashed if they submit data to the system that the Ratifiers deem to be incorrect. The bonds and rewards for participation for these roles are separate constant values and can be changed individually before launch to aim for the proper level of incentives. 

##Control Flow

The control flow for a cross chain governance proposal with this system is as follows:

    1. Proposal by a user is submitted on any of the supported chains.

    2. A unique identifier for this proposal is generated based on the address of the creator, the chain of origin, and the block’s timestamp.

    3. The proposal is pushed to all other chains by Submitters, who are rewarded for doing so.

Steps 4 and 5 begin simultaneously:

    4. On each chain, Ratifiers either ratify or negate the validity of the data pushed

        1. Ratifiers have a period of 2 days to complete this action.

        2. If the Ratifiers deem the data to be incorrect, the bond of the submitter is slashed and the proposal discarded.

    5. Voting Begins on all chains.

        1. Voting last 7 days with all holders of the governance token being able to vote proportionally to their token holdings.

        2. Tokens used to vote are locked until voting ends to prevent double voting

    6. Voting Ends 7 days later on all chains

    7. For each chain, Submitters aggregate all votes on other chains and submit them to that chain.

    8. Ratifiers vote on the validity of the data provided by the submitter on each chain

        1. If the data is deemed invalid, Submitter bond is slashed.

    9. Aggregated votes from other chains are added to votes collected on chain

    10. If there more votes for the proposal than against it, the correct amount of time has passed, and data from the Submitters has been all deemed valid, the proposal can be executed.



##Thoughts on Improvements and Attack Vectors

It is important to always evaluate the worst case and most malicious actions possible within any DEFI system, and well as the incentives that motivate participant behavior. The most present attack vector for this system is a 51% attack involving controlling 51% of the Ratifiers. This protocol should be implemented at sufficient enough scale to make a 51% by one entity economically infeasible. It would also be a good idea to consider implementing anti-collusion mechanisms. Rewards and penalties from the system could be made to be dynamic, so that the incentives grow with the inflation of the token and value of the project. Doing so could help offset a greater potential economic gain for exploitation as the value of the project grows. Minting tokens could also be done to target a yearly inflation rate instead of created at a constant value during each action of governance. 
      

##Conclusion

We believe governance systems such this one could support higher mobility of governance tokens across networks, as well as lower the barrier to entry for governance voting. As with any DEFI system, thought should be given to any all all potential attack vectors, many of which are addressed above.
