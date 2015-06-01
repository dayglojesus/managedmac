# == Class: managedmac::portablehomes
#
# Leverages the Mobileconfig type to deploy a Mobility profile capable of
# supporting portable home directories.
#
# === Parameters
#
# This class takes many many parameters. The horror...
#
# [*enable*]
#   Enable Portable Home Directory Synchromization
#   Accepts a String value of true, false or a Mac OS X major product revision
#   number, like '10.9' or '10.10' which will scope the policy
#   application to the version specified.
#   Default: false
#   Type: String
#
# [*menuExtra*]
#   Enable the PHD Menu Extra
#   Default: on
#   Type: String
#
# [*isNewMobileAccount*]
#   New Mobile Account
#   Set to True if this is a new mobile account that should be synced
#   initially.
#   Default: false
#   Type: Boolean
#
# [*periodicSyncOn*]
#   Background Sync On
#   Set to True to sync in the background.
#   Default: true
#   Type: Boolean
#
# [*syncPeriodSeconds*]
#   Background Sync Interval
#   Background sync interval in seconds.
#   Default: 1200
#   Type: Integer
#
# [*syncOnChange*]
#   Sync On File Change
#   Set to True to sync when a file changes.
#   Default: false
#   Type: Boolean
#
# [*replaceUserSyncList*]
#   Override Home Sync Prefs
#   Set to True to replace the user's Home Sync preferences with managed
#   preferences. Set to False to combine with managed preferences.
#   Default: true
#   Type: Boolean
#
# [*replaceUserPrefSyncList*]
#   Override Preference Sync Prefs
#   Set to True to replace the user's Preference sync preferences with
#   managed preferences. Set to False to combine them with managed preferences.
#   Default: false
#   Type: Boolean
#
# [*syncedFolders*]
#   Managed Home Sync Items
#   Include managed items to sync in the background while the user is
#   logged in.
#   Default: ['~']
#   Tyoe: String
#
# [*syncedPrefFolders*]
#   Managed Preference Sync Items
#   Include managed items to sync when a user logs in or logs out.
#   Default: ['~/Library', '~/Documents/Microsoft User Data']
#   Type: Array
#
# [*excludedItems*]
#   Managed Home Sync Exclusions
#   List managed items to exclude from Home Sync.
#   Default: (see class params)
#   Type: Array
#
# [*excludedPrefItems*]
#   Managed Preference Sync Exclusions
#   List managed items to exclude from Preference Sync.
#   Default: (see class params)
#   Type: Array
#
# [*loginPrefSyncConflictResolution*]
#   Login Preference Sync Conflict Resolution
#   This setting affects syncing ~/Library at login. Set to
#   "mobileHomeWins" to merge homes and have the local (mobile) home win
#   conflicts "mobileHomeCopy" to copy the local home to the network home
#   "automatic" or "networkHomeWins" to merge homes and have the network home
#   win conflicts or "networkHomeCopy" to copy the network home to the local
#   home.
#   Default: automatic
#   Type: String
#
# [*loginNonprefSyncConflictResolution*]
#   Login Non-preference Sync Conflict Resolution
#   This setting affects syncing everything besides ~/Library at login. Set
#   to "showConflictDialogs" to show dialogs when conflicts occur
#   "mobileHomeWins" to merge homes and have the local (mobile) home win
#   conflicts "mobileHomeCopy" to copy the local home to the network home
#   "automatic" or "networkHomeWins" to merge homes and have the network home
#   win conflicts or "networkHomeCopy" to copy the network home to the local
#   home.
#   Default: automatic
#   Type: String
#
# [*logoutPrefSyncConflictResolution*]
#   Logout Preference Sync Conflict Resolution
#   This setting affects syncing ~/Library at logout. Set to
#   "mobileHomeWins" to merge homes and have the local (mobile) home win
#   conflicts "mobileHomeCopy" to copy the local home to the network home
#   "networkHomeWins" to merge homes and have the network home win conflicts or
#   "networkHomeCopy" to copy the network home to the local home.
#   Default: automatic
#   Type: String
#
# [*logoutNonprefSyncConflictResolution*]
#   Logout Non-preference Sync Conflict Resolution
#   This setting affects syncing everything besides ~/Library at logout.
#   Set to "showConflictDialogs" to show dialogs when conflicts occur
#   "automatic" or "mobileHomeWins" to merge homes and have the local (mobile)
#   home win conflicts "mobileHomeCopy" to copy the local home to the network
#   home "networkHomeWins" to merge homes and have the network home win
#   conflicts or "networkHomeCopy" to copy the network home to the local home.
#   Default: automatic
#   Type: String
#
# [*backgroundConflictResolution*]
#   Home Sync Conflict Resolution
#   This setting affects syncing everything besides ~/Library in the
#   background. Set to "automatic" or "showConflictDialogs" to show dialogs
#   when conflicts occur "mobileHomeWins" to merge homes and have the local
#   (mobile) home win conflicts "mobileHomeCopy" to copy the local home to the
#   network home "networkHomeWins" to merge homes and have the network home win
#   conflicts or "networkHomeCopy" to copy the network home to the local home.
#   Default: automatic
#   Type: String
#
# [*syncPreferencesAtLogin*]
#   Sync Preference Set During Login
#   This setting allows you to sync Preference Sync items during login. Set
#   to "automatic" or "sync" to sync Preference Sync items at login\, or
#   "dontSync" to not sync Preference Sync items at login.
#   Default: automatic
#   Type: String
#
# [*syncPreferencesAtLogout*]
#   Sync Preference Set During Logout
#   This setting allows you to sync Preference Sync items during logout.
#   Set to "automatic" or "sync" to sync Preference Sync items at logout\, or
#   "dontSync" to not sync Preference Sync items at logout.
#   Default: automatic
#   Type: String
#
# [*syncPreferencesAtSyncNow*]
#   Sync Preferences During Manual Sync
#   This setting allows you to sync preferences during a manual sync. Set
#   to "automatic" or "sync" to sync preferences during a manual sync\, or
#   "dontSync" to not sync preferences during a manual sync.
#   Default: automatic
#   Type: String
#
# [*syncPreferencesInBackground*]
#   Sync Preferences in the Background
#   This setting allows you to sync preferences during a background sync.
#   Set to "automatic" or "sync" to sync preferences in the background\, or
#   "dontSync" to not synchronize preferences in the background.
#   Default: automatic
#   Type: String
#
# [*syncBackgroundSetAtLogin*]
#   Sync Home Set During Login
#   This setting allows you to sync Home Sync items during login. Set to
#   "automatic" or "sync" to sync Home Sync items at login\, or "dontSync" to
#   not sync Home Sync items at login.
#   Default: automatic
#   Type: String
#
# [*syncBackgroundSetAtLogout*]
#   Sync Home Set During Logout
#   This setting allows you to sync Home Sync items during logout. Set to
#   "automatic" or "sync" to sync Home Sync items at logout\, or "dontSync" to
#   not sync Home Sync items at logout.
#   Default: automatic
#   Type: String
#
# [*syncBackgroundSetAtSyncNow*]
#   Sync Preferences During Manual Sync
#   This setting allows you to sync Home Sync items during a manual sync.
#   Set to "automatic" or "sync" to sync Home Sync items during a manual sync\,
#   or "dontSync" to not sync Home Sync items during a manual sync.
#   Default: automatic
#   Type: String
#
# [*syncBackgroundSetInBackground*]
#   Sync Preferences in the Background
#   This setting allows you to sync Home Sync items during a background
#   sync. Set to "automatic" or "sync" to sync Home Sync items in the
#   background\, or "dontSync" to not synchronize Home Sync items in the
#   background.
#   Default: automatic
#   Type: String
#
# [*loginPrefSuppressErrors*]
#   Suppress Login Preference Sync Errors
#   Set to True to suppress error dialogs during login sync of ~/Library.
#   Default: false
#   Type: Boolean
#
# [*loginNonprefSuppressErrors*]
#   Suppress Login Non-preference Sync Errors
#   Set to True to suppress error dialogs during login sync of everything
#   besides ~/Library.
#   Default: false
#   Type: Boolean
#
# [*logoutPrefSuppressErrors*]
#   Suppress Logout Preference Sync Errors
#   Set to True to suppress error dialogs during logout sync of ~/Library.
#   Default: false
#   Type: Boolean
#
# [*logoutNonprefSuppressErrors*]
#   Suppress Logout Non-preference Sync Errors
#   Set to True to suppress error dialogs during logout sync of everything
#   besides ~/Library.
#   Default: false
#   Type: Boolean
#
# [*backgroundSuppressErrors*]
#   Suppress Home Sync Errors
#   Set to True to suppress error dialogs during home sync.
#   Default: false
#   Type: Boolean
#
# [*firstSyncSuppressErrors*]
#   Suppress Initial Sync Errors
#   Set to True to suppress error dialogs during initial sync.
#   Default: false
#   Type: Boolean
#
# [*syncNowAllPrefsSuppressErrors*]
#   Suppress Sync Now Sync Errors
#   Set to True to suppress error dialogs during Sync Now.
#   Default: false
#   Type: Boolean
#
# [*loginPrefSuppressConflicts*]
#   Suppress Login Preference Sync Conflicts
#   Set to True to suppress conflict dialogs during login sync of ~/Library.
#   Default: false
#   Type: Boolean
#
# [*loginNonprefSuppressConflicts*]
#   Suppress Login Non-preference Sync Conflicts
#   Set to True to suppress conflict dialogs during login sync of
#   everything besides ~/Library.
#   Default: false
#   Type: Boolean
#
# [*logoutPrefSuppressConflicts*]
#   Suppress Logout Preference Sync Conflicts
#   Set to True to suppress conflict dialogs during logout sync of
#   ~/Library.
#   Default: false
#   Type: Boolean
#
# [*logoutNonprefSuppressConflicts*]
#   Suppress Logout Non-preference Sync Conflicts
#   Set to True to suppress conflict dialogs during logout sync of
#   everything besides ~/Library.
#   Default: false
#   Type: Boolean
#
# [*backgroundSuppressConflicts*]
#   Suppress Home Sync Conflicts
#   Set to True to suppress conflict dialogs during home sync.
#   Default: false
#   Type: Boolean
#
# [*firstSyncSuppressConflicts*]
#   Suppress Initial Sync Conflicts
#   Set to True to suppress conflict dialogs during initial sync.
#   Default: false
#   Type: Boolean
#
# [*syncNowAllPrefsSuppressConflicts*]
#   Suppress Sync Now Conflicts
#   Set to True to suppress conflict dialogs during Sync Now.
#   Default: false
#   Type: Boolean
#
# [*disableFirstSyncCancel*]
#   Disable First Time Sync Cancel
#   Set to True to disable canceling a first time sync.
#   Default: false
#   Type: Boolean
#
# [*disableLoginSyncCancel*]
#   Disable Login Sync Cancel
#   Set to True to disable canceling a login sync.
#   Default: false
#   Type: Boolean
#
# [*disableLogoutSyncCancel*]
#   Disable Logout Sync Cancel
#   Set to True to disable canceling a logout sync.
#   Default: false
#   Type: Boolean
#
# [*loginSyncDialogTimeoutSeconds*]
#   Login Dialog Timeout
#   Maximum seconds to display login error or conflict dialogs. Set to 0
#   for no time limit.
#   Default: 0
#   Type: Integer
#
# [*logoutSyncDialogTimeoutSeconds*]
#   Logout Dialog Timeout
#   Maximum seconds to display logout error or conflict dialogs. Set to 0
#   for no time limit.
#   Default: 0
#   Type: Integer
#
# [*progressDelaySeconds*]
#   Time To Delay Progress Dialog
#   The time in whole seconds that the progress dialog delays for various
#   reasons.  The default is set to 0.5 seconds if you do not set this key.
#   Default: 2
#   Type: Integer
#
# [*alertOnFailedMounts*]
#   Alert On Failed Mounts
#   Set to True if you want an alert if the network home mount fails.
#   Default: false
#   Type: Boolean
#
# === Variables
#
# Not applicable
#
# === Functions
#
# This class uses two custom functions to reformat file lists:
# - portablehomes_excluded_items
# - portablehomes_synced_folders
#
# === Examples
#
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
#  # Example: defaults.yaml
#  ---
# managedmac::portablehomes::enable: true
# managedmac::portablehomes::menuextra: on
# managedmac::portablehomes::backgroundConflictResolution: mobileHomeWins
# managedmac::portablehomes::backgroundSuppressErrors: true
# managedmac::portablehomes::periodicSyncOn: true
# managedmac::portablehomes::syncPeriodSeconds: 720
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::portablehomes
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::portablehomes':
#    enable => true,
#    menuextra => true,
#    backgroundConflictResolution => 'mobileHomeWins',
#  }
#
# === Authors
#
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2015 Simon Fraser University, unless otherwise noted.
#
class managedmac::portablehomes (

  $enable                               = false,
  $syncedFolders                        = ['~'],
  $syncedPrefFolders                    = [
    '~/Library',
    '~/Documents/Microsoft User Data'
  ],
  $excludedItems                        = {
    fullPath => [ '~/.SymAVQSFile',
                  '~/Documents/Microsoft User Data/Entourage Temp',
                  '~/Library/Application Support/SyncServices',
                  '~/Library/Application Support/MobileSync',
                  '~/Library/Caches',
                  '~/Library/Calendars/Calendar Cache',
                  '~/Library/Logs',
                  '~/Library/Mail/AvailableFeeds',
                  '~/Library/Mail/Envelope Index',
                  '~/Library/Preferences/Macromedia/Flash Player',
                  '~/Library/Printers',
                  '~/Library/PubSub/Database',
                  '~/Library/PubSub/Downloads',
                  '~/Library/PubSub/Feeds',
                  '~/Library/Safari/Icons.db',
                  '~/Library/Safari/HistoryIndex.sk',
                  '~/Library/iTunes/iPhone Software Updates',
    ],
    startsWith => [ 'IMAP-',
                    'Exchange-',
                    'EWS-',
                    'Mac-'
    ],
  },
  $excludedPrefItems                    = {
    fullPath => [ '~/.SymAVQSFile',
                  '~/Documents/Microsoft User Data',
                  '~/Library',
                  '~/NAVMac800QSFile'
    ],
  },
  $menuExtra                            = true,
  $warnOnCreateAllowNever               = false,
  $createAtLogin                        = true,
  $createPHDAtLogin                     = false,
  $warnOnCreate                         = false,
  $isNewMobileAccount                   = false,
  $periodicSyncOn                       = true,
  $syncPeriodSeconds                    = 1200,
  $syncOnChange                         = false,
  $replaceUserSyncList                  = true,
  $replaceUserPrefSyncList              = false,
  $loginPrefSyncConflictResolution      = 'automatic',
  $loginNonprefSyncConflictResolution   = 'automatic',
  $logoutPrefSyncConflictResolution     = 'automatic',
  $logoutNonprefSyncConflictResolution  = 'automatic',
  $backgroundConflictResolution         = 'automatic',
  $syncPreferencesAtLogin               = 'automatic',
  $syncPreferencesAtLogout              = 'automatic',
  $syncPreferencesAtSyncNow             = 'automatic',
  $syncPreferencesInBackground          = 'automatic',
  $syncBackgroundSetAtLogin             = 'automatic',
  $syncBackgroundSetAtLogout            = 'automatic',
  $syncBackgroundSetAtSyncNow           = 'automatic',
  $syncBackgroundSetInBackground        = 'automatic',
  $loginPrefSuppressErrors              = false,
  $loginNonprefSuppressErrors           = false,
  $logoutPrefSuppressErrors             = false,
  $logoutNonprefSuppressErrors          = false,
  $backgroundSuppressErrors             = false,
  $firstSyncSuppressErrors              = false,
  $syncNowAllPrefsSuppressErrors        = false,
  $loginPrefSuppressConflicts           = false,
  $loginNonprefSuppressConflicts        = false,
  $logoutPrefSuppressConflicts          = false,
  $logoutNonprefSuppressConflicts       = false,
  $backgroundSuppressConflicts          = false,
  $firstSyncSuppressConflicts           = false,
  $syncNowAllPrefsSuppressConflicts     = false,
  $disableFirstSyncCancel               = false,
  $disableLoginSyncCancel               = false,
  $disableLogoutSyncCancel              = false,
  $loginSyncDialogTimeoutSeconds        = 0,
  $logoutSyncDialogTimeoutSeconds       = 0,
  $progressDelaySeconds                 = 2,
  $alertOnFailedMounts                  = false,

) {

  # Accepted values for the $enable parameter
  $enable_re_values = ['^true$', '^false$', '^10\.\d{1,2}\.?\d{0,2}$',]

  # Validate $enable as a string
  validate_re ("${enable}", $enable_re_values)

  # Evaluate $enable as an OS X major version string and deduce a state
  $os_conditional = versioncmp("${enable}", $::macosx_productversion_major) ? {
    0       => present,
    default => absent,
  }

  # Set ensure according to defined logic
  $ensure = $enable ? {
    true                      => present,
    /^10\.\d{1,2}\.?\d{0,2}$/ => $os_conditional,
    default                   => absent,
  }

  $compiled_options = []

  if $ensure == present {

    #
    # VALIDATE INTEGERS
    #
    unless is_integer($syncPeriodSeconds) {
      fail("syncPeriodSeconds not an Integer: ${syncPeriodSeconds}")
    }

    unless is_integer($loginSyncDialogTimeoutSeconds) {
      fail("loginSyncDialogTimeoutSeconds not an Integer: \
${loginSyncDialogTimeoutSeconds}")
    }

    unless is_integer($logoutSyncDialogTimeoutSeconds) {
      fail("logoutSyncDialogTimeoutSeconds not an Integer: \
${logoutSyncDialogTimeoutSeconds}")
    }

    unless is_integer($progressDelaySeconds) {
      fail("progressDelaySeconds not an Integer: ${progressDelaySeconds}")
    }

    #
    # VALIDATE CONFLICT RESOLUTION
    #
    $allowed_conflict_res = ['automatic', 'showConflictDialogs',
      'mobileHomeWins', 'mobileHomeCopy', 'networkHomeWins', 'networkHomeCopy'
    ]

    unless member($allowed_conflict_res, $loginPrefSyncConflictResolution) {
      fail("Parameter Error: invalid value for \
:loginPrefSyncConflictResolution, ${loginPrefSyncConflictResolution}")
    }

    unless member($allowed_conflict_res, $loginNonprefSyncConflictResolution) {
      fail("Parameter Error: invalid value for \
:loginNonprefSyncConflictResolution, ${loginNonprefSyncConflictResolution}")
    }

    unless member($allowed_conflict_res, $logoutPrefSyncConflictResolution) {
      fail("Parameter Error: invalid value for \
:logoutPrefSyncConflictResolution, ${logoutPrefSyncConflictResolution}")
    }

    unless member($allowed_conflict_res, $logoutNonprefSyncConflictResolution) {
      fail("Parameter Error: invalid value for \
:logoutNonprefSyncConflictResolution, ${logoutNonprefSyncConflictResolution}")
    }

    unless member($allowed_conflict_res, $backgroundConflictResolution) {
      fail("Parameter Error: invalid value for \
:backgroundConflictResolution, ${backgroundConflictResolution}")
    }

    #
    # VALIDATE SYNC RULES
    #
    $allowed_sync_rules = ['automatic', 'sync', 'dontSync']

    unless member($allowed_sync_rules, $syncPreferencesAtLogin) {
      fail("Parameter Error: invalid value for :syncPreferencesAtLogin, \
${syncPreferencesAtLogin}")
    }

    unless member($allowed_sync_rules, $syncPreferencesAtLogout) {
      fail("Parameter Error: invalid value for :syncPreferencesAtLogout, \
${syncPreferencesAtLogout}")
    }

    unless member($allowed_sync_rules, $syncPreferencesAtSyncNow) {
      fail("Parameter Error: invalid value for :syncPreferencesAtSyncNow, \
${syncPreferencesAtSyncNow}")
    }

    unless member($allowed_sync_rules, $syncPreferencesInBackground) {
      fail("Parameter Error: invalid value for :syncPreferencesInBackground, \
${syncPreferencesInBackground}")
    }

    unless member($allowed_sync_rules, $syncBackgroundSetAtLogin) {
      fail("Parameter Error: invalid value for :syncBackgroundSetAtLogin, \
${syncBackgroundSetAtLogin}")
    }

    unless member($allowed_sync_rules, $syncBackgroundSetAtLogout) {
      fail("Parameter Error: invalid value for :syncBackgroundSetAtLogout, \
${syncBackgroundSetAtLogout}")
    }

    unless member($allowed_sync_rules, $syncBackgroundSetAtSyncNow) {
      fail("Parameter Error: invalid value for :syncBackgroundSetAtSyncNow, \
${syncBackgroundSetAtSyncNow}")
    }

    unless member($allowed_sync_rules, $syncBackgroundSetInBackground) {
      fail("Parameter Error: invalid value for :syncBackgroundSetInBackground, \
${syncBackgroundSetInBackground}")
    }

    #
    # VALIDATE BOOL OPTIONS
    #
    validate_bool ($menuExtra)
    validate_bool ($warnOnCreateAllowNever)
    validate_bool ($createAtLogin)
    validate_bool ($createPHDAtLogin)
    validate_bool ($warnOnCreate)
    validate_bool ($isNewMobileAccount)
    validate_bool ($periodicSyncOn)
    validate_bool ($syncOnChange)
    validate_bool ($replaceUserSyncList)
    validate_bool ($replaceUserPrefSyncList)
    validate_bool ($loginPrefSuppressErrors)
    validate_bool ($loginNonprefSuppressErrors)
    validate_bool ($logoutPrefSuppressErrors)
    validate_bool ($logoutNonprefSuppressErrors)
    validate_bool ($backgroundSuppressErrors)
    validate_bool ($firstSyncSuppressErrors)
    validate_bool ($syncNowAllPrefsSuppressErrors)
    validate_bool ($loginPrefSuppressConflicts)
    validate_bool ($loginNonprefSuppressConflicts)
    validate_bool ($logoutPrefSuppressConflicts)
    validate_bool ($logoutNonprefSuppressConflicts)
    validate_bool ($backgroundSuppressConflicts)
    validate_bool ($firstSyncSuppressConflicts)
    validate_bool ($syncNowAllPrefsSuppressConflicts)
    validate_bool ($disableFirstSyncCancel)
    validate_bool ($disableLoginSyncCancel)
    validate_bool ($disableLogoutSyncCancel)
    validate_bool ($alertOnFailedMounts)

  } else {
    unless $ensure == absent {
      fail("Parameter Error: invalid value for :enable, ${enable}")
    }
  }

  $menu_payload = { 'PayloadType' => 'com.apple.mcxMenuExtras',
    'HomeSync.menu' => $menuExtra,
  }

  $mcx_payload  = { 'PayloadType' => 'com.apple.MCX',
      'cachedaccounts.WarnOnCreate.allowNever'              =>
        $warnOnCreateAllowNever,
      'com.apple.cachedaccounts.CreateAtLogin'              => $createAtLogin,
      'com.apple.cachedaccounts.CreatePHDAtLogin'           =>
        $createPHDAtLogin,
      'com.apple.cachedaccounts.WarnOnCreate'               => $warnOnCreate,
      'cachedaccounts.create.encrypt'                       => false,
      'cachedaccounts.create.encrypt.requireMasterPassword' => false,
      'cachedaccounts.create.location'                      => 'startup',
      'cachedaccounts.create.maxSize'                       => '',
      'cachedaccounts.create.maxSize.fixedSize'             => 262144000,
      'cachedaccounts.create.maxSize.percentOfNetworkHome'  => 100,
      'cachedaccounts.expiry.cond.successfulSync'           => true,
      'cachedaccounts.expiry.delete.disusedSeconds'         => -1,
  }

  $homesync_payload = { 'PayloadType' => 'com.apple.homeSync',
    'syncedFolders-managed'                =>
      portablehomes_synced_folders($syncedFolders),
    'syncedPrefFolders-managed'            =>
      portablehomes_synced_folders($syncedPrefFolders),
    'excludedItems-managed'                =>
      portablehomes_excluded_items($excludedItems),
    'excludedPrefItems-managed'            =>
      portablehomes_excluded_items($excludedPrefItems),
    'warnOnCreateAllowNever'               => $warnOnCreateAllowNever,
    'createAtLogin'                        => $createAtLogin,
    'createPHDAtLogin'                     => $createPHDAtLogin,
    'warnOnCreate'                         => $warnOnCreate,
    'isNewMobileAccount'                   => $isNewMobileAccount,
    'periodicSyncOn'                       => $periodicSyncOn,
    'syncPeriodSeconds'                    => $syncPeriodSeconds,
    'syncOnChange'                         => $syncOnChange,
    'replaceUserSyncList'                  => $replaceUserSyncList,
    'replaceUserPrefSyncList'              => $replaceUserPrefSyncList,
    'loginPrefSyncConflictResolution'      => $loginPrefSyncConflictResolution,
    'loginNonprefSyncConflictResolution'   =>
      $loginNonprefSyncConflictResolution,
    'logoutPrefSyncConflictResolution'     =>
      $logoutPrefSyncConflictResolution,
    'logoutNonprefSyncConflictResolution'  =>
      $logoutNonprefSyncConflictResolution,
    'backgroundConflictResolution'         => $backgroundConflictResolution,
    'syncPreferencesAtLogin'               => $syncPreferencesAtLogin,
    'syncPreferencesAtLogout'              => $syncPreferencesAtLogout,
    'syncPreferencesAtSyncNow'             => $syncPreferencesAtSyncNow,
    'syncPreferencesInBackground'          => $syncBackgroundSetInBackground,
    'syncBackgroundSetAtLogin'             => $syncBackgroundSetAtLogin,
    'syncBackgroundSetAtLogout'            => $syncBackgroundSetAtLogout,
    'syncBackgroundSetAtSyncNow'           => $syncBackgroundSetAtSyncNow,
    'syncBackgroundSetInBackground'        => $syncBackgroundSetInBackground,
    'loginPrefSuppressErrors'              => $loginPrefSuppressErrors,
    'loginNonprefSuppressErrors'           => $loginNonprefSuppressErrors,
    'logoutPrefSuppressErrors'             => $logoutPrefSuppressErrors,
    'logoutNonprefSuppressErrors'          => $logoutNonprefSuppressErrors,
    'backgroundSuppressErrors'             => $backgroundSuppressErrors,
    'firstSyncSuppressErrors'              => $firstSyncSuppressErrors,
    'syncNowAllPrefsSuppressErrors'        => $syncNowAllPrefsSuppressErrors,
    'loginPrefSuppressConflicts'           => $loginPrefSuppressConflicts,
    'loginNonprefSuppressConflicts'        => $loginNonprefSuppressConflicts,
    'logoutPrefSuppressConflicts'          => $logoutPrefSuppressConflicts,
    'logoutNonprefSuppressConflicts'       => $logoutNonprefSuppressConflicts,
    'backgroundSuppressConflicts'          => $backgroundSuppressConflicts,
    'firstSyncSuppressConflicts'           => $firstSyncSuppressConflicts,
    'syncNowAllPrefsSuppressConflicts'     => $syncNowAllPrefsSuppressConflicts,
    'disableFirstSyncCancel'               => $disableFirstSyncCancel,
    'disableLoginSyncCancel'               => $disableLoginSyncCancel,
    'disableLogoutSyncCancel'              => $disableLogoutSyncCancel,
    'loginSyncDialogTimeoutSeconds'        => $loginSyncDialogTimeoutSeconds,
    'logoutSyncDialogTimeoutSeconds'       => $logoutSyncDialogTimeoutSeconds,
    'progressDelaySeconds'                 => $progressDelaySeconds,
    'alertOnFailedMounts'                  => $alertOnFailedMounts,
  }

  $organization = hiera('managedmac::organization', 'Simon Fraser University')

  mobileconfig { 'managedmac.portablehomes.alacarte':
    ensure       => $ensure,
    content      => [$menu_payload, $mcx_payload, $homesync_payload],
    displayname  => 'Managed Mac: Portable Home Directories',
    description  => 'Portable Home Directory configuration. \
Installed by Puppet.',
    organization => $organization,
  }

}