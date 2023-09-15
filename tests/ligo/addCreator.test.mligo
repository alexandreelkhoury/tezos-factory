#import "./helpers/bootstrap.mligo" "Bootstrap"
#import "../../contracts/errors.mligo" "Contract_Errors"

let () = Test.log("---- testing entrypoints add creator ----")

let test_success_addCreator = 
    let (admin, user1, _user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source user1 in
    let _ = Test.transfer_to_contract contr (Pay_10tez_to_be_in_the_whitelist_creators()) 10000000mutez in
    ()

let test_failure_addCreator_alreadyCreator = 
    let (admin, user1, _user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source user1 in
    let _ = Test.transfer_to_contract contr (Pay_10tez_to_be_in_the_whitelist_creators()) 10000000mutez in
    let test_result : test_exec_result = Test.transfer_to_contract contr (Pay_10tez_to_be_in_the_whitelist_creators()) 10000000mutez in
    let () = match  test_result with
        | Fail (Rejected (actual, _)) -> assert(actual = (Test.eval Contract_Errors.already_whitelisted))
        | Fail (Balance_too_low _) -> failwith ("Balance is too low")
        | Fail (Other p) -> failwith (p)
        | Success (_) -> failwith("Test should have failed")
    in
    ()

let test_failure_addCreator_not_enough_tez = 
    let (admin, user1, _user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source user1 in
    let test_result : test_exec_result = Test.transfer_to_contract contr (Pay_10tez_to_be_in_the_whitelist_creators()) 0mutez in
    let () = match  test_result with
        | Fail (Rejected (actual, _)) -> assert(actual = (Test.eval Contract_Errors.not_enough_tez))
        | Fail (Balance_too_low _) -> failwith ("Balance is too low")
        | Fail (Other p) -> failwith (p)
        | Success (_) -> failwith("Test should have failed")
    in
    ()