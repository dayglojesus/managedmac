require 'puppet'
require 'open3'

Facter.add("filevault_active") do
  confine :operatingsystem => :darwin
  setcode do
    cmd = '/usr/bin/fdesetup isactive'
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      case wait_thr.value.exitstatus
      when 0, 2
        return true
      end
      false
    end
  end
end
