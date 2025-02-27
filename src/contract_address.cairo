use starknet::{ContractAddress};
#[starknet::interface]
pub trait IAddressList<TContractState> {
    fn register_address(ref self: TContractState);
    fn get_n_th_registered_addrss(self: @TContractState, index: u64) -> Option::<ContractAddress>;
}

#[starknet::contract]
mod AddressList {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, Vec, VecTrait, MutableVecTrait,
    };

    #[storage]
    struct Storage {
        addresses: Vec<ContractAddress>,
    }

    #[abi(embed_v0)]
    impl AddressListImpl of super::IAddressList<ContractState> {
        fn register_address(ref self: ContractState) {
            //get caller address
            let caller: ContractAddress = get_caller_address();
            self.addresses.append().write(caller);
        }
        fn get_n_th_registered_addrss(
            self: @ContractState, index: u64,
        ) -> Option::<ContractAddress> {
            // here we are using storage_prt because with vec<> type as the address was appended it
            // returned a storage pointer instead of an actual slot as with storage memory
            if let Option::Some(storage_ptr) = self.addresses.get(index) {
                return Option::Some(storage_ptr.read());
            }
            return Option::None;
        }
    }
}
