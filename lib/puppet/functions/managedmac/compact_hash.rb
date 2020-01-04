# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----

# ---- original file header ----
#
# @summary
#   Hash keys with empty or undef values are deleted. Returns resulting Hash.
#
#
Puppet::Functions.create_function(:'managedmac::compact_hash') do
  # @param args
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    # Call the method named 'default_impl' when this is matched
    # Port this to match individual params for better type safety
    repeated_param 'Any', :args
  end


  def default_impl(*args)
    

    e = "compact_hash(): Wrong number of args: #{args.size} for 1"
    raise(Puppet::ParseError, e) if args.size != 1

    the_hash = args.shift
    raise(Puppet::ParseError, "arg was not a Hash") unless the_hash.is_a? Hash

    the_hash.delete_if do |k,v|
      (v.empty? if v.respond_to? :empty?) or v == :undef or v.nil?
    end
  
  end
end