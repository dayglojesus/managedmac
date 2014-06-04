require 'pry'
require 'fileutils'
require 'cfpropertylist'

Puppet::Type.type(:remotemanagement).provide(:default) do
  desc "Abstracts the Mac OS X kickstart command, allowing management of the Apple Remote Desktop features."

  commands    :kickstart => '/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart'
  commands    :nc        => '/usr/bin/nc'
  commands    :dscl      => '/usr/bin/dscl'
  commands    :ps        => '/usr/bin/dscl'
  
  confine     :operatingsystem => :darwin
  defaultfor  :operatingsystem => :darwin
  has_feature :enableable

  DSLOCAL_USERS_DIR = '/private/var/db/dslocal/nodes/Default/users'
  ARD_PREFERENCES   = '/Library/Preferences/com.apple.RemoteManagement.plist'
  VNC_PASSWORD_FILE = '/Library/Preferences/com.apple.VNCSettings.txt'
  VNC_SEED          = '1734516E8BA8C5E2FF1C39567390ADCA'

  mk_resource_methods

  class << self

    def instances
      args = Puppet::Util::CommandLine.new.args
      if args.length > 1
        raise Puppet::Error,
          'Listing specific remotemanagement instances is not supported.'
      end
      [new(get_service_properties)]
    end

    def get_service_properties
      prefs = read_plist(ARD_PREFERENCES)
      { :name                  => 'apple_remote_desktop',
        :ensure                => service_active? ? :running : :stopped,
        :allow_all_users       => prefs['ARD_AllLocalUsers'],
        :all_users_privs       => prefs['ARD_AllLocalUsersPrivs'],
        :enable_menu_extra     => prefs['LoadRemoteManagementMenuExtra'],
        :enable_dir_logins     => prefs['DirectoryGroupLoginsEnabled'],
        :allowed_dir_groups    => prefs['DirectoryGroupList'],
        :enable_legacy_vnc     => prefs['VNCLegacyConnectionsEnabled'],
        :vnc_password          => read_vnc_password(VNC_PASSWORD_FILE),
        :allow_vnc_requests    => prefs['ScreenSharingReqPermEnabled'],
        :allow_wbem_requests   => prefs['WBEMIncomingAccessEnabled'],
        :users                 => get_all_ard_users,
      }.delete_if { |k,v,| v.nil? }
    end

    # Try and determine if Apple Remote Desktop is already activated
    def service_active?
      # Is the VNC port open?
      unless nc('-z', 'localhost', '5900', '> /dev/null')
        info("VNC port not open...")
        return false
      end

      # Is the Remote Management port open?
      unless nc('-u', '-z', 'localhost', '3283', '> /dev/null')
        info("Remote Management port not open...")
        return false
      end

      # Is the trigger file present?
      return false unless File.exists? '/private/etc/RemoteManagement.launchd'

      # Is the ARDAgent running?
      unless ps('axc', '| grep ARDAgent', '> /dev/null')
        info("ARD agent not running...")
        return false
      end
      true
    end

    def read_vnc_password(path)
      result = nil
      if File.exists?(path)
        if file = File.read(path)
          if file.length == 32
            seed = convert_to_hex VNC_SEED
            pass = convert_to_hex file
            result = seed.inject('') do |memo,byte|
              memo << (byte ^ (pass.shift || 0))
              memo.delete("\0")
            end
          end
        end
      end
      result
    end

    def convert_to_hex(string)
      string.scan(/../).collect { |byte| byte.hex }
    end

    def get_all_ard_users
      raw = `/usr/bin/dscl . list /Users naprivs`
      Hash[*raw.split]
    end

    def read_plist(path)
      plist = CFPropertyList::List.new(:file => path)
      return {} unless plist
      CFPropertyList.native_types(plist.value)
    end

  end

  def initialize(value={})
    super(value)
    @property_hash  = self.class.get_service_properties
    @property_flush = {}
  end

  def running?
    @property_hash[:ensure] == :running
  end

  def start
    @property_flush[:ensure] = :running
  end
  
  def stop
    @property_flush[:ensure] = :stopped
  end
  
  def vnc_password=(value)
    seed = self.class.convert_to_hex VNC_SEED
    pass = value.unpack('C*')
    result = seed.inject('') do |memo,byte|
      memo << "%02X" % (byte ^ (pass.shift || 0))
      memo
    end
    if result.size == 32
      begin
        File.write(VNC_PASSWORD_FILE, result)
      rescue
        raise Puppet::Error, "Could not save VNC Password!"
      end
    end
  end
  
  def flush
    binding.pry
    if @property_flush[:ensure] == :stopped
      # stop the service
    else
      # set_content
      # set_owner
      # set_group
      # set_mode
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = self.class.get_service_properties
  end
  
end
