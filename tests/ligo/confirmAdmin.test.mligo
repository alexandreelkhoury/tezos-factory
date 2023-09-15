#import "./helpers/bootstrap.mligo" "Bootstrap"
#import "../../contracts/errors.mligo" "Contract_Errors"

let () = Test.log("----- testing entrypoints Confirm Admin -----")

let test_success_confirmAdmin = 
    let (admin, user1, _user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source user1 in
    let _ = Test.transfer_to_contract contr (Confirm_admin()) 0mutez in
    ()

let test_failure_confirmAdmin = 
    let (admin, user1, _user2) = Bootstrap.bootstrap_accounts() in
    let (_addr, _t_addr, contr) = Bootstrap.originate_contract(admin) in
    let () = Test.set_source user1 in
    let _ = Test.transfer_to_contract contr (Confirm_admin()) 0mutez in
    ()
