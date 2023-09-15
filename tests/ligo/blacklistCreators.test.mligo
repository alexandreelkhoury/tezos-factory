#import "./helpers/bootstrap.mligo" "Bootstrap"
#import "../../contracts/errors.mligo" "Contract_Errors"

let () = Test.log("---- testing entrypoints Blacklist Creators ----")

let test_success_blacklistCreator = 
    let (admin, user1, _user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source user1 in
    let _ = Test.transfer_to_contract contr (Pay_10tez_to_be_in_the_whitelist_creators()) 10000000mutez in
    let () = Test.set_source admin in
    let _ = Test.transfer_to_contract contr (Blacklist_creators(user1)) 0mutez in
    ()

let test_failure_blacklistCreator_not_creator = 
    let (admin, user1, _user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source admin in
    let test_result : test_exec_result = Test.transfer_to_contract contr (Blacklist_creators(user1)) 0mutez in
    let () = match  test_result with
        | Fail (Rejected (actual, _)) -> assert(actual = (Test.eval Contract_Errors.not_creator))
        | Fail (Balance_too_low _) -> failwith ("Balance is too low")
        | Fail (Other p) -> failwith (p)
        | Success (_) -> failwith("Test should have failed")
    in
    ()

let test_failure_blacklistCreator_not_admin = 
    let (_admin, user1, user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source user1 in
    let _ = Test.transfer_to_contract contr (Pay_10tez_to_be_in_the_whitelist_creators()) 10000000mutez in
    let () = Test.set_source user2 in
    let test_result : test_exec_result = Test.transfer_to_contract contr (Blacklist_creators(user1)) 0mutez in
    let () = match  test_result with
        | Fail (Rejected (actual, _)) -> assert(actual = (Test.eval Contract_Errors.only_admin))
        | Fail (Balance_too_low _) -> failwith ("Balance is too low")
        | Fail (Other p) -> failwith (p)
        | Success (_) -> failwith("Test should have failed")
    in
    ()
