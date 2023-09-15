#import "ligo-extendable-fa2/lib/multi_asset/fa2.mligo" "FA2"
#import "./errors.mligo" "Errors"

type admins = (address, bool) map
type can_be_admins = (address, bool) map
type whitelist_creators = (address, bool) map
type blacklist_creators = (address, bool) map
// type collections = (address, address) map

type storage = {
    admins : admins;
    can_be_admins : can_be_admins;
    whitelist_creators : whitelist_creators;
    blacklist_creators : blacklist_creators;
    // collections : address set;
}

type parameter =
  Add_admin of address
| Remove_admin of address
| Pay_10tez_to_be_in_the_whitelist_creators
| Confirm_admin
| Blacklist_creators of address
// | Creaet_new_FA2_NFT of map

type return = operation list * storage 

let add_admin (_address : address) (store : storage) : storage =
  let isAdmin = Map.find_opt (Tezos.get_sender()) store.admins in
  let () = if (Option.unopt(isAdmin) <> True) then (failwith Errors.only_admin) in
  let map_opt : bool option = Map.find_opt _address store.can_be_admins in
    match map_opt with
        | Some (_) -> failwith Errors.already_elligible
        | None -> 
        let new_can_be_admins_map = Map.add _address True store.can_be_admins in
        { store with can_be_admins = new_can_be_admins_map }

let remove_admin (_address : address) (store : storage) : storage =
  let isAdmin = Map.find_opt (Tezos.get_sender()) store.admins in
  let () = if (Option.unopt(isAdmin) = not True) then (failwith Errors.only_admin) in
  let map_opt : bool option = Map.find_opt _address store.admins in
    match map_opt with
        | None -> failwith Errors.not_admin
        | Some (_) -> 
        let new_admins_map = Map.remove _address store.admins in
        { store with admins = new_admins_map }

let confirm_admin (store : storage) : storage =
  let isAdmin = Map.find_opt (Tezos.get_sender()) store.admins in
  let () = if (Option.unopt(isAdmin) = True) then (failwith Errors.already_admin) in
  let map_opt : bool option = Map.find_opt (Tezos.get_sender()) store.can_be_admins in
    match map_opt with
        | None -> failwith Errors.not_elligible
        | Some (_) -> 
        let new_admins_map = Map.add (Tezos.get_sender()) True store.admins in
        let new_can_be_admins_map = Map.remove (Tezos.get_sender()) store.can_be_admins in
        { store with admins = new_admins_map; can_be_admins = new_can_be_admins_map }

let pay_10tez_to_be_in_the_whitelist_creators (store : storage) : storage =
  let () = if (Tezos.get_amount() < 10tz) then (failwith Errors.not_enough_tez) in
  let map_opt2 : bool option = Map.find_opt (Tezos.get_sender()) store.whitelist_creators in
  let () = if (Option.unopt(map_opt2) = True) then (failwith Errors.already_whitelisted) in
  let map_opt : bool option = Map.find_opt (Tezos.get_sender()) store.blacklist_creators in
    match map_opt with
        | Some (_) -> failwith Errors.blacklisted
        | None -> 
          let new_whitelist_creators_map = Map.add (Tezos.get_sender()) True store.whitelist_creators in
          { store with whitelist_creators = new_whitelist_creators_map }

let blacklist_creators (_address : address) (store : storage) : storage =
  let isAdmin = Map.find_opt (Tezos.get_sender()) store.admins in
  let () = if (Option.unopt(isAdmin) = not True) then (failwith Errors.only_admin) in
  let map_opt : bool option = Map.find_opt _address store.whitelist_creators in
    match map_opt with
        | None -> failwith Errors.not_creator
        | Some (_) -> 
        let new_blacklist_creators_map = Map.add _address True store.blacklist_creators in
        let new_whitelist_creators_map = Map.remove _address store.whitelist_creators in
        { store with blacklist_creators = new_blacklist_creators_map; whitelist_creators = new_whitelist_creators_map }

// let creaet_new_FA2_NFT (metadata : map) (store : storage) : storage =  
//   let map_opt : bool option = Map.find_opt (Tezos.get_sender()) store.whitelist_creators in
//     match map_opt with
//         | None -> failwith Errors.not_creator
//         | Some (n) ->
//         Tezos.create_contract
//         let new_collections_set = Map.add contract_address store.collections in
//         { store with collections = new_collections_set }

let main (action : parameter) (store : storage) : return =
  ([] : operation list), (match action with 
    |   Add_admin (n) -> add_admin n store 
    |   Remove_admin (n) -> remove_admin n store
    |   Pay_10tez_to_be_in_the_whitelist_creators () -> pay_10tez_to_be_in_the_whitelist_creators store
    |   Confirm_admin () -> confirm_admin store
    |   Blacklist_creators (n) -> blacklist_creators n store)
    // |   Creaet_new_FA2_NFT (n) -> creaet_new_FA2_NFT n store

// [@view] let getCollections () (store : storage) : set(address) =
//           store.collections

[@view] let isAdmin (_address : address) (store : storage) : bool =
            let map_opt : bool option = Map.find_opt _address store.admins in
            match map_opt with
                | None -> failwith Errors.not_admin
                | Some (bool) -> bool