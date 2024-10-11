 
flow accounts add-contract ./cadence/contracts/ApprovalVoting.cdc
flow accounts update-contract ./cadence/contracts/ApprovalVoting.cdc
flow scripts execute cadence/scripts/GetVotes.cdc
flow transactions send ./cadence/transactions/InitApprovalVotes.cdc "[\"Longer Shot Clock\", \"Trampolines instead of hardwood floors\"]"
flow transactions send ./cadence/transactions/CreateBallot.cdc f8d6e0586b0a20c7 --signer bob4
flow transactions send ./cadence/transactions/CastVotes.cdc --signer bob4 "[true, false]"

flow accounts create --network emulator 
