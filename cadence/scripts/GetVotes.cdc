import "ApprovalVoting"

// This script allows anyone to read the tallied votes for each proposal
//

// Fill in a return type that can properly represent the number of votes
// for each proposal
// This might need a custom struct to represent the data
access(all) fun main(): {String: UInt} {
    let proposals: [String] = ApprovalVoting.getProposals()
    let votes: {UInt: UInt} = ApprovalVoting.getVotes()
    
    let r: {String: UInt} = {}
    for i, proposal in proposals {
        r[proposal] = votes[UInt(i)] ?? 0
    }
    return r
}
