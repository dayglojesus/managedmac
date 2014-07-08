require 'puppet/managedmac/common'

Puppet::Type.newtype(:propertylist) do
  desc %q{Puppet type for managing OS X PropertyLists.

    Suitable for the creation and management of configuration files and
    OS X preference domain stores.

    Example 1:

      # You can transpose a PropertyList file into a Puppet resource.

      `sudo puppet resource propertylist /Library/Preferences/com.apple.loginwindow.plist `

      propertylist { '/Library/Preferences/com.apple.loginwindow.plist':
        ensure  => 'present',
        content => {'MCXLaunchAfterUserLogin' => 'true',
                    'OptimizerLastRunForBuild' => '27396096',
                    'OptimizerLastRunForSystem' => '168362496',
                    'lastUser' => 'loggedIn',
                    'lastUserName' => 'foo'},
        format  => 'binary',
        group   => 'wheel',
        mode    => '0644',
        owner   => 'root',
      }


    Example 2:

      # Plist can be managed in whole or part by changing the :method param.
      # See :method documentation for gory details.

      $content = { LoginwindowText => 'A message to you, Rudy.' }

      propertylist { '/Library/Preferences/com.apple.loginwindow.plist':
        ensure  => present,
        method  => insert,
        content => $content,
      }

    Example 3:

      # Use the :defaults provider

      # Avoid problems with cfprefsd and preference domain sychronization by
      # setting the provider parameter to :defaults.

      # The defaults provider will not write directly to disk. Instead, it
      # uses the /usr/bin/defaults utility to sync the data so that the changes
      # are picked up by cfprefsd.

      # NOTE: The content property MUST be a Hash (Dictionary) because that
      # is what OS X defaults demands. If you attempt to use another primitive,
      # Puppet will raise an exception.

      $content = { LoginwindowText => 'A message to you, Rudy.' }

      propertylist { '/Library/Preferences/com.apple.loginwindow.plist':
        ensure   => present,
        method   => insert,
        content  => $content,
        provider => defaults,
      }
  }

  ensurable

  newparam(:path) do
    desc %q{The path to the file to manage. Must be fully qualified.}
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
    desc %q{The user to whom the file should belong. Argument should be a user
      name. Default is root.

      NOTE: The user name is NOT pre-validated.
    }
    defaultto 'root'
  end

  newproperty(:group) do
    desc %q{Which group that should own the file. Argument should be a group
      name. Default is wheel.

      NOTE: The group name is NOT pre-validated.
    }
    defaultto 'wheel'
  end

  newproperty(:mode) do
    desc %q{The desired permissions for the file using standard four-digit
      octal notation.
    }

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
    desc %q{The file's content, whole or in part as a Puppet data type.

      Plist content can be managed in whole or in part. Default mode is
      wholesale management -- see the :method documentation for exhaustive
      details.

      Usually, the most convenient of handling this is property is to jam
      the desired state into a Puppet variable and use that in the resource
      declaration. It's tidy.

      Example:

        $content = { LoginwindowText => 'A message to you, Rudy.' }

        propertylist { '/Library/Preferences/com.apple.loginwindow.plist':
          ensure  => present,
          method  => insert,
          content => $content,
        }
    }

    def insync?(is)
      is = [is].flatten

      # CFPreferences must use Dictionary/Hash type
      if resource[:provider] == :defaults
        unless should.first.respond_to?(:keys)
          raise Puppet::Error,
            "Content type must be Hash when using the :defaults provider!"
        end
      end

      return is.eql? should if resource[:method] == :replace

      result = should.zip(is).collect do |s,i|
        if s.nil? or i.nil?
          false
        else
          case s
          when Hash
            (i.merge(s)).eql? i
          when Array
            (i | s).eql? i
          when String, Fixnum, Float, TrueClass, FalseClass
            i.eql? s
          else
            fail Puppet::Error, "No equality test for '#{s.class}: (#{s})'"
          end
        end
      end
      result.all?
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
    desc %q{The PropertyList format the file should use, binary (default) or
      xml.

      CAUTION: Setting this parameter can cause undue resource modification
      during a Puppet run. Puppet will enforce the file format. If your
      selected format differs from what OS X expects it to be, you could get
      annoying conversion cycles.

    }
    newvalues(:xml, :binary)
    defaultto :binary
  end

  newparam(:method) do
    desc %q{Whether to overwrite the propertylist, or insert the specified data.

      This behaviour demands a detailed explanation, because it's not as simple
      as it sounds. First, a little about PropertyLists in general...

      As most OS X administrators are aware, PropertyLists usually take the
      form of a Dictionary, but they can actually be used to archive ANY of the
      primitive data types supported by ObjC: NSDictionary, NSArray, NSData,
      NSDate, NSString, etc.

      However, the thing that all PropertyLists have in common is that they may
      only ever contain a single root object.

      What does this mean? It means that if your Plist is storing an Integer,
      _that_ is the only value it can hold.

      Example:

        <plist version="1.0">
          <integer>1</integer>
        </plist>

      That is a valid PropertyList containing a single value.

      "But wait!" you say, "I know that I can have mutiple values in a
      PropertyList, just look at any of the files stored in
      /Library/Preferences."

      This is true, you can store as many values as you wish a in PropertyList,
      but just like plain old XML, you can only ever have ONE ROOT ELEMENT.

      This means that in order to store multiple values in a PropertyList, you
      will need to use a compound data type such as a <\dict> or an <\array>
      as the ROOT element.

      Example (dictionary):

        <plist version="1.0">
          <dict>
            <key>foo</key>
            <integer>99</integer>
            <key>bar</key>
            <integer>42</integer>
            <key>baz</key>
            <string>This is a string.</string>
          </dict>
        </plist>

      Example (array):

        <plist version="1.0">
          <array>
            <string>A string.</string>
            <string>Another string.</string>
            <integer>42</integer>
          </array>
        </plist>

      These complex data types allow you store multiple values as a single
      root object. In addition, you can also modify the elements in an Array or
      Dictionary without disturbing the remaining data.

      This is where the :method parameter for this Puppet Type comes into play.

      We use it to control two modes of operation for the creation and
      management of the PropertyList on disk:

      1. Replace (:replace)

      This is the default mode. In this mode, the data you specify in Puppet or
      another data source like Hiera, will be the only data in the Plist. It
      is absolute. If the Plist you are managing deviates in ANY way from the
      content specified in your Puppet resource, it will be overwritten.

      For example, let's say you are managing a Plist in /Library/Preferences
      (this is _not_ a good idea, see :providers documentation) named...

      com.apple.loginwindow.plist

      By managing this file in :replace mode, you are committed to managing the
      file in totality -- every key, every value. But, as we know, this file
      gets modified any time somebody logs in or out of the computer.

      This means that on any given Puppet run, this file is extremely likely to
      be reverted to the originally desired state.

      This is a good thing, if that's what you want, but chances are this
      behaviour is less than optimal (noisy and unnecessary).

      Maybe you only wish to manage particular keys/values inside the file???

      2. Insert (:insert)

      This is an optional mode and it must be expressly set in your resource
      declaration. Examine this Puppet code...

        # A Puppet Hash ("dictionary") containing a single key/value combo. In
        # this case, we want to control the value LoginwindowText and present
        # our users with a "special" message.
        $content = { LoginwindowText => 'A message to you, Rudy.' }

        # Here is our resource declaration, but notice that we have set the
        # :method parameter to :insert
        propertylist { '/Library/Preferences/com.apple.loginwindow.plist':
          ensure  => present,
          group   => 'staff',
          mode    => '0644',
          owner   => 'root',
          content => $content,
          method  => insert,
        }

      So, what does this accomplish?

      What we are in fact saying to Puppet is the following...

        "I want to make sure this file exists. If not, create it."
        "I want to make sure this file's owner, group and mode are set
        accordingly."
        "I want to make sure the content of this file is a dictionary that
         contains the key 'LoginwindowText' and that key has a value of...
         'A message to you, Rudy.'
         You can ignore the other portions of the file's content. Thanks."

      This is what :insert mode does. It inserts the content you define into
      the file leaving the other stuff unmolested.

      Of course, if you try to insert data and there is a mismatch between the
      root objects in the PropertyList, you will get an error. For example,
      let's say we tried the following...

        # A simple Puppet Array variable, full of Integers
        $content = [1, 2, 3, 4, 5]

        # Some non-essential params removed
        propertylist { '/Library/Preferences/com.apple.loginwindow.plist':
          content => $content,
          method  => insert,
        }

      Here, we know com.apple.loginwindow.plist exists -- it always does.
      We also know that it's root object is a <\dict> -- it always is.

      But we were careless and we have attempted to use an Array as the root
      object while in :insert mode. In :replace mode, this would work the
      contents of the file would be overwritten with the $content array
      destroying the integrity of the file and possibly destabilizing the
      system -- don't do this -- but it _would_ work.

      However, in :insert mode you would receive an error that looks like
      this...

        'Could not evaluate: no implicit conversion of Array into Hash'

      This means you tried to replace the root object (currently a <\dict>)
      with an <\array> and Puppet has stopped you. Thanks, Puppet.

      Now, this whole scenario is a bit far-fetched, but it does illustrate
      the need to be DECISIVELY AWARE of HOW and WHAT you are
      choosing to manage, so you can avoid errors (and poetntial disasters).

      There is one more intersting characteristic of managing PropertyLists
      that has to do with Arrays as root objects...

      Arrays are ordered lists.

        $content = [1, 2, 3, 4, 5]

      This array has 5 elements. Let's create a PropertyList with it.

        propertylist { '/Users/Shared/foo.plist':
          format  => xml,
          content => $content,
          method  => insert,
        }

      Ok, great. We should now have a PropertyList that looks like this...

        <plist version="1.0">
          <array>
            <integer>1</integer>
            <integer>2</integer>
            <integer>3</integer>
            <integer>4</integer>
            <integer>5</integer>
          </array>
        </plist>

      So, what if we want to delete a value? Let's say we want to remove the
      fourth element of the array...

        $content = [1, 2, 3, 5]

        propertylist { '/Users/Shared/foo.plist':
          format  => xml,
          content => $content,
          method  => insert,
        }

      Now let's inspect our PropertyList...

        <plist version="1.0">
          <array>
            <integer>1</integer>
            <integer>2</integer>
            <integer>3</integer>
            <integer>5</integer>
            <integer>5</integer>
          </array>
        </plist>

      What happened??? Do you see the problem?

      Let's break it down...

      1. We are in insert mode, this implies we are going to ignore extraneous
      data and only manage what we are told to.

      2. Arrays are ordered lists. The only thing unique about array elements
      is its index (ie. what order it is in).

      3. We shortened the $content array from 5 elements to 4 elements! When
      we did this, we essentially redefined what the first four elements of the
      root object Array should be and since we were in :insert mode, the
      leftover element got ignored -- even though it was a duplicate value!!!

      Weird as it may seem, this is how :insert mode operates on Arrays as root
      objects. You need to be aware of this behaviour.

      Luckily, most PropertyLists DO NOT use Arrays as root objects. Off the
      top my head I can only think of one that does and it is not something
      that can be managed as a file-on-disk. FTR: the output of
      /usr/sbin/system_profiler produces an XML PropertyList that uses an
      Array as the root object.

    }
    newvalues(:replace, :insert)
    defaultto :replace
  end

end
