# == Class: managedmac::users
#
class managedmac::users ($accounts, $defaults = {}) {

  validate_hash ($accounts)
  validate_hash ($defaults)

  if empty ($accounts) {
    fail('Parameter Error: $accounts is empty')
  } else {
    # Cheating: validate that the value for each key is itself a Hash
    $check_hash = inline_template("<%= @accounts.reject! {
      |x| x.respond_to? :key } %>")
    
    unless empty($check_hash) {
      fail("Account Error: Failed to parse one or more account data objects:
        ${check_hash}")
    }
    
    create_resources(user, $accounts, $defaults)
  }

}