use starknet::ContractAddress;
#[starknet::interface]
trait INameRegister<TContractState> {
    fn store_name(ref self: TContractState, name: felt252);
    fn get_name(self: @TContractState, address: ContractAddress) -> felt252;
}

#[starknet::contract]
mod NameRegister {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map,
    };

    #[storage]
    struct Storage {
        names: Map<ContractAddress, felt252>,
        total_names: u32,
    }

    #[derive(Drop, Serde, starknet::Store)]
    pub struct Person {
        address: ContractAddress,
        name: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: Person) {
        self.names.entry(owner.address).write(owner.name);
        self.total_names.write(1);
    }

    impl NameRegister of super::INameRegister<ContractState> {
        fn store_name(ref self: ContractState, name: felt252) {
            let caller: ContractAddress = get_caller_address();
            self._store_name(caller, name);
        }
        fn get_name(self: @ContractState, address: ContractAddress) -> felt252 {
            let name: felt252 = self.names.entry(address).read();
            name
        }
    }

    #[generate_trait]
    impl Internal of InternalTrait {
        fn _store_name(ref self: ContractState, address: ContractAddress, name: felt252) {
            let current_total_names = self.total_names.read();

            self.names.entry(address).write(name);

            self.total_names.write(current_total_names + 1);
        }
    }

    // lets get the contract name
    #[external(v0)]
    fn get_contract_name(self: @ContractState) -> felt252 {
        'Name Register'
    }

    #[external(v0)]
    fn get_total_name_address(self: @ContractState) -> felt252 {
        self.total_names.__base_address__
    }
}
