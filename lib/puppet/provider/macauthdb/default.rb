require 'sqlite3'
require 'cfpropertylist'

Puppet::Type.type(:macauthdb).provide(:default) do

  desc "Manage Mac OS X authorization database rules and rights."

  defaultfor :operatingsystem  => :darwin
  commands   :security         => '/usr/bin/security'

  mk_resource_methods

  DEFAULTS = '/System/Library/Security/authorization.plist'
  AUTH_DB  = '/private/var/db/auth.db'

  SCHEMA  = ['id', 'name', 'type', 'class', 'group', 'kofn', 'timeout',
    'flags', 'tries', 'version', 'created', 'modified', 'hash',
    'identifier', 'requirement', 'comment']

  PROPERTIES = [ :allow_root, :authenticate_user,
    :auth_class, :auth_type, :comment, :group, :kofn, :mechanisms, :rule,
    :session_owner, :shared, :timeout, :tries ]

  FLAGS = [ 'shared', 'allow-root', 'session-owner', 'authenticate-user',
    'extract-password', 'entitled', 'entitled-group', 'require-apple-signed',
    'vpn-entitled-group' ]

  class << self

    def instances
      list_all_rights_and_rules.collect do |rule|
        rule_properties = get_resource_properties(rule)
        new(rule_properties)
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

    def list_all_rights_and_rules
      exec_sql_statement 'select * from rules'
    end

    # Return the Puppet resource as a Hash
    def get_resource_properties(array)
      return {} if array.nil?
      row = process_db_row array
      row[:ensure] = :present
      row
    end

    def process_db_row(array)
      Hash[SCHEMA.zip(array)].inject({}) do |memo, (k,v)|
        unless v.nil? or k =~ /created|modified|hash|identifier|requirement|id|version/
          case k
          when 'class'
            memo["auth_#{k}".to_sym] = convert_class v
          when 'type'
            memo["auth_#{k}".to_sym] = convert_type v
          when 'flags'
            c = memo[:auth_class]
            unpack_flags(c, v).each { |k,v| memo[k.gsub('-', '_').to_sym] = v }
          else
            memo[k.to_sym] = v
          end
        end
        memo
      end
    end

    def convert_class(int)
      classes = ['user', 'rule', 'evaluate-mechanism', 'allow', 'deny']
      classes[int - 1]
    end

    def convert_type(int)
      types = ['right', 'rule']
      types[int - 1]
    end

    # Unpack the 'flags' Integer
    # - params are the 'class' and 'flags' column values
    # - flags is just a C bit-field describing the state of various keys
    # - we expand them into a Hash and constrain them accordingly
    # Class constraints based on...
    # http://opensource.apple.com/source/Security/Security-55471/authd/rule.c
    # See Line 919. Some of the auth classes return keys, even when they're
    # false. Anyway, we use the array indices as identifiers for the flags.
    def unpack_flags(auth_class, flags)
      FLAGS.each_with_index.inject({}) do |memo,(key,i)|
        value = (flags & (1 << i)).zero? ? false : true
        case auth_class
        when 'user'
          memo[key] = value if value or (0..3).member?(i)
        when 'evaluate-mechanism'
          memo[key] = value if value or i == 0
        else
          memo[key] = value if value
        end
        memo
      end
    end

    # Reconstitute the list of flags as an Integer
    # - accepts a Hash of normalized data
    def pack_flags(flags)
      FLAGS.each_with_index.inject(0) do |memo,(key,i)|
        memo |= i if flags[key]
        memo
      end
    end

    def exec_sql_statement(string, *args)
      begin
        db = SQLite3::Database.new(AUTH_DB)
        op = db.prepare string
        results = op.execute(*args)
        results.to_a
      rescue SQLite3::Exception => e
        raise Puppet::Error, "Could not exec SQL: `#{e}`"
      ensure
        op.close if op
        db.close if db
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

  def default
    @property_flush[:ensure] = :default
  end

  def security_remove_right_or_rule
    security "authorizationdb", :remove, resource[:name]
  end

  def normalize_resource_data
    PROPERTIES.inject({}) do |memo,key|
      value = resource[key].is_a?(Symbol) ? resource[key].to_s : resource[key]
      if value
        key = key.to_s.gsub('_', '-')
        key.gsub!('auth-class', 'class')
        memo[key] = value unless key.eql? 'auth-type'
      end
      memo
    end
  end

  # Use `security` to create or modify the right or rule
  def security_create_right(data)
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(data)
    tmp = Tempfile.new('puppet_macauthdb')
    begin
      plist.save(tmp.path, CFPropertyList::List::FORMAT_XML)
      tmp.close
      cmds = [:security, "authorizationdb", "write", resource[:name]]
      execute(cmds, :failonfail => false, :combine => false, 
        :stdinfile => tmp.path.to_s)
    rescue Errno::EACCES => e
      raise Puppet::Error.new("Cannot save right to #{tmp.path}: #{e}")
    ensure
      tmp.unlink
    end
  end

  def sql_create_rule(data)
    sql = {
      'name'     => resource[:name],
      'type'     => 2,
      'class'    => data['class'] || 1,
      'group'    => data['group'],
      'timeout'  => 2147483647,
      'flags'    => self.class.pack_flags(data),
      'tries'    => 10000,
      'version'  => data['version'],
      'created'  => 407288069.183469,
      'modified' => 407288069.183469,
      'comment'  => data['comment'],
    }
    columns      = sql.keys.collect { |x| "`#{x}`" }.join(',')
    values       = sql.values
    placeholders = (['?'] * sql.values.size).join(',')
    statement = %Q{replace into rules (#{columns}) values (#{placeholders})}

    self.class.exec_sql_statement statement, values
  end

  def retreive_defaults
    plist = CFPropertyList::List.new(:file => DEFAULTS)
    data  = CFPropertyList.native_types(plist.value)
    type  = (resource[:auth_type] || 'right').to_s + 's'
    data[type][resource[:name]]
  end

  def create_by_type_with_data(type, data)
    if type == :rule
      sql_create_rule(data)
    else
      security_create_right(data)
    end
  end

  def flush
    case @property_flush[:ensure] || :present
    when :absent
      security_remove_right_or_rule
    when :present
      data = normalize_resource_data
      create_by_type_with_data resource[:auth_type], data
    when :default
      data = retreive_defaults
      create_by_type_with_data resource[:auth_type], data
    else
      raise Puppet::Error, "Invalid action passed to ensure param: `#{action}`"
    end

    query = %Q{select * from rules where name is "#{resource[:name]}"}
    results = self.class.exec_sql_statement query
    @property_hash = self.class.get_resource_properties(results.first)
  end

end
