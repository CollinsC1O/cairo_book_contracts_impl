#[starknet::interface]
trait IVoteProposal<TContractState> {
    fn create_proposal(ref self: TContractState, title: felt252, description: felt252) -> u32;
    fn vote(ref self: TContractState, proposal_id: u32, vote: bool);
}


#[starknet::contract]
mod VoteProposal {
    use starknet::{ContractAddress, get_caller_address};
    // use starknet::contract_address::ContractAddressZeroable;
    use starknet::storage::{
        StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess, Map,
    };

    #[storage]
    struct Storage {
        proposal_count: u32,
        proposals: Map<u32, ProposalNode>,
    }

    #[starknet::storage_node]
    struct ProposalNode {
        title: felt252,
        description: felt252,
        vote_yes: u32,
        vote_no: u32,
        // checks address that have voted
        votes: Map<ContractAddress, bool>,
    }

    impl IVoteProposalImpl of super::IVoteProposal<ContractState> {
        fn create_proposal(ref self: ContractState, title: felt252, description: felt252) -> u32 {
            // to create a voting proposal, firstly, get the already available propopal count, and
            // make a new unique ID off of it.
            // Now get a mutable reference to a new entry in the proposal map using the new ID
            // use the mutable reference to innitialize the proposals
            // update the proposal_count with the new ID in storage
            // return the proposal new ID

            // read the proposal id
            let mut proposal_count_ = self.proposal_count.read();
            // make a unique proposal Id
            let new_proposal_id = proposal_count_ + 1;

            // Note: entry() is a method that provides access to a specific key in a map
            // this get mutable reference to a new entry in the map using new id
            let mut proposal = self.proposals.entry(new_proposal_id);

            // now we can access and initialize the proposal fields
            proposal.title.write(title);
            proposal.description.write(description);
            proposal.vote_yes.write(0);
            proposal.vote_no.write(0);

            self.proposal_count.write(new_proposal_id);

            new_proposal_id
        }

        fn vote(ref self: ContractState, proposal_id: u32, vote: bool) {
            // DEV: to access the votes varient in the Proposals struct type, you need to go through
            // the storage varaible: proposals since the Proposal type is enters as a return value
            // in the proposals storage varaible, considering it is a storage_node a storage_node
            // which help us have several collections values in one type

            // lets get the proposal node type using the given proposal_id
            let proposal = self.proposals.entry(proposal_id).read();

            // lets get the caller
            let caller_: ContractAddress = get_caller_address();
            // get zero address
            // let address_zero = ContractAddressZeroable::zero();

            // ensure caller/voter is not zero address
            // assert(caller != address_zero, 'caller cannot be zero address');

            // check if caller has voted
            let has_voted = self.proposals.entry(proposal_id).votes.entry(caller_).read();
            // if has voted then abort the function call
            if has_voted {
                return;
            };
            proposal.voters.entry(caller).read();
            // now we can use the retrieved proposal to update the Proposal node, therefore updating
            // the votes lets vote

            // proposal.votes.entry(caller).write(true);
            self.proposals.entry(proposal_id).votes.entry(caller).write(true);
        }
    }
}
