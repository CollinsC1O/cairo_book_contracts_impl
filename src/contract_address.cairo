use starknet::{ContractAddress};
#[starknet::interface]
trait IAddressList<TContractState> {
    fn register_caller(ref self: TContractState,);
    fn get_n_th_registered_addrss(self: @TContractState, index: u64 ) -> Option::<ContractAddress>;
    
}