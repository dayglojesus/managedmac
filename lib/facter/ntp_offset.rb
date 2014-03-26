require 'puppet'
require 'timeout'

Facter.add("ntp_offset") do
  confine :operatingsystem => :darwin
  ntpdate  = "/usr/sbin/ntpdate"
  ntp_conf = "/private/etc/ntp.conf"
  offset   = 0
  if File.exists? ntp_conf
    servers = File.readlines(ntp_conf).collect { |x| x.split.last }
    servers.each do |server|
      output = Timeout::timeout(5) do
        %x{ #{ntpdate} -u -t 0.5 -q #{server} 2> /dev/null }.split("\n").last
      end
      next unless $?.exitstatus == 0
      offset = (output[/(?<label>offset\s+)(?<value>[-+]?\d+\.\d+)(?<unit>.*)/, "value"]).to_f
      break if offset != 0
    end
  end
  setcode do
    offset
  end
end
