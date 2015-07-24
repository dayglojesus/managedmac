# == Class: managedmac::files
#
# Dynamically create Puppet File resources using the Puppet built-in
# 'create_resources' function.
#
# We do some validation of data, but the usual caveats apply: garbage in,
# garbage out.
#
# === Parameters
#
# There 2 parameters, the $accounts parameter is required.
#
# [*objects*]
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
#
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
# # Example: defaults.yaml
# ---
# managedmac::files::objects:
#   /Users/Shared/example_file_a.txt:
#     ensure: file
#     owner: root
#     group: admin
#     mode: '0644'
#     content: "This is an example of how to create a file using the \
# content parameter."
#   /Users/Shared/example_file_b.txt:
#     ensure: file
#     owner: root
#     group: admin
#     mode: '0644'
#     source: puppet:///modules/my_module/example_file_b.txt
#   /Users/Shared/example_directory:
#     ensure: directory
#     owner: root
#     group: admin
#     mode: '0755'
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::files
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  # Create some Hashes
#  $defaults = { 'owner' => 'root', 'group' => 80, }
#  $objects = {
#     '/Users/Shared/test_file_a.txt' => { 'content' => 'Example A.' },
#     '/Users/Shared/test_file_b.txt' => { 'content' => 'Example B.' },
#  }
#
#  class { 'managedmac::files':
#    objects  => $objects,
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
class managedmac::files (

  $objects  = {},
  $defaults = {},

) {

  unless empty ($objects) {

    validate_raw_constructor ($objects)
    validate_hash ($defaults)
    create_resources(file, $objects, $defaults)

  }

}
