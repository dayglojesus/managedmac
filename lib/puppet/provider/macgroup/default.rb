require 'cfpropertylist'
require 'puppet/provider/mobileconfig'

Puppet::Type.type(:macgroup).provide(:default) do

  defaultfor :operatingsystem  => :darwin
  commands   :dscl          => '/usr/bin/dscl'
  commands   :dsmemberutil  => '/usr/bin/dsmemberutil'
  commands   :dseditgroup   => '/usr/sbin/dseditgroup'

  mk_resource_methods

  GROUPS_ROOT  = '/private/var/db/dslocal/nodes/Default/groups'

  class << self

    def instances
      list_all_groups.collect do |group|
        group_properties = get_resource_properties(group)
        new(group_properties)
      end
    end

    # Puppet MAGIC
    def prefetch(resources)
      instances.each do |prov|
        if resource = resources[prov.name]
          resource.provider = prov
        end
      end
    end

    def list_all_groups
      file_list = Dir.glob("#{GROUPS_ROOT}/*.plist")
      file_list.collect do |file|
        parse_propertylist(file)
      end
    end

    # Return the Puppet resource as a Hash
    def get_resource_properties(dict)
      return {} if dict.nil?

      param_keys = [ :name, :gid, :strict, :users, :nestedgroups,
        :realname, :comment, :ensure, ]
      dict.inject({}) do |memo,(k,v)|
        key = k.to_sym
        if param_keys.member? key
          memo[key] = [:users, :nestedgroups].member?(key) ? v : v.first
        end
        memo[:ensure] = :present
        memo
      end
    end

    # Parse a plist and return a Ruby object
    def parse_propertylist(file)
      plist = CFPropertyList::List.new(:file => file)
      raise Puppet::Error, "Cannot parse: #{file}" if plist.nil?
      CFPropertyList.native_types(plist.value)
    end

  end

  def initialize(value={})
    super(value)
    @property_flush = {}
    @dslocal_root = '/Local/Default'
  end

  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @original_properties = @property_hash.dup
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  # Method for handling the two membership setter attributes
  def update_membership(type)
    type = type.to_sym
    unless [:users, :nestedgroups].member? type
      raise Puppet::Error, "unknown membership type: #{type}"
    end

    desired_state = @resource.should(type).compact

    if @resource[:strict] == :false
      current_state = Array(@original_properties[type])
      desired_state = current_state | desired_state
    end

    unique_members = desired_state.uniq

    desired_state.detect do |e|
      if desired_state.count(e) > 1
        Puppet::Util::Warnings.warnonce(
          "Macgroup: duplicate group specified! #{e}. Ignoring...")
      end
    end

    name = @resource[:name]
    args = [@dslocal_root, 'create', "/Groups/#{name}", type.to_s,
      *unique_members]

    dscl(args)
  end

  # Provider Helper method
  # Create the group OR destroy it
  def manage_group

    name         = @resource[:name]
    comment      = @resource[:comment]  || @property_hash[:comment]
    realname     = @resource[:realname] || @property_hash[:realname]
    gid          = @resource[:gid]      || @property_hash[:gid]
    users        = @resource[:users]
    nestedgroups = @resource[:nestedgroups]

    cmd_args = ['-q', '-o']

    if @property_flush[:ensure] == :absent
      # Destroy the group
      cmd_args += ['delete', name]
      dseditgroup(cmd_args)
    else
      # Edit or Create the group
      op = :edit
      begin
        dseditgroup([cmd_args, 'read', name].flatten)
      rescue Puppet::ExecutionFailure => e
        op = :create
      end
      cmd_args << op

      # The dsmemberutil :edit operation will not edit a GID that already
      # exists, EVEN IF it belongs to the group we are editing!!! So, don't
      # try and edit the GID unless we have to. Of course, if the GID
      # being assigned to the target group already belongs to another entity,
      # a Puppet::ExecutionFailure will be raised, but that's probably a
      # good thing. Probably.
      if gid
        unless gid.to_i == @original_properties[:gid].to_i
          cmd_args += ['-i', "#{gid}"]
        end
      end

      cmd_args += ['-r', "#{realname}" ] if realname
      cmd_args += ['-c', "#{comment}"  ] if comment
      cmd_args << name

      dseditgroup(cmd_args)
      update_membership(:users)        if users
      update_membership(:nestedgroups) if nestedgroups
    end

  end

  # Puppet MAGIC
  # The flush method is called once per resource whenever the
  # 'is' and 'should' values for a property differ
  # (and synchronization needs to occur).
  # As per Shit Gary Says: http://bit.ly/1j9ou3Q
  def flush

    # Do what needs to be done
    manage_group

    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    all_groups = self.class.list_all_groups

    this_group = all_groups.find do |group|
      group['name'].eql? [resource[:name]]
    end

    @property_hash = self.class.get_resource_properties(this_group)
  end

end
