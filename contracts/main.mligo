#import "ligo-extendable-fa2/lib/multi_asset/fa2.mligo" "FA2"

type extension = {
    admin : address;
}
type storage = FA2.storage
type extended_storage = extension storage

type return = operation list * extended_storage 

type parameter = FA2.parameter

let main(action : parameter) (store : extended_storage) : return =
  match action with 
    |   Transfer (p) -> FA2.transfer p store
    |   Balance_of (p) -> FA2.balance_of p store
    |   Update_operators (p) -> FA2.update_ops p store
