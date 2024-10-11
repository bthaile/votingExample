import "ApprovalVoting"

// This transaction allows a user
// to create a new ballot and store it in their account
// by calling the public function on the Admin resource
// through its public capability

transaction(address: Address) {
    // fill in the correct entitlements!
    prepare(voter: auth(BorrowValue, SaveValue) &Account) {
        // Get the administrator's public account object
        // and borrow a reference to their Administrator resource
        let admin: &Account = getAccount(address)
        let adminRef: &ApprovalVoting.Administrator = admin.capabilities.borrow<&ApprovalVoting.Administrator>(ApprovalVoting.getPublicPath())
            ?? panic("Admin not found")

        // Issue the ballot
        let ballot: @ApprovalVoting.Ballot <- adminRef.issueBallot()

        // Store the ballot in the voter's account storage using Cadence 1.0 syntax
       voter.storage.save(<-ballot, to: ApprovalVoting.getBallotStoragePath())
 }
}
