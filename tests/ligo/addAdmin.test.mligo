#import "./helpers/bootstrap.mligo" "Bootstrap"
#import "../../contracts/errors.mligo" "Contract_Errors"

let () = Test.log("-----testing entrypoints for Add Admin-----")

let () = Test.log("-----testing success-----")

let test_success_addAdmin = 
    let (admin, user1, _user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source admin in
    let _ = Test.transfer_to_contract contr (Add_admin(user1)) 0mutez in
    ()

let () = Test.log("-----testing failure-----")

let test_failure_addAdmin_not_admin = 
    let (_admin, user1, user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source user1 in
    let test_result : test_exec_result = Test.transfer_to_contract contr (Add_admin(user2)) 0mutez in
    let () = Test.log(test_result) in
    let () = match  test_result with
        | Fail (Rejected (actual, _)) -> assert(actual = (Test.eval Contract_Errors.only_admin))
        | Fail (Balance_too_low _) -> failwith ("Balance is too low")
        | Fail (Other p) -> failwith (p)
        | Success (_) -> failwith("Test should have failed")
    in
    ()

let test_failure_addAdmin_already_admin = 
    let (admin, user1, _user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source admin in
    let _ = Test.transfer_to_contract contr (Add_admin(user1)) 0mutez in
    let test_result : test_exec_result = Test.transfer_to_contract contr (Add_admin(user1)) 0mutez in
    let () = match  test_result with
        | Fail (Rejected (actual, _)) -> assert(actual = (Test.eval Contract_Errors.already_elligible))
        | Fail (Balance_too_low _) -> failwith ("Balance is too low")
        | Fail (Other p) -> failwith (p)
        | Success (_) -> failwith("Test should have failed")
    in
    ()