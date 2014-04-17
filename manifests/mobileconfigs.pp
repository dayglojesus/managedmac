# == Class: managedmac::mobileconfigs
#
class managedmac::mobileconfigs ($payloads, $defaults = {}) {

  validate_hash ($payloads)
  validate_hash ($defaults)

  if empty ($payloads) {
    fail('Parameter Error: $payloads is empty')
  } else {
    # Cheating: validate that the value for each key is itself a Hash
    $check_hash = inline_template("<%= @payloads.reject! {
      |x| x.respond_to? :key } %>")

    unless empty($check_hash) {
      fail("Payload Error: Failed to parse one or more payload data objects:
        ${check_hash}")
    }

    create_resources(mobileconfig, $payloads, $defaults)
  }

}