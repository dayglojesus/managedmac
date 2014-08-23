require 'puppet/managedmac/common'

Puppet::Type.newtype(:macgroup) do
  @doc = %q{A drop-in replacement for the built-in Puppet Type: Group

    A custom Puppet type for configuring and managing OS X groups.

    Similar to the built-in Puppet type, Macgroup can manage user membership and
    other attributes of DSLocal group records.

    However, unlike the built-in Puppet type, it also supports management of
    nestedgroups records, aka "Groups-in-Group".

    ==== USAGE ====

    macgroup { 'foo':
      ensure => present,
      realname => 'FooGroup',
      comment => 'Installed by Puppet',
      users => ['foo', 'bar', 'baz'],
      nestedgroups => ["ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050", 'group_two'],
      strict => true,
    }

  }

  ensurable

  newparam(:name) do
    desc %q{The resource name.

    Corresponds to the RecordName/name attribute.
    }
    isnamevar

    # Override #insync?
    # - We only compare the first element of the array
    def insync?(is)
      i, s = [is, should].each do |a|
        Array(a).first
      end
      i.eql? s
    end
  end

  newproperty(:gid) do
    desc %q{The numeric ID for the Group.

      Corresponds to the PrimaryGroupID/gid attribute.

      If you create a new group and do not specify a GID, one will be selected
      for you. However, this is not recommended as it cannot guarantee GID
      specification across a collection of machines. For example, if the same
      resource were applied to two different machines, the GID could not be
      guaranteed to be the same on both, unless you were to configure this
      parameter.

      By the same token, if you do specify a GID parameter, you must ensure
      that the GID will not collide with existing groups on the machine --
      especially built-ins.

      Default is :absent.
    }
    newvalues(/^\d+$/)

    def insync?(is)
      i, s = [is, should].map do |a|
        Array(a.to_i).first
      end
      i == s
    end

    # Normalize the :gid
    munge do |value|
      value.to_i
    end
  end

  newproperty(:users, :array_matching => :all) do
    desc %q{The list of users you want added to the group.

      Corresponds to the GroupMembership/users attribute.

      Membership is managed wholesale, that is, it's purged prior to
      modification unless you set strict => false.

      Please see the documentation on :strict _before_ using this feature.

      To specify users, you pass an Array of user names. The provider will warn
      about an invalid user account, but it will apply the configuration
      anyway. This is to prevent temporary OpenDirectory or network outages
      from wreaking havoc with your Puppet config.

      Note: an empty list is not the same as an absent one. An absent list
      implies that the attribute is unmanaged, while an empty list _is_ managed
      and will create and empty list... Use caution.

      Default is :absent (no management)
    }
    # Validate a user account parameter
    def validate_user(name)
      result = ::ManagedMacCommon::dscl_find_by(:users, 'name', name)
      unless result.respond_to? :first
        raise Puppet::Error,
           "An unknown error occured while searching: #{result}"
      end

      if result.empty?
        Puppet::Util::Warnings.warnonce(
          "Macgroup: User not found: \'#{name}\'")
      end

      name
    end

    # Override #insync?
    # - We need to sort the Arrays before performing an equality test.
    # - We also need to obey the :strict param and compare the Arrays appropriately
    def insync?(is)
      i, s = [is, should].collect do |a|
        if a == :absent
          []
        else
          a = Array(a)
          a.compact!
          a.sort!
        end
      end
      return i.eql? s if resource[:strict] == :true
      (i | s).eql? i
    end

    # Normalize the should parameter
    munge do |value|
      validate_user(value)
    end
  end

  newproperty(:nestedgroups, :array_matching => :all) do
    desc %q{A list of groups you want nested inside the group.

      Corresponds to the NestedGroups/nestedgroups attribute.

      Note: this attribute lists membership according the record's GeneratedUID,
      not the record's' name like the user list.

      Membership is managed wholesale, that is, it's purged prior to
      modification unless you set strict => false.

      Please see the documentation on :strict _before_ using this feature.

      To specify nested groups, you pass an Array of:

      a) Group Names   (ie. "admin", "staff", etc.)
      b) GeneratedUIDs (ie. "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050", etc.)
      c) A mix of both (ie. "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050", "staff")

      When you provide a list of group names, the Macgroup type will attempt to
      resolve the record to its associated GeneratedUID. This is IMPORTANT to
      keep in mind when referring to external node records (ie. LDAP or AD). If
      it cannot resolve the record name to GeneratedUID, the Magroup type will
      generate a warning and _skip_ configuration of the unresolvable record.

      Like the user membership control, this "warn and continue" style of
      resource management is sub-optimal, but provides greater resilience
      during temporary outages.

      For this reason, it is recommended that you list nestegroups according to
      their respective GeneratedUIDs and NOT the record names as this will
      provide the greatest stability (and less log noise).

      Note: an empty list is not the same as an absent one. An absent list
      implies that the attribute is unmanaged, while an empty list _is_ managed
      and will create and empty list... Use caution.

      Default is :absent (no management)
    }
    # Resolve a group name to uuid in OpenDirectory
    # - given a valid name value, return the GeneratedUID for the group
    def group_to_uuid(name)
      result = ::ManagedMacCommon::dscl_find_by(:groups, 'name', name)
      unless result.respond_to? :first
        raise Puppet::Error,
           "An unknown error occured while searching: #{result}"
      end

      if result.empty?
        Puppet::Util::Warnings.warnonce(
          "Macgroup: Group not found: \'#{name}\'")
        return nil
      end

      cmd_args = [::ManagedMacCommon::DSCL, ::ManagedMacCommon::SEARCH_NODE,
        'read', "/Groups/\'#{name}\'", 'GeneratedUID']

      `#{cmd_args.join(' ')}`.chomp.split.last.strip
    end

    # Validate a Group's GeneratedUUID in OpenDirectory
    # - given a valid uuid, find the corresponding record
    # - generates a warning if the uuid cannot be resovled
    # - always returns the GeneratedUID (input)
    def uuid_to_group(uuid)
      result = ::ManagedMacCommon::dscl_find_by(:groups, 'GeneratedUID', uuid)
      unless result.respond_to? :first
        raise Puppet::Error,
           "An unknown error occurred while searching: #{result}"
      end

      if result.empty?
        Puppet::Util::Warnings.warnonce(
          "Macgroup: Group not found: \'#{uuid}\'")
      end

      uuid
    end

    # Override #insync?
    # - We need to sort the Arrays before performing an equality test.
    # - We also need to obey the :strict param and compare the Arrays appropriately
    def insync?(is)
      i, s = [is, should].collect do |a|
        if a == :absent
          []
        else
          a = Array(a)
          a.compact!
          a.sort!
        end
      end
      return i.eql? s if resource[:strict] == :true
      (i | s).eql? i
    end

    # Normalize the should parameter
    munge do |value|
      guid = '\A[0-9A-Z]{8}-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{12}\z'
      if value =~ /#{guid}/
        uuid_to_group(value)
      else
        group_to_uuid(value)
      end
    end
  end

  newparam(:strict) do
    desc %q{How to handle membership in the users and nestedgroups arrays.

      A Boolean value that informs the provider whether to merge the
      specified members into the record, or replace them outright.

      This parameter controls the behavior of BOTH the users and nestedgroups
      arrays.

      By default, the users and nestedgroups arrays will be PURGED and replaced
      by whatever you specify in the resource (ie. strict => true).

      Still, this isn't always what you want. Sometimes, you simply want to
      ensure that the users/groups you specify in the resource are members, and
      ignore any other records in the list(s).

      To accomplish this, you can set the strict parameter to false.

      Default is :true (purge)
    }
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:realname) do
    desc %q{Optional string value that declares the group's RealName.

      Corresponds to the RealName/realname attribute.

      Default is :absent.
    }

    def insync?(is)
      i, s = [is, should].each do |a|
        Array(a).first
      end
      i.eql? s
    end

    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
  end

  newproperty(:comment) do
    desc %q{String that describes the group's purpose.

      Corresponds to the Comment/comment attribute.

      Default is :absent.
    }

    def insync?(is)
      i, s = [is, should].each do |a|
        Array(a).first
      end
      i.eql? s
    end

    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
  end

end
