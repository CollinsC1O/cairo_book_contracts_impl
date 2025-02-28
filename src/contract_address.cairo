use starknet::{ContractAddress};
#[starknet::interface]
pub trait IAddressList<TContractState> {
    fn register_address(ref self: TContractState);
    fn get_n_th_registered_addrss(self: @TContractState, index: u64) -> Option::<ContractAddress>;
    fn get_all_address(self: @TContractState) -> Array<ContractAddress>;
    fn modify_nth_address(ref self: TContractState, index: u64, new_address: ContractAddress);
    fn add_user(ref self: TContractState, index: u64, new_user: ContractAddress);
    fn modify_address(ref self: TContractState, index: u64, new_address: ContractAddress);
    // fn remove_user(ref self: TContractState, index: u64) -> bool;
    fn store_addrs_from_array(ref self: TContractState);
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
            // DEV: here we are using storage_prt because with vec<> type as the address was
            // appended it
            // returned a storage pointer instead of an actual slot as with storage memory
            // for retrieving from the vec<> we used get() here, we could still use at() but if at()
            // is used if the index is out of bound, the at() method panics but the get() method
            // returns None.
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

        fn modify_nth_address(ref self: ContractState, index: u64, new_address: ContractAddress) {
            let mut storage_ptr = self.addresses.at(index);
            storage_ptr.write(new_address);
        }
        fn add_user(ref self: ContractState, index: u64, new_user: ContractAddress) {
            self.addresses.append().write(new_user)
        }

        fn modify_address(ref self: ContractState, index: u64, new_address: ContractAddress) {
            let mut storage_ptr = self.addresses.at(index);
            storage_ptr.write(new_address);
        }
        // fn remove_user(ref self: ContractState, index: u64) -> bool {
        //     let vec_len = self.addresses.len();
        //     if index >= vec_len{
        //         return false;
        //     }

        //     for i in index..(vec_len - 1) {
        //         let next_address = self.addresses.at(i + 1).read();
        //         let current_address = self.addresses.at(i);
        //         current_address.write(next_address);
        //     };

        //     MutableVecTrait::pop_front_at(ref self.addresses, index)
        //     return true;
        // }

        fn store_addrs_from_array(ref self: ContractState) {
            let mut address: Array<ContractAddress> = array![];

            let first_addrs: ContractAddress = 0x11ab.try_into().unwrap();
            let second_addrs: ContractAddress = 0x12ab.try_into().unwrap();
            let third_addrss: ContractAddress = 0x13ab.try_into().unwrap();

            address.append(first_addrs);
            address.append(second_addrs);
            address.append(third_addrss);

            // lets iterate over the element of the array to append them into our vec<> in storage
            // this is done because we can't directly store array into memory
            for i in 0..address.len() {
                //since returning an element from an array returns a snapshot, lets desnap(*) it
                let address_ = *address.at(i);
                self.addresses.append().write(address_)
            }
        }
    }
}
