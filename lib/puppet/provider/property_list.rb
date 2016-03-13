require 'etc'
require 'fileutils'
require 'cfpropertylist'

class Puppet::Provider::PropertyList < Puppet::Provider

  confine :operatingsystem => :darwin

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
      resources.each do |k,v|
        v.provider = new(get_propertylist_properties(k))
      end
    end

    def get_propertylist_properties(path)
      absent = { :name => path, :ensure => :absent }

      unless File.exists?(path)
        return absent
      end

      unless File.file?(path)
        raise Puppet::Error, "Error: #{path} is not a file, [#{File.ftype(path)}]."
      end

      return absent unless format = get_format(path)

      stat    = File.stat path
      content = read_plist path
      {
        :name     => path,
        :format   => format,
        :ensure   => :present,
        :owner    => Etc.getpwuid(stat.uid).name,
        :group    => Etc.getgrgid(stat.gid).name,
        :mode     => stat.mode.to_s(8)[2..-1],
        :content  => content,
      }
    end

    def read_plist(path)
      begin
        plist = CFPropertyList::List.new(:file => path)
      rescue Exception
        warn("Warning: #{path} is not a Property List.")
      end
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

    def get_format(path)
      bytes = IO.read(path, 8)
      if bytes.eql?('bplist00')
        return :binary
      elsif bytes =~ /\A\<\?xml\sve/
        return :xml
      else
        warn("Error: #{path} is not a Property List.")
        false
      end
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
    path    = resource[:path]
    content = if resource[:content].size != 1
      resource[:content]
    else
      resource[:content].first
    end
    if resource[:method] == :insert
      if File.exists?(path) and File.file?(path)
        original = self.class.read_plist path
        case original
        when Hash
          content = original.merge(content)
        when Array
          content = original.zip(content).collect { |x| x.compact.last }
        else
          content = content
        end
      end
    end
    self.class.write_plist(path, content, resource[:format])
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
