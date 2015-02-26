Puppet::Type.newtype(:dsconfigad) do

  desc %q{Manage OS X Active Directory binding and configuration options.

    A custom Puppet type for scripted binding and AD plugin configuration
    for OS X using the `dsconfigad` utility.

    Most of the accepted parameters map directly to supported options in
    `dsconfigad` and their descriptions are lifted directly from the man page.

    Example:

      dsconfigad { 'some.domain':
        ensure        => 'present',
        computerid    => 'some_machine',
        username      => 'some_user',
        password      => 'a_password',
        ou            => 'CN=Computers',
        domain        => 'some.domain',
        mobile        => 'disable',
        mobileconfirm => 'disable',
        localhome     => 'disable',
        useuncpath    => 'enable',
        protocol      => 'afp',
        shell         => '/bin/false',
        groups        => ['SOME_DOMAIN\some_group','SOME_DOMAIN\another_group'],
        passinterval  => '0',
      }
  }

  class << self

    # Method for testing Array type attribute equality
    define_method(:array_insync?) do |is, should|
      if should == :absent or should.join == ""
        is == :absent
      else
        i, s = [is, should].collect do |a|
          if a == :absent
            []
          else
            a = Array(a)
            a.compact!
            a.sort!
          end
        end
        i.eql? s
      end
    end

    # Method for testing no_flag String type attribute equality
    define_method(:no_flag_insync?) do |is, should|
      return (is == :absent) if (should == :absent or should == "")
      is == should
    end

  end

  ensurable

  newparam(:fqdn) do
    desc %q{The fully-qualified DNS name of the Domain to be used when adding
      the computer to the Directory (e.g. domain.ads.example.com).}
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
    isnamevar
  end

  newparam(:username) do
    desc %q{Username of a Network account that has administrative privileges
      to add/remove this computer to/from the specified Domain}
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
  end

  newparam(:password) do
    desc %q{Password to use in conjunction with the specified username.}
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
  end

  newparam(:computer) do
    desc %q{The "computerid" to add the specified Domain}
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
  end

  newparam(:ou) do
    desc %q{The LDAP DN of the container to use for adding the computer.  If
      this is not specified, it will default to the container "CN=Computers"
      within the domain that was specified.
      (e.g. "CN=Computers,DC=domain,DC=ads,DC=demo,DC=com"}
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
  end

  ######## Bind/Unbind Param modifiers ########
  # - these control the temperment of a bind or unbind operation

  newparam(:force) do
    desc %q{Force the process (i.e., join the existing account or remove the
      binding)}
    newvalues(:enable, :disable)
    defaultto(:enable)
  end

  newparam(:leave) do
    desc %q{Leaves the current domain (preserving the computer record in the
      directory).}
    newvalues(:enable, :disable)
    defaultto(:disable)
  end

  ######## AD Plugin Options: User Experience ########

  newproperty(:mobile) do
    desc %q{This flag determines whether the plugin will enable mobile account
      support for offline logon.}
    newvalues(:enable, :disable)
  end

  newproperty(:mobileconfirm) do
    desc %q{This flag determines whether the plugin will warn the user when a
      mobile account is going to be created.}
    newvalues(:enable, :disable)
  end

  newproperty(:localhome) do
    desc %q{This flag determines whether the plugin forces all home directories
      to be local to the computer (i.e. /Users/username)}
    newvalues(:enable, :disable)
  end

  newproperty(:useuncpath) do
    desc %q{This flag determines whether the plugin uses the UNC specified in
      the Active Directory when mounting the network home.  If this is dis-
      abled, the plugin will look for Apple schema extensions to mount the
      home directory.}
    newvalues(:enable, :disable)
  end

  newproperty(:protocol) do
    desc %q{This flag determines how a home directory is mounted on the
      desktop. By default SMB is used, but AFP can be used for use with
      Mac OS X Server or 3rd Party AFP solutions on Windows Servers}
    newvalues(:smb, :afp)
  end

  newproperty(:sharepoint) do
    desc %q{Enable or disable mounting of the network home as a sharepoint.}
    newvalues(:enable, :disable)
  end

  newproperty(:shell) do
    desc %q{Use the specified shell (e.g., "/bin/bash") if a shell attribute
      does not exist in the directory for the user logging into this computer.
      Use a shell value of "none" to disable use of a default shell, preserving
      values that are only specified in the directory.}
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
  end

  ########  AD Plugin Options: Mappings ########

  newproperty(:uid) do
    desc %q{This specifies the attribute to be used for the UID of the user. By
      default, a UID is generated from the Active Directory GUID.}
    validate do |value|
      unless value.is_a? String or value == :absent
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
    def insync?(is)
      Puppet::Type::Dsconfigad.no_flag_insync? is, should
    end
  end

  newproperty(:gid) do
    desc %q{This specifies the attribute to be used for the GID of the user. By
      default, a GID is derived from the primaryGroupID of the user (typically
      Domain Users).}
    validate do |value|
      unless value.is_a? String or value == :absent
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
    def insync?(is)
      Puppet::Type::Dsconfigad.no_flag_insync? is, should
    end
  end

  newproperty(:ggid) do
    desc %q{This specifies the attribute to be used for the GID of the group.
      By default, a group GID is generated from the Active Directory GUID of
      the group.}
    validate do |value|
      unless value.is_a? String or value == :absent
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
    def insync?(is)
      Puppet::Type::Dsconfigad.no_flag_insync? is, should
    end
  end

  newproperty(:authority) do
    desc %q{This feature is not described in the man page. Enable or disable
      generation of Kerberos authority}
    newvalues(:enable, :disable)
  end

  ######## AD Plugin Options: Administrative ########

  newproperty(:preferred) do
    desc %q{Use the specified server for all Directory lookups and
      authentications. If the server is no longer available, it will fail-over
      to other servers.}
    validate do |value|
      unless value.is_a? String or value == :absent
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
    def insync?(is)
      Puppet::Type::Dsconfigad.no_flag_insync? is, should
    end
  end

  newproperty(:groups, :array_matching => :all) do
    desc %q{Use the listed groups to determine who has local administrative
      privileges on this computer.}
    # Override #insync?
    # - We need to sort the Arrays before performing an equality test.
    def insync?(is)
      Puppet::Type::Dsconfigad.array_insync? is, should
    end
  end

  newproperty(:alldomains) do
    desc %q{This flag determines whether the plugin allows authentication from
      any domain in the forest. When this is enabled, individual domains will
      not be visible, only "All Domains". If it is disabled, you will have the
      ability to select the specific domains that can authenticate to this
      computer. Enabled by default.}
    newvalues(:enable, :disable)
  end

  newproperty(:packetsign) do
    desc %q{By default packet signing is allowed but not required, but can be
      required or disabled (for example if debugging a problem).  This ensures
      that the data to/from the server is not tampered with by another computer
      before received it is received.}
    newvalues(:disable, :allow, :require)
  end

  newproperty(:packetencrypt) do
    desc %q{By default packet encryption is allowed but not required, but can
      be required or disabled (for example if debugging a problem). This
      ensures that the data to/from the server is encrypted and signed
      guaranteeing the content was not tampered with and cannot be seen by
      other computers on the network.}
    newvalues(:disable, :allow, :require)
  end

  newproperty(:namespace) do
    desc %q{Sets the primary account username naming convention. By default it
      is set to "domain" naming which assumes no conflicting user accounts
      across all domains. If your Active Directory forest has conflicts setting
      this to "forest" will prefix all usernames with "DOMAIN\" to ensure
      unique naming between domains (e.g., "ADDOMAIN\user1").
      Warning:  this will change the primary name of the user for all logins.
      Changing this setting on an existing system will cause any existing homes
      to be unused on the local machine.}
    newvalues(:forest, :domain)
  end

  newproperty(:passinterval) do
    desc %q{Set how often the computer trust account password should be changed
       (default 14 days).}
    newvalues(/^\d+$/)
    munge do |value|
      value.to_i
    end
  end

  newproperty(:restrictddns, :array_matching => :all) do
    desc %q{Restricts Dynamic DNS updates to specific interfaces (e.g., en0, en1,
      en2, etc.).  To disable restrictions pass "" as the list.}
    # Override #insync?
    # - We need to sort the Arrays before performing an equality test.
    def insync?(is)
      Puppet::Type::Dsconfigad.array_insync? is, should
    end
  end

end