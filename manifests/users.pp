# == Class: managedmac::users
#
# Dynamically create Puppet User resources using the Puppet built-in
# 'create_resources' function.
#
# We do some validation of data, but the usual caveats apply: garbage in,
# garbage out.
#
# === Parameters
#
# [*accounts*]
#   This is a Hash of Hashes.
#   The hash should be in the form { title => { parameters } }.
#   See http://tinyurl.com/7783b9l, and the examples below for details.
#   Type: Hash
#
# [*defaults*]
#   A Hash that defines the default values for the resources created.
#   See http://tinyurl.com/7783b9l, and the examples below for details.
#   Type: Hash
#
# === Variables
#
# Not applicable
#
# === Examples
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
# # Example: defaults.yaml
# ---
# managedmac::users::defaults:
#
# managedmac::users::accounts:
#   foo:
#     uid: 505
#     iterations: 32786
#     password: 4f5942e989e7566955d42421dc4b80c0fa45f6fb2ecbc1026b2183060c8ecbec38582b1a8a6459574ebe1a2d7884d9e8d2a460e8ea3fcf179964a6325a688d7ee7cc60bbb8b8abf252c6a6a799760da0b0fe6e4562f506b2355b03f272580ed9bdbbae55152dfbac066d9c62a799ee184f9904da153a3c20d66657cf3b60d5c8
#     salt: 77586e8902d744f650758b402b44e174d7943b10b145c921b3b71affbaf9a32d
#   bar:
#     uid: 506
#     iterations: 32786
#     password: a85ea7ce2df74b13be298d6584edbb35558b74616a70e579252416a6b76d0a615c88b7d566280fa5e035e8db7b1a0c4e3ee4b8cd6204652dcb6c89e6e450a60ca7ed0cc9fa545326ca25211e6f600835f50642ab9d407fa30999c68c05b92d9281eff4a66c67f44ed2f8b8eaf8b62283db202bc98e21c0df9a95cf9abb359b69
#     salt: 9ab79307a7bfbb293b4f015ae748d227423481bcd4e5801f450697d15fb67144
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::users
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  # Create some Hashes
#  # Our $defaults specify that users we create are mebers of the Staff group
#  # (gid: 20), but individual resources can override this value as per the
#  # "bar" user resource -- which gets gid: 80 (admin).
#  $defaults = { 'gid' => 20, }
#  $accounts = {
#     'foo' => { 'uid' => 511, },
#     'bar' => { 'uid' => 522, 'gid' => 80},
#  }
#
#  class { 'managedmac::users':
#    accounts => $accounts,
#    defaults => $defaults,
#  }
#
# === Authors
#
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2015 Simon Fraser University, unless otherwise noted.
#
class managedmac::users (

  $accounts = {},
  $defaults = {},

) {

  unless empty ($accounts) {

    validate_raw_constructor ($accounts)
    validate_hash ($defaults)
    create_resources(user, $accounts, $defaults)

  }

}