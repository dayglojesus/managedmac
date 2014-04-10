require 'puppet/provider/mobileconfig'

Puppet::Type.type(:mobileconfig).provide(:activedirectory, 
  :parent => Puppet::Provider::MobileConfig) do
  
  commands :profiles => '/usr/bin/profiles'
  
  mk_resource_methods
  
  # Override the #content getter so that we can interecept any
  # any Password key/values.
  #
  # This has to do with the manner which we determine whether or not a profile
  # is actually installed. When /usr/bin/profiles returns the list of
  # installed profiles, it scrubs passwords, so we can never know the real
  # value. This isn't such a problem for a bind operation, but it does mean
  # that this value is NOT idempotent (ie. changes to this value, will not
  # trigger a puppet apply).
  #
  def content
    if @resource[:content]
      return @property_hash[:content].each_with_index.map do |hash, i|
        if hash.key?('Password')
          hash['Password'] = @resource[:content][i]['Password']
          hash
        end
      end
    end
    @property_hash[:content]
  end
  
  # Override the #transform_content method
  #
  # The Advanced Active Directory profile contains flag keys which inform
  # the installation process which configuration keys should actually be
  # activated.
  # 
  # http://support.apple.com/kb/HT5981?viewlocale=en_US&locale=en_US
  #
  # For example, if we wanted to change the default shell for AD accounts, we
  # would actually need to define two keys: a configuration key and a flag key.
  # 
  # <key>ADDefaultUserShell</key>
  # <string>/bin/zsh</string>
  # 
  # <key>ADDefaultUserShellFlag</key>
  # <true/>
  #
  # If you fail to specify this second key (the activation or "flag" key), the
  # configuration key will be ignored when the mobileconfig is processed.
  #
  # To avoid having to activate and deactivate the configuration keys, we
  # pre-process the content array by overriding the transform_content method
  # and shoehorn these flag keys into place dynamically, as required.
  #
  def transform_content(content)
    return [] if content.empty?
    needs_flag = ['ADAllowMultiDomainAuth',
                  'ADCreateMobileAccountAtLogin',
                  'ADDefaultUserShell',
                  'ADDomainAdminGroupList',
                  'ADForceHomeLocal',
                  'ADNamespace',
                  'ADPacketEncrypt',
                  'ADPacketSign',
                  'ADPreferredDCServer',
                  'ADRestrictDDNS',
                  'ADTrustChangePassIntervalDays',
                  'ADUseWindowsUNCPath',
                  'ADWarnUserBeforeCreatingMA',]
    
    needs_flag.each do |e|
      content.collect! do |payload|
        if payload.key?(e)
          flag_key = e + 'Flag'
          payload[flag_key] = true
        end
        payload
      end
    end
    super(content)
  end
  
end