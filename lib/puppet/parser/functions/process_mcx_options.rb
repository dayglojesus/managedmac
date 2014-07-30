require 'time'

module Puppet::Parser::Functions
  newfunction(:process_mcx_options, :type => :rvalue, :doc => <<-EOS
Returns a com.apple.ManagedClient.preferences Payload.
    EOS
  ) do |args|

    if args.size != 5
      e = "process_mcx_options(): Wrong number of args: #{args.size} for 5"
      raise(Puppet::ParseError, e)
    end

    bluetooth,
    wifi,
    loginitems,
    suppress_icloud_setup,
    hidden_preference_panes = *args

    settings = {
      'com.apple.MCXBluetooth'      => {},
      'com.apple.MCXAirPort'        => {},
      'loginwindow'                 => {},
      'com.apple.SetupAssistant'    => {},
      'com.apple.systempreferences' => {},
    }

    case bluetooth
    when TrueClass, FalseClass
      settings['com.apple.MCXBluetooth'] = {
        'Forced' => [
          { 'mcx_preference_settings' => { 'DisableBluetooth' => true } }
        ]
      }
    else
      settings.delete('com.apple.MCXBluetooth')
    end

    case wifi
    when TrueClass, FalseClass
      settings['com.apple.MCXAirPort'] = {
        'Forced' => [
          { 'mcx_preference_settings' => { 'DisableAirPort' => true } }
        ]
      }
    else
      settings.delete('com.apple.MCXAirPort')
    end

    if loginitems.empty?
      settings.delete('loginwindow')
    else
      values = loginitems.collect do |path|
        Hash['Hide', false, 'Path', path]
      end
      settings['loginwindow'] = {
        'Forced' => [
          { 'mcx_preference_settings' => {
              'AutoLaunchedApplicationDictionary-managed' => values,
              'DisableLoginItemsSuppression'              => false,
              'LoginUserMayAddItems'                      => true,
            }
          },
        ]
      }
    end

    case suppress_icloud_setup
    when true
      settings['com.apple.SetupAssistant'] = {
        'Set-Once' => [
          { 'mcx_data_timestamp'      => Time.parse('2013-10-29T17:20:10'),
            'mcx_preference_settings' => {
              'DidSeeCloudSetup' => true,
              'LastSeenCloudProductVersion' =>
                lookupvar('macosx_productversion_major'),
            },
          },
        ]
      }
    else
      settings.delete('com.apple.SetupAssistant')
    end

    if hidden_preference_panes.empty?
      settings.delete('com.apple.systempreferences')
    else
      settings['com.apple.systempreferences'] = {
        'Forced' => [
          { 'mcx_preference_settings' => {
              'HiddenPreferencePanes' => hidden_preference_panes,
            }
          },
        ]
      }
    end

    return [] if settings.empty?

    # Return a PayloadContent Array
    hash = { 'PayloadType'    => 'com.apple.ManagedClient.preferences',
             'PayloadContent' => settings,
    }

    [hash]
  end
end
