require 'puppet'

Facter.add("filevault_active") do
  confine :operatingsystem => :darwin
  setcode do
    %x{/usr/bin/fdesetup isactive}.chomp.eql?('true')
  end
end
