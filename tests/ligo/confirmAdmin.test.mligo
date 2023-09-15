#import "./helpers/bootstrap.mligo" "Bootstrap"
#import "../../contracts/errors.mligo" "Contract_Errors"

let () = Test.log("----- testing entrypoints Confirm Admin -----")

let test_success_confirmAdmin = 
    let (admin, user1, _user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source admin in
    let _ = Test.transfer_to_contract contr (Add_admin(user1)) 0mutez in
    let () = Test.set_source user1 in
    let _ = Test.transfer_to_contract contr (Confirm_admin()) 0mutez in
    ()

let test_failure_confirmAdmin_not_elligible = 
    let (admin, user1, _user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source user1 in
    let test_result : test_exec_result = Test.transfer_to_contract contr (Confirm_admin()) 0mutez in
    let () = match  test_result with
        | Fail (Rejected (actual, _)) -> assert(actual = (Test.eval Contract_Errors.not_elligible))
        | Fail (Balance_too_low _) -> failwith ("Balance is too low")
        | Fail (Other p) -> failwith (p)
        | Success (_) -> failwith("Test should have failed")
    in
    ()

let test_failure_confirmAdmin_already_admin = 
    let (admin, user1, _user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source admin in
    let _ = Test.transfer_to_contract contr (Add_admin(user1)) 0mutez in
    let () = Test.set_source user1 in
    let _ = Test.transfer_to_contract contr (Confirm_admin()) 0mutez in
    let test_result : test_exec_result = Test.transfer_to_contract contr (Confirm_admin()) 0mutez in
    let () = match  test_result with
        | Fail (Rejected (actual, _)) -> assert(actual = (Test.eval Contract_Errors.already_admin))
        | Fail (Balance_too_low _) -> failwith ("Balance is too low")
        | Fail (Other p) -> failwith (p)
        | Success (_) -> failwith("Test should have failed")
    in
    ()
