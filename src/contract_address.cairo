use starknet::{ContractAddress};
#[starknet::interface]
pub trait IAddressList<TContractState> {
    fn register_address(ref self: TContractState);
    fn get_n_th_registered_addrss(self: @TContractState, index: u64) -> Option::<ContractAddress>;
    fn get_all_address(self: @TContractState) -> Array<ContractAddress>;
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
            // get caller address
            let caller: ContractAddress = get_caller_address();
            self.addresses.append().write(caller);
        }
        fn get_n_th_registered_addrss(
            self: @ContractState, index: u64,
        ) -> Option::<ContractAddress> {
            // DEV: here we are using storage_prt because with vec<> type as the address was appended it
            //      returned a storage pointer instead of an actual slot as with storage memory
            if let Option::Some(storage_ptr) = self.addresses.get(index) {
                return Option::Some(storage_ptr.read());
            }
            return Option::None;
        }
        fn get_all_address(self: @ContractState) -> Array<ContractAddress> {
            let mut address = array![];

            // DEV: .. is the cairo range operator
            //      i is the iterator, iterating from index 0 to but except the vec<> length
            //      0..self.addresses.len() ===== declares the range
            for i in 0..self.addresses.len() {
                address.append(self.addresses.at(i).read())
            };

            // return the array containing all the addresses
            address
        }
    }
}
