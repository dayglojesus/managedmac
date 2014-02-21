# Class: managedmac::ntp
#
#
class managedmac::ntp ($options) {

  validate_hash  ($options)
  validate_array ($options[servers])

  unless is_integer($options[max_offset]) {
    fail("max_offset not an Integer: ${options[max_offset]}")
  }

}