import "ApprovalVoting"

// This transaction allows the administrator of the Voting contract
// to create new proposals for voting and save them to the smart contract

transaction(proposals: [String]) {
    // Fill in auth() with the correct entitlements you need!
    prepare(admin: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability) &Account) {

        // borrow a reference to the admin Resource
        // remember to use descriptive error messages!  
        let adminResource: auth(ApprovalVoting.Admin) &ApprovalVoting.Administrator
        = admin.storage.borrow<auth(ApprovalVoting.Admin) &ApprovalVoting.Administrator>
        (from: ApprovalVoting.getAdminStoragePath()) ?? panic("Admin resource not found")

        // Call the initializeProposals function
        adminResource.setup(proposals: proposals)
        // to create the proposals array as an array of strings
        // Maybe we could create two proposals for the local basketball league:
        // ["Longer Shot Clock", "Trampolines instead of hardwood floors"]

        // Issue and public a public capability to the Administrator resource
        // so that voters can get their ballots!
        let cap: Capability<&ApprovalVoting.Administrator> 
        = admin.capabilities.storage.issue<&ApprovalVoting.Administrator>
        (ApprovalVoting.getAdminStoragePath())

        admin.capabilities.publish(cap, at: ApprovalVoting.getPublicPath())

    }

    post {
        // Verify that the proposals were initialized properly
    }

}
