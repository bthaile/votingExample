// create ballot transaction test

import Test
import "ApprovalVoting"

access(all) fun testApprovalVotingProcess() {
    // Setup
    let admin: Test.TestAccount = Test.getAccount(0x0000000000000007)
    let voter: Test.TestAccount = Test.createAccount()
    
    // Deploy the ApprovalVoting contract
    Test.deployContract(
        name: "ApprovalVoting",
        path: "../contracts/ApprovalVoting.cdc",
        arguments: []
    )

    // Create proposals
    let createProposalsTx: Test.Transaction = Test.Transaction(
        code: Test.readFile("../transactions/InitApprovalVotes.cdc"),
        authorizers: [admin.address],
        signers: [admin],
        arguments: [["Proposal 1", "Proposal 2", "Proposal 3"]]
    )
    
    let createProposalsResult: Test.TransactionResult = Test.executeTransaction(createProposalsTx)
    Test.expect(createProposalsResult, Test.beSucceeded())

    // call "GetVotes.cdc" to get proposals and verify zero votes for each
    let getVotesScript: Test.ScriptResult = Test.executeScript(
        Test.readFile("../scripts/GetVotes.cdc"),
        []
    )
    Test.expect(getVotesScript, Test.beSucceeded())
    // verify the return value is a dictionary of proposals with vote counts that are zero
    let votes: {String: UInt}? = getVotesScript.returnValue as! {String: UInt}?
    Test.assertEqual(0 as UInt, votes!["Proposal 1"] ?? 0)
    Test.assertEqual(0 as UInt, votes!["Proposal 2"] ?? 0)
    Test.assertEqual(0 as UInt, votes!["Proposal 3"] ?? 0)

    // Issue ballot
    let issueBallotTx: Test.Transaction = Test.Transaction(
        code: Test.readFile("../transactions/CreateBallot.cdc"),
        authorizers: [voter.address],
        signers: [voter],
        arguments: [admin.address]
    )
    
    let issueBallotResult: Test.TransactionResult = Test.executeTransaction(issueBallotTx)
    Test.expect(issueBallotResult, Test.beSucceeded())


 // call "GetVotes.cdc" to get proposals and verify zero votes for each
    let getVotes1: Test.ScriptResult = Test.executeScript(
        Test.readFile("../scripts/GetVotes.cdc"),
        []
    )
    Test.expect(getVotes1, Test.beSucceeded())
    // verify the return value is a dictionary of proposals with vote counts that are zero
    let votes1: {String: UInt}? = getVotes1.returnValue as! {String: UInt}?
    Test.assertEqual(0 as UInt, votes1!["Proposal 1"] ?? 0)
    Test.assertEqual(0 as UInt, votes1!["Proposal 2"] ?? 0)
    Test.assertEqual(0 as UInt, votes1!["Proposal 3"] ?? 0)


    // Vote
    let voteTx: Test.Transaction = Test.Transaction(
        code: Test.readFile("../transactions/CastVotes.cdc"),
        authorizers: [voter.address],
        signers: [voter],
        arguments: [[true, false, true]]  // Voting for Proposal 1 and 3
    )
    
    let voteResult: Test.TransactionResult = Test.executeTransaction(voteTx)
    Test.expect(voteResult, Test.beSucceeded())

     // call "GetVotes.cdc" to get proposals and verify zero votes for each
    let getVotes: Test.ScriptResult = Test.executeScript(
        Test.readFile("../scripts/GetVotes.cdc"),
        []
    )
    Test.expect(getVotes, Test.beSucceeded())
    // verify the return value is a dictionary of proposals with vote counts that are zero
   let votes2: {String: UInt}? = getVotes.returnValue as! {String: UInt}?
    Test.assertEqual(1 as UInt, votes2!["Proposal 1"] ?? 0)
    Test.assertEqual(0 as UInt, votes2!["Proposal 2"] ?? 0)
    Test.assertEqual(1 as UInt, votes2!["Proposal 3"] ?? 0)
}



