/*
*
*   In this example, we want to create a simple approval voting contract
*   where a polling place issues ballots to addresses.
*
*   The run a vote, the Admin deploys the smart contract,
*   then initializes the proposals
*   using the initialize_proposals.cdc transaction.
*   The array of proposals cannot be modified after it has been initialized.
*
*   Then they will give ballots to users by
*   using the issue_ballot.cdc transaction.
*
*   Every user with a ballot is allowed to approve any number of proposals.
*   A user can choose their votesPerProposal and cast them
*   with the cast_vote.cdc transaction.
*
*.  See if you can code it yourself!
*
*/

access(all)
contract ApprovalVoting {

    // Field: An array of strings representing proposals to be approved
    access(all) var proposals: [String]

    // Field: A dictionary mapping the proposal index to the number of votesPerProposal per proposal
    access(all) var votesPerProposal: {UInt: UInt}
  // Add a new field to track which addresses have voted
    access(all) var votedAddresses: {Address: Bool}
    // Add the new hasVoted function
    access(all) fun getHasVoted(address: Address): Bool {
        return self.votedAddresses[address] ?? false
    }
    access(all) fun getVotes(): {UInt: UInt} {
        return self.votesPerProposal
    }
    // Entitlement: Admin entitlement that restricts the privileged fields
    // of the Admin resource
    access(all) entitlement Admin

    access(all) fun getProposals(): [String] {
        return self.proposals
    }

    access(all) fun getAdminStoragePath(): StoragePath {
        return StoragePath(identifier: "approvalVotingAdmin")!
    }

    access(all) fun getBallotStoragePath(): StoragePath {
        return StoragePath(identifier: "approvalVotingBallot")!
    }

    access(all) fun getPublicPath(): PublicPath {
        return PublicPath(identifier: "ApprovalVoting")!
    }
    // Resource: Ballot resource that is issued to users.
    access(all) resource Ballot {
        access(all) var votesPerProposal: {UInt: Bool}
        access(all) var hasVoted: Bool
        access(all) fun vote(votes: {UInt: Bool}) {
            for votesIndex in votes.keys {
                if votesIndex < 0 || votesIndex > UInt(ApprovalVoting.proposals.length) - 1  {
                    panic("vote index out of range")
                }
            }
            self.votesPerProposal = votes
        }
        access(all) fun cast() {
            pre {
                !self.hasVoted: "This ballot has already been cast"
            }
            self.hasVoted = true
            for votesIndex in self.votesPerProposal.keys {
                if self.votesPerProposal[votesIndex]! {
                    ApprovalVoting.votesPerProposal[votesIndex] = (ApprovalVoting.votesPerProposal[votesIndex] ?? 0) + 1
                }
            }
            // Update the votedAddresses field
            ApprovalVoting.votedAddresses[self.owner!.address] = true
        }

        init() {
            self.votesPerProposal = {}
            self.hasVoted = false
        }
    }

    // When a user gets a Ballot object, they call the `vote` function
    // to include their votesPerProposal for each proposal, and then cast it in the smart contract
    // using the `cast` function to have their vote included in the polling
    // Remember to track which proposals a user has voted yes for in the Ballot resource
    // and remember to include proper pre and post conditions to ensure that no mistakes are made
    // when a user submits their vote


    // Resource: Administrator of the voting process
    // initialize the proposals and to provide a function for voters
    // to get a ballot resource
    // Remember to include proper conditions for each function!
    // Also make sure that the privileged fields are secured with entitlements!
    access(all) resource Administrator {
        access(Admin) fun setup(proposals: [String]) {
            ApprovalVoting.proposals = proposals
            ApprovalVoting.votesPerProposal = {}
        }

        access(all) fun issueBallot(): @Ballot {
            return <-create Ballot()
        }
    }

    // Public function: A user can create a capability to their ballot resource
    // and send it to this function so its votes are tallied
    // Remember to include a provision so that a ballot can only be cast once!

    // initialize the contract fields by setting the proposals and votesPerProposal to empty
    // and create a new Admin resource to put in storage
    init() {
        self.account.storage.save(<-create Administrator(), to: ApprovalVoting.getAdminStoragePath())
        self.proposals = []
        self.votesPerProposal = {}
        self.votedAddresses = {} // Initialize the new field
    }

  
}
