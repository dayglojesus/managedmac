require 'fileutils'
require 'cfpropertylist'
require 'puppet/managedmac/common'

Puppet::Type.type(:remotemanagement).provide(:default) do
  desc "Abstracts the Mac OS X kickstart command, allowing management of the Apple Remote Desktop features."

  commands    :kickstart => '/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart'
  commands    :nc        => '/usr/bin/nc'
  commands    :dscl      => '/usr/bin/dscl'
  commands    :ps        => '/bin/ps'

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
        :allowed_dir_groups    => (prefs['DirectoryGroupList'] || '').split(','),
        :enable_legacy_vnc     => prefs['VNCLegacyConnectionsEnabled'],
        :vnc_password          => read_vnc_password(VNC_PASSWORD_FILE),
        :allow_vnc_requests    => prefs['ScreenSharingReqPermEnabled'],
        :allow_wbem_requests   => prefs['WBEMIncomingAccessEnabled'],
        :users                 => get_all_ard_users,
      }.delete_if { |k,v,| v.nil? }
    end

    def launchd_file_exists?
      [ '/private/etc',
        '/Library/Application Support/Apple/Remote Desktop',
      ].each { |p| File.exists? File.join(p, 'RemoteManagement.launchd') }.any?
    end

    # Try and determine if Apple Remote Desktop is already activated
    def service_active?
      # Is the VNC port open?
      unless system("nc -z localhost 5900 &> /dev/null")
        info("VNC port not open...")
        return false
      end

      # Is the Remote Management port open?
      unless system("nc -u -z localhost 3283 &> /dev/null")
        info("ARD port not open...")
        return false
      end

      # Is the launchd file present?
      return false unless launchd_file_exists?

      # Is the ARDAgent running?
      unless system("ps axc | grep -q ARDAgent")
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
      return {} unless File.exists? path
      plist = CFPropertyList::List.new(:file => path)
      return {} unless plist
      CFPropertyList.native_types(plist.value)
    end

    def write_plist(path, content, format)
      f = case format
      when :xml
        CFPropertyList::List::FORMAT_XML
      when :binary
        CFPropertyList::List::FORMAT_BINARY
      else
        raise Puppet::Error, "Bad Format: #{format}"
      end
      plist = CFPropertyList::List.new
      plist.value = CFPropertyList.guess(content)
      plist.save(path, f, {:formatted => true})
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
    if value.nil? or value.empty?
      FileUtils.rm VNC_PASSWORD_FILE
    end
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

  def service_deactivate
    info("Stopping Apple Remote Desktop...")
    begin
      kickstart "-deactivate", "-stop"
    rescue Puppet::ExecutionFailure
      raise Puppet::Error, "Unable to stop Apple Remote Desktop!"
    end
  end

  def service_activate
    info("Starting Apple Remote Desktop...")
    begin
      kickstart "-activate"
    rescue Puppet::ExecutionFailure
      raise raise Puppet::Error, "Unable to start Apple Remote Desktop!"
    end
  end

  def validate_user(name)
    result = ::ManagedMacCommon::dscl_find_by(:users, 'name', name)
    unless result.respond_to? :first
      raise Puppet::Error,
         "An unknown error occured while searching: #{result}"
    end
    if result.empty?
      Puppet::Util::Warnings.warnonce(
        "#{self.class}: User not found: \'#{name}\'")
      return false
    end
    true
  end

  def configure_access
    info("Configuring Apple Remote Desktop access...")
    assigned_users = resource[:users].inject({}) do |memo,(k,v)|
      if validate_user(k)
        memo[k] = v
      else
        warn("Skipping user \'#{k}\'. User account does not exist.")
      end
      memo
    end
    existing_users = self.class.get_all_ard_users
    combined_users = existing_users.merge(assigned_users)
    combined_users.each do |user,priv|
      if assigned_users.key?(user)
        dscl('.', 'create', "/Users/#{user}", 'naprivs', priv)
      elsif resource[:strict]
        dscl('.', 'delete', "/Users/#{user}", 'naprivs')
      else
        info("Strict mode is off. User \'#{user}\' naprivs retained.")
      end
    end
  end

  def write_preferences
    prefs = {
      'ARD_AllLocalUsers'             => resource[:allow_all_users],
      'ARD_AllLocalUsersPrivs'        => resource[:all_users_privs],
      'LoadRemoteManagementMenuExtra' => resource[:enable_menu_extra],
      'DirectoryGroupLoginsEnabled'   => resource[:enable_dir_logins],
      'DirectoryGroupList'            => resource[:allowed_dir_groups].join(','),
      'VNCLegacyConnectionsEnabled'   => resource[:enable_legacy_vnc],
      'ScreenSharingReqPermEnabled'   => resource[:allow_vnc_requests],
      'WBEMIncomingAccessEnabled'     => resource[:allow_wbem_requests],
    }.delete_if { |k,v| v.nil? }
    self.class.write_plist(ARD_PREFERENCES, prefs, :xml)
    system('/usr/bin/killall', 'cfprefsd')
  end

  def flush
    write_preferences
    configure_access
    if resource[:ensure] == :stopped
      service_deactivate if running?
    else
      service_activate unless running?
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = self.class.get_service_properties
  end

end
