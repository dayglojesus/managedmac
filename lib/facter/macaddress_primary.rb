require 'puppet'

if RUBY_PLATFORM =~ /darwin/
  require 'cfpropertylist'
end

Facter.add("macaddress_primary") do
  confine :operatingsystem => :darwin
  setcode do
    file    = "/Library/Preferences/SystemConfiguration/NetworkInterfaces.plist"
    plist   = CFPropertyList::List.new(:file => file)
    native  = CFPropertyList.native_types(plist.value)
    devices = native['Interfaces'].select { |d|
         d['IOBuiltin'] and
           d['IOInterfaceNamePrefix'].eql?('en') and not
             d['IOPathMatch'] =~ /thunderbolt|usb|firewire/i
    }.sort_by { |d| d['IOInterfaceUnit'] }
    devices[0]['IOMACAddress'].unpack('H*').first.scan(/../).join(':')
  end
end
