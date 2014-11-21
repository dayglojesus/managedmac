require 'date'
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

  ATTRIBS = %w(id name type class "group" kofn timeout flags tries comment)

  PROPERTIES = [ :auth_class, :auth_type, :group, :mechanisms, :rule,
    :comment, :kofn, :timeout, :tries, :shared, :allow_root,
    :session_owner, :authenticate_user, :extract_password, :entitled,
    :entitled_group, :require_apple_signed, :vpn_entitled_group ]

  FLAGS = [ 'shared', 'allow-root', 'session-owner', 'authenticate-user',
    'extract-password', 'entitled', 'entitled-group', 'require-apple-signed',
    'vpn-entitled-group' ]

  CLASSES = ['user', 'rule', 'evaluate-mechanisms', 'allow', 'deny']

  TYPES = ['right', 'rule']

  class << self

    def instances
      list_all_rights_and_rules.collect do |rule|
        new(rule)
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
      begin
        @dbconn = SQLite3::Database.new(AUTH_DB)
        all_rules = exec_sql_statement @dbconn, "SELECT #{ATTRIBS.join(', ')} FROM rules"
        processed = all_rules.collect do |rule|
          rule_properties = get_resource_properties(@dbconn, rule)
        end
      rescue Exception => e
        raise Puppet::Error, "Could not exec SQL: `#{e}`"
      ensure
        @dbconn.close if @dbconn
      end
      @dbconn.close if @dbconn
      processed
    end

    def exec_sql_statement(dbconn, string, *args)
      begin
        op      = dbconn.prepare string
        results = op.execute(*args)
        array   = results.to_a
        op.close if op
      rescue Exception => e
        raise Puppet::Error, "Could not exec SQL: `#{e}`"
      end
      array
    end

    # SQL taken from the Apple source code
    # http://opensource.apple.com/source/Security/Security-55471/authd/rule.c
    def get_delegates(dbconn, rule_id)
      expr = "SELECT rules.* \
              FROM rules JOIN delegates_map \
              ON rules.id = delegates_map.d_id \
              WHERE delegates_map.r_id = ? \
              ORDER BY delegates_map.ord ASC"

      exec_sql_statement(dbconn, expr, rule_id).map { |r| r[1] }
    end

    # SQL taken from the Apple source code
    # http://opensource.apple.com/source/Security/Security-55471/authd/rule.c
    def get_mechanisms(dbconn, rule_id)
      expr = "SELECT mechanisms.* \
              FROM mechanisms \
              JOIN mechanisms_map ON mechanisms.id = mechanisms_map.m_id \
              WHERE mechanisms_map.r_id = ? \
              ORDER BY mechanisms_map.ord ASC"

      exec_sql_statement(dbconn, expr, rule_id).map { |r| r[1..2].join(':') }
    end

    # Return the Puppet resource as a Hash
    def get_resource_properties(dbconn, array)
      return {} if array.nil?
      row = process_db_row dbconn, array
      row[:ensure] = :present
      row
    end

    def process_db_row(dbconn, array)
      Hash[ATTRIBS.zip(array)].inject({}) do |memo, (k,v)|
        if k.eql?('id')
          mechanisms        = get_mechanisms(dbconn, v)
          memo[:mechanisms] = mechanisms unless mechanisms.empty?
          rule              = get_delegates(dbconn, v)
          memo[:rule]       = rule unless rule.empty?
        end

        unless v.nil? or k =~ /id/
          case k
          when '"group"'
            memo[:group] = v
          when 'class'
            memo["auth_#{k}".to_sym] = convert_int_to_class v
          when 'type'
            memo["auth_#{k}".to_sym] = convert_int_to_type v
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

    def convert_int_to_class(int)
      return 'user' unless int
      CLASSES[int - 1]
    end

    def convert_int_to_type(int)
      return 'right' unless int
      TYPES[int - 1]
    end

    def convert_class_to_int(string)
      return 1 unless string
      CLASSES.index(string) + 1
    end

    def convert_type_to_int(string)
      return 1 unless string
      TYPES.index(string) + 1
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
        when 'evaluate-mechanisms'
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
        memo |= (1 << i) if flags[key]
        memo
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
    # Need to have a more thorough #exists?
    # When @property_hash[:ensure] == :default, we need to check that.
    # 1. load the defaults
    # 2. return true/false based comparison of state with defaults
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
      source = @property_hash.empty? ? @resource : @property_hash
      value  = source[key].is_a?(Symbol) ? source[key].to_s : source[key]
      if value
        key = key.to_s.gsub('_', '-')
        key.gsub!('auth-class', 'class')
        key.gsub!('auth-type', 'type')
        memo[key] = value
      end
      memo
    end
  end

  # Use `security` to create or modify the right or rule
  def security_create_right(data)
    plist        = CFPropertyList::List.new
    plist.value  = CFPropertyList.guess(data)
    tmp          = Tempfile.new('puppet_macauthdb')
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

  # Timestamp in decimal
  # Apple uses Jan 01, 2001 as the epoch
  def timestamp
    ((DateTime.now) << 12 * 31).to_time.to_f
  end

  # Prepares the data processing by #sql_create_rule
  def prepare_rule_data(data)
    data['type']  = 2
    data['flags'] = self.class.pack_flags(data)
    data['class'] = self.class.convert_class_to_int(data['class']) || 1

    defaults = {
      'flags'    => 0,
      'version'  => 0,
      'created'  => timestamp,
      'modified' => timestamp,
    }

    class_defaults = [
      defaults.merge(Hash['timeout', 2147483647, 'flags', 9, 'tries', 10000]),
      defaults,
      defaults,
      defaults.merge(Hash['flags', 1, 'tries', 10000]),
      defaults.merge(Hash['kofn', 1, 'flags', 0 ]),
    ]

    data       = class_defaults[data['class']].merge(data)
    rule       = data.delete('rule')
    mechanisms = data.delete('mechanisms')

    [data, rule, mechanisms]
  end

  # Fetches the appropriate rules row and converts results to a Hash
  def sql_get_rule(dbconn, name)
    name_query = %Q{SELECT * FROM rules WHERE name = '#{name}'}
    result     = self.class.exec_sql_statement(@dbconn, name_query).first
    result.nil? ? {} : Hash[SCHEMA.zip(result)] || {}
  end

  # Returns the updated rule as a Hash
  def sql_insert_or_udpate_rules(dbconn, op, data)
    statement = case op
    when :insert
      columns      = data.keys.collect { |x| "`#{x}`" }.join(',')
      placeholders = (['?'] * data.values.size).join(',')
      %Q{INSERT INTO rules (#{columns}) VALUES (#{placeholders})}
    else
      data.delete_if { |k| %w{name created}.member?(k) }
      columns = data.keys.map { |k| "`#{k}` = ?" }
      %Q{UPDATE rules SET #{columns.join(', ')} WHERE name = '#{name}'}
    end
    self.class.exec_sql_statement(dbconn, statement, data.values)
    sql_get_rule dbconn, name
  end

  # Update the delegates_map table with the modified list of rules
  def sql_update_delegates_map(dbconn, the_rule, delegates)
    delete = "DELETE FROM delegates_map WHERE r_id = ?"
    self.class.exec_sql_statement(dbconn, delete, the_rule['id'])

    unless delegates.empty?
      rules = delegates.map do |name|
        query = %Q{SELECT * FROM rules WHERE name = ?}
        self.class.exec_sql_statement(dbconn, query, the_rule['name']).first
      end
      mapping = "INSERT INTO delegates_map VALUES (?,?,?)"
      rules.each_with_index do |rule, i|
        row = [the_rule['id'], rule[0], i]
        self.class.exec_sql_statement(dbconn, mapping, row)
      end
    end
  end

  # Update the mechanisms_map table with the modified list of mechanisms
  def sql_update_mechanisms_map(dbconn, the_rule, mechanisms)
    delete = "DELETE FROM mechanisms_map WHERE r_id = ?"
    self.class.exec_sql_statement(dbconn, delete, the_rule['id'])

    unless mechanisms.empty?
      mechs = mechanisms.map do |value|
        plugin, param = value.split(':')
        query = %Q{SELECT * FROM mechanisms WHERE plugin = ? and param = ?}
        self.class.exec_sql_statement(dbconn, query, [plugin, param]).last
      end
      mapping = "INSERT INTO mechanisms_map VALUES (?,?,?)"
      mechs.each_with_index do |mech, i|
        row = [the_rule['id'], mech[0], i]
        self.class.exec_sql_statement(dbconn, mapping, row)
      end
    end
  end

  def sql_create_rule(data)
    name = resource[:name]
    data, delegates, mechanisms = prepare_rule_data data

    begin
      @dbconn  = SQLite3::Database.new(AUTH_DB)
      the_rule = sql_get_rule @dbconn, name

      # Create a composite of state for comparison, but ignore timestamps
      composite = the_rule.merge(data) do |key, v1, v2|
        %w{created modified}.member?(key) ? v1 : v2
      end

      # Update the main table 'rules' as required
      unless composite == the_rule
        op       = the_rule.empty? ? :insert : :update
        the_rule = sql_insert_or_udpate_rules @dbconn, op, data
      end

      # Update the map tables
      sql_update_mechanisms_map(@dbconn, the_rule, mechanisms) if mechanisms
      sql_update_delegates_map(@dbconn, the_rule, delegates)   if delegates

    rescue Exception => e
      raise Puppet::Error, "Could not exec SQL: `#{e}`"
    end

  end

  def retreive_defaults(type)
    plist = CFPropertyList::List.new(:file => DEFAULTS)
    data  = CFPropertyList.native_types(plist.value)
    data[type + 's'][resource[:name]] || { :name => resource[:name] }
  end

  def create_by_type_with_data(type, data)
    if type.to_s.eql?('rule')
      sql_create_rule(data)
    else
      security_create_right(data)
    end
  end

  def flush
    type = @property_hash[:auth_type] || resource[:auth_type]
    case @property_flush[:ensure] || :present
    when :absent
      security_remove_right_or_rule
    when :present
      create_by_type_with_data type, normalize_resource_data
    when :default
      create_by_type_with_data type, retreive_defaults(type)
    else
      raise Puppet::Error, "Invalid action passed to ensure param: `#{action}`"
    end

    begin
      query   = %Q{SELECT * FROM rules WHERE name IS "#{resource[:name]}"}
      @dbconn = SQLite3::Database.new(AUTH_DB)
      results = self.class.exec_sql_statement @dbconn, query
      @property_hash = self.class.get_resource_properties(@dbconn, results.first)
    rescue Exception => e
      raise Puppet::Error, "Could not exec SQL: `#{e}`"
    ensure
      @dbconn.close if @dbconn
    end
  end

end
