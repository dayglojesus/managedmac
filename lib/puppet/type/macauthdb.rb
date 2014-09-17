require 'puppet/property/boolean'

Puppet::Type.newtype(:macauthdb) do

  @doc = %q{Manage the OS X authorization database. See the
    [Apple developer site](http://developer.apple.com/library/mac/documentation/Security/Conceptual/AuthenticationAndAuthorizationGuide/Introduction/Introduction.html)
    for more information.

    Note that authorization store directives with hyphens in their names have
    been renamed to use underscores, as Puppet does not react well to hyphens
    in identifiers.

    **Autorequires:** If Puppet is managing the `/System/Library/Security/authorization.plist` file, each
    macauthdb resource will autorequire it.

    Example:

    # Allow everyone to modify Energy Saver settings in the System Prefernces control panel

    # First change the parent class
    macauthdb { 'system.preferences':
      ensure            => 'present',
      allow_root        => 'true',
      auth_class        => 'user',
      auth_type         => 'right',
      authenticate_user => 'true',
      comment           => 'Checked by the Admin framework when making changes to certain System Preferences.',
      group             => 'everyone',
      session_owner     => 'false',
      shared            => 'true',
      timeout           => '2147483647',
      tries             => '10000',
    }

    # Then change the target
    macauthdb { 'system.preferences.energysaver':
      ensure            => 'present',
      allow_root        => 'true',
      auth_class        => 'user',
      auth_type         => 'right',
      authenticate_user => 'true',
      comment           => 'Checked by the Admin framework when making changes to the Energy Saver preference pane.',
      group             => 'everyone',
      session_owner     => 'false',
      shared            => 'true',
      timeout           => '2147483647',
      tries             => '10000',
    }

  }

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    newvalue(:default) do
      provider.default
    end
  end

  autorequire(:file) do
    ['/System/Library/Security/authorization.plist']
  end

  def munge_integer(value)
    Integer(value)
  rescue ArgumentError
    fail("munge_integer only takes integers")
  end

  newparam(:name) do
    desc "The name of the right or rule to be managed.
    Corresponds to `key` in Authorization Services. The key is the name
    of a rule. A key uses the same naming conventions as a right. The
    Security Server uses a rule's key to match the rule with a right.
    Wildcard keys end with a '.'. The generic rule has an empty key value.
    Any rights that do not match a specific rule use the generic rule."

    isnamevar
  end

  newproperty(:auth_class) do
    desc "Corresponds to `class` in the authorization store; renamed due
    to 'class' being a reserved word in Puppet."

    newvalue('user')
    newvalue('evaluate-mechanisms')
    newvalue('allow')
    newvalue('deny')
    newvalue('rule')
  end

  newproperty(:auth_type) do
    desc "Corresponds to `class` in the authorization store; renamed due
    to 'class' being a reserved word in Puppet."

    newvalue('right')
    newvalue('rule')
  end

  newproperty(:group) do
    desc "A group which the user must authenticate as a member of. This
    must be a single group."
  end

  newproperty(:mechanisms, :array_matching => :all) do
    desc "A sequence of suitable mechanisms to be evaluated. (Array)"
  end

  newproperty(:rule, :array_matching => :all) do
    desc "The rule(s) that this right refers to."
  end

  newproperty(:comment) do
    "String that describes what the rule or right is used for."
  end

  ##################
  # INTS
  ##################

  newproperty(:kofn) do
    desc "How large a subset of rule mechanisms must succeed for successful
    authentication. If there are 'n' mechanisms, then 'k' (the integer value
    of this parameter) mechanisms must succeed. The most common setting for
    this parameter is `1`. If `k-of-n` is not set, then every mechanism ---
    that is, 'n-of-n' --- must succeed."

    munge do |value|
      @resource.munge_integer(value)
    end
  end

  newproperty(:timeout) do
    desc "The number of seconds in which the credential used by this rule will
    expire. For maximum security where the user must authenticate every time,
    set the timeout to 0. For minimum security, remove the timeout attribute
    so the user authenticates only once per session."

    munge do |value|
      @resource.munge_integer(value)
    end
  end

  newproperty(:tries) do
    desc "The number of tries allowed."
    munge do |value|
      @resource.munge_integer(value)
    end
  end

  ##################
  # BOOL
  ##################

  newproperty(:shared, :parent => Puppet::Property::Boolean) do
    desc "Whether the Security Server should mark the credentials used to gain
    this right as shared. The Security Server may use any shared credentials
    to authorize this right. For maximum security, set sharing to false so
    credentials stored by the Security Server for one application may not be
    used by another application."
  end

  newproperty(:allow_root) do
    desc "Corresponds to `allow-root` in the authorization store. Specifies
    whether a right should be allowed automatically if the requesting process
    is running with `uid == 0`.  AuthorizationServices defaults this attribute
    to false if not specified."
  end

  newproperty(:session_owner) do
    desc "Whether the session owner automatically matches this rule or right.
    Corresponds to `session-owner` in the authorization store."
  end

  newproperty(:authenticate_user) do
    desc "Corresponds to `authenticate-user` in the authorization store."
  end

  newproperty(:extract_password) do
    desc "Boolean that indicates that the password should be extracted to
    the context."
  end

  newproperty(:entitled) do
    desc "Boolean that indicates whether to grant a right based on the
    entitlement."
  end

  newproperty(:entitled_group) do
    desc "Boolean that indicates whether to grant a right based on the
    entitlement and if the user is a member of the Authorization
    Group (:group)."
  end

  newproperty(:require_apple_signed) do
    desc "Boolean require the caller to be signed by apple."
  end

  newproperty(:vpn_entitled_group) do
    desc "Boolean that indicates whether to grant a right base on the VPN
    entitlement and if the user is a member of the Authorization
    Group (:group)."
  end

end
