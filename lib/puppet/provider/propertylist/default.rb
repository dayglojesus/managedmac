require 'etc'
require 'fileutils'
require 'cfpropertylist'

Puppet::Type.type(:propertylist).provide(:default) do

  confine :operatingsystem => :darwin

  mk_resource_methods

  class << self

    def instances
      args = Puppet::Util::CommandLine.new.args
      resource_type, resource_name = args.each { |x| x }
      unless resource_name
        err = ['Listing propertylist instances is not supported.',
        'Please specify a file or directory, e.g. puppet resource file /etc'].join(' ')
        raise Puppet::Error, err
      end
      [ new(get_propertylist_properties(resource_name)) ]
    end

    def prefetch(resources)
      if resource = resources.values.first
        resource.provider = new(get_propertylist_properties(resources.keys.first))
      end
    end

    def get_propertylist_properties(path)
      unless File.exists?(path) and File.file?(path)
        return { :path => path, :ensure => :absent }
      end
      format  = IO.read(path, 8).eql?('bplist00') ? :binary : :xml
      stat    = File.stat path
      content = read_plist path
      {
        :path     => path,
        :format   => format,
        :ensure   => :present,
        :owner    => Etc.getpwuid(stat.uid).name,
        :group    => Etc.getgrgid(stat.gid).name,
        :mode     => stat.mode.to_s(8)[2..-1],
        :content  => content,
      }
    end

    def read_plist(path)
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
    @property_flush = {}
  end

  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def set_owner
    FileUtils.chown resource[:owner], nil, resource[:path]
  end

  def set_group
    FileUtils.chown nil, resource[:group], resource[:path]
  end

  def set_mode
    FileUtils.chmod resource[:mode].to_i(8), resource[:path]
  end

  def set_content
    self.class.write_plist(resource[:path], resource[:content], resource[:format])
  end

  def flush
    if @property_flush[:ensure] == :absent
      FileUtils.rm resource[:path]
    else
      set_content
      set_owner
      set_group
      set_mode
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = self.class.get_propertylist_properties(resource[:path])
  end
end
