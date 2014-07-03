require 'puppet/managedmac/common'

Puppet::Type.newtype(:propertylist) do
  desc 'Puppet type for creating OS X PropertyLists and saving them to disk.'

  ensurable

  newparam(:path) do
    desc 'The path to the file to manage. Must be fully qualified.'
    isnamevar

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        fail Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end

    munge do |value|
      if value.start_with?('//') and ::File.basename(value) == "/"
        # This is a UNC path pointing to a share, so don't add a trailing slash
        ::File.expand_path(value)
      else
        ::File.join(::File.split(::File.expand_path(value)))
      end
    end
  end

  newproperty(:owner) do
    desc 'The user to whom the file should belong. Argument should be a user name.'
    defaultto 'root'
  end

  newproperty(:group) do
    desc 'Which group that should own the file. Argument should be a group name.'
    defaultto 'wheel'
  end

  newproperty(:mode) do
    desc 'The desired permissions for the file using standard four-digit octal notation.'

    validate do |value|
      unless value =~ /\A\d{4}\z/
        raise Puppet::Error, "Invalid Parameter: \'#{value}\'"
      end
    end

    munge do |value|
      value.to_s
    end

    defaultto '0644'
  end

  newproperty(:content, :array_matching => :all) do
    desc %q{The file's content, whole or in part.}

    def insync?(is)
      this = [is].flatten
      return this.eql? should if resource[:method] == :replace
      case should
      when Hash
        (this.merge(should)).eql? is
      when Array
        (this | should).eql? is
      when String, Fixnum, Float, TrueClass, FalseClass
        this.eql? should
      else
        fail Puppet::Error, "No equality test for '#{should.class}: (#{should})'"
      end
    end

    # Normalize the :content value
    munge do |value|
      ::ManagedMacCommon::destringify value
    end

    def is_to_s(value)
      value.hash
    end

    alias should_to_s is_to_s

    validate do |value|
      err = 'Content parameter cannot be'
      case value
      when Hash, Array, String
        raise Puppet::Error, "#{err} empty!" if value.empty?
      else
        raise Puppet::Error, "#{err} nil!" if value.nil?
      end
    end
  end

  newproperty(:format) do
    desc 'The PropertyList format the file should use, binary (default) or xml.'
    newvalues(:xml, :binary)
    defaultto :binary
  end

  newparam(:method) do
    desc 'Whether to overwrite the propertylist, or insert the specified data.'
    newvalues(:replace, :insert)
    defaultto :replace
  end

end
