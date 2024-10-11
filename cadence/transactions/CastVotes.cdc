import "ApprovalVoting"

// This transaction allows a voter to select the votes they would like to make
// and cast that vote using the ballot previously created and stored in their account

transaction(votes: [Bool]) {
    let voterAddress: Address
    let hasVoted: Bool

    prepare(voter: auth(BorrowValue) &Account) {
        self.voterAddress = voter.address

        // Check if the ballot exists in the voter's storage
        if voter.storage.type(at: ApprovalVoting.getBallotStoragePath()) == nil {
            panic("No ballot found. Please run the CreateBallot transaction first.")
        }

        let ballotRef: &ApprovalVoting.Ballot = voter.storage.borrow<&ApprovalVoting.Ballot>(
            from: ApprovalVoting.getBallotStoragePath()
        ) ?? panic("Could not borrow reference to the voter's ballot. This should not happen if the ballot exists.")

        // Check if the ballot has already been cast
        if ballotRef.hasVoted {
            panic("This ballot has already been cast")
        }

        // Convert the votes array to a dictionary inline
        var voteDict: {UInt: Bool} = {}
        var i: Int = 0
        while i < votes.length {
            voteDict[UInt(i)] = votes[i]
            i = i + 1
        }

        ballotRef.vote(votes: voteDict)
        ballotRef.cast()
        self.hasVoted = ApprovalVoting.getHasVoted(address: self.voterAddress)
    }

    post {
        self.hasVoted == true: "Vote was not cast successfully"
    }
}
