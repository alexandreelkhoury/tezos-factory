#import "../../../contracts/main.mligo" "Contract"

type originated = (
    address *
    (Contract.parameter, Contract.storage) typed_address *
    Contract.parameter contract
)

let bootstrap_accounts () =
    let () = Test.reset_state 5n ([] : tez list) in
    let accounts =
        Test.nth_bootstrap_account 1,
        Test.nth_bootstrap_account 2,
        Test.nth_bootstrap_account 3
    in
    accounts

// let moves : register =
//   Map.literal [
//     (("tz1KqTpEZ7Yob7QbPE4Hy4Wo8fHG8LhKxZSx" : address), (1,2));
//     (("tz1gjaF81ZRRvdzjobyfVNsAeSC6PScjfQwN" : address), (0,3))]

let initial_storage(admin : address) = {
    admin = Map.literal[
        ((admin : address), (true : bool));
    ];
    can_be_admins = (Map.empty  : Contract.can_be_admins );
    whitelist_creators = (Map.empty : Contract.whitelist_creators);
    blacklist_creators = (Map.empty : Contract.blacklist_creators);
}

let initial_balance = 0mutez

let originate_contract (admin : address) : originated =
    let init_storage = (Test.eval (initial_storage(admin))) in
    // let (t_addr, _code, _nonce) =
    //     Test.originate Contract.main (initial_storage(admin)) initial_balance in
    let (addr, _code, _nonce) =
        Test.originate_from_file "../../../contracts/main.mligo" "main" (["isAdmin"] : string list) init_storage initial_balance in
    
    let actual_storage = Test.get_storage_of_address addr in
    let () = Test.log("init_storage: ", init_storage) in
    let () = Test.log("actual_store: ", actual_storage) in
    let () = assert(init_storage = actual_storage) in
    let t_addr = Test.cast_address addr in
    let contr = Test.to_contract t_addr in
    (addr, t_addr, contr)
