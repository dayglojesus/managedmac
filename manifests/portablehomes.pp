# Class: managedmac::portablehomes
#
#
class managedmac::portablehomes (

  $enable                               = false,
  $syncedFolders                        = ['~'],
  $syncedPrefFolders                    = ['~/Library', '~/Documents/Microsoft User Data'],
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

  validate_bool ($enable)

  $compiled_options = []

  if $enable == true {

    #
    # VALIDATE INTEGERS
    #
    unless is_integer($syncPeriodSeconds) {
      fail("syncPeriodSeconds not an Integer: ${syncPeriodSeconds}")
    }

    unless is_integer($loginSyncDialogTimeoutSeconds) {
      fail("loginSyncDialogTimeoutSeconds not an Integer: ${loginSyncDialogTimeoutSeconds}")
    }

    unless is_integer($logoutSyncDialogTimeoutSeconds) {
      fail("logoutSyncDialogTimeoutSeconds not an Integer: ${logoutSyncDialogTimeoutSeconds}")
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
      fail("Parameter Error: invalid value for :loginPrefSyncConflictResolution, ${loginPrefSyncConflictResolution}")
    }

    unless member($allowed_conflict_res, $loginNonprefSyncConflictResolution) {
      fail("Parameter Error: invalid value for :loginNonprefSyncConflictResolution, ${loginNonprefSyncConflictResolution}")
    }

    unless member($allowed_conflict_res, $logoutPrefSyncConflictResolution) {
      fail("Parameter Error: invalid value for :logoutPrefSyncConflictResolution, ${logoutPrefSyncConflictResolution}")
    }

    unless member($allowed_conflict_res, $logoutNonprefSyncConflictResolution) {
      fail("Parameter Error: invalid value for :logoutNonprefSyncConflictResolution, ${logoutNonprefSyncConflictResolution}")
    }

    unless member($allowed_conflict_res, $backgroundConflictResolution) {
      fail("Parameter Error: invalid value for :backgroundConflictResolution, ${backgroundConflictResolution}")
    }

    #
    # VALIDATE SYNC RULES
    #
    $allowed_sync_rules = ['automatic', 'sync', 'dontSync']

    unless member($allowed_sync_rules, $syncPreferencesAtLogin) {
      fail("Parameter Error: invalid value for :syncPreferencesAtLogin, ${syncPreferencesAtLogin}")
    }

    unless member($allowed_sync_rules, $syncPreferencesAtLogout) {
      fail("Parameter Error: invalid value for :syncPreferencesAtLogout, ${syncPreferencesAtLogout}")
    }

    unless member($allowed_sync_rules, $syncPreferencesAtSyncNow) {
      fail("Parameter Error: invalid value for :syncPreferencesAtSyncNow, ${syncPreferencesAtSyncNow}")
    }

    unless member($allowed_sync_rules, $syncPreferencesInBackground) {
      fail("Parameter Error: invalid value for :syncPreferencesInBackground, ${syncPreferencesInBackground}")
    }

    unless member($allowed_sync_rules, $syncBackgroundSetAtLogin) {
      fail("Parameter Error: invalid value for :syncBackgroundSetAtLogin, ${syncBackgroundSetAtLogin}")
    }

    unless member($allowed_sync_rules, $syncBackgroundSetAtLogout) {
      fail("Parameter Error: invalid value for :syncBackgroundSetAtLogout, ${syncBackgroundSetAtLogout}")
    }

    unless member($allowed_sync_rules, $syncBackgroundSetAtSyncNow) {
      fail("Parameter Error: invalid value for :syncBackgroundSetAtSyncNow, ${syncBackgroundSetAtSyncNow}")
    }

    unless member($allowed_sync_rules, $syncBackgroundSetInBackground) {
      fail("Parameter Error: invalid value for :syncBackgroundSetInBackground, ${syncBackgroundSetInBackground}")
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

    #
    # OKAY. NOW DO SOME WORK...
    #

  } else {
    unless $enable == false {
      fail("Parameter Error: invalid value for :enable, ${enable}")
    }
  }

  $menu_payload = { 'PayloadType' => 'com.apple.mcxMenuExtras',
    'HomeSync.menu' => $menuExtra,
  }

  $mcx_payload  = { 'PayloadType' => 'com.apple.MCX',
      'cachedaccounts.WarnOnCreate.allowNever'              => $warnOnCreateAllowNever,
      'com.apple.cachedaccounts.CreateAtLogin'              => $createAtLogin,
      'com.apple.cachedaccounts.CreatePHDAtLogin'           => $createPHDAtLogin,
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
    'syncedFolders-managed'                => $syncedFolders,
    'syncedPrefFolders-managed'            => $syncedPrefFolders,
    'excludedItems'                        => $excludedItems,
    'excludedPrefItems'                    => $excludedPrefItems,
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
    'loginNonprefSyncConflictResolution'   => $loginNonprefSyncConflictResolution,
    'logoutPrefSyncConflictResolution'     => $logoutPrefSyncConflictResolution,
    'logoutNonprefSyncConflictResolution'  => $logoutNonprefSyncConflictResolution,
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

  mobileconfig { 'managedmac.portablehomes.alacarte':
    ensure       => $enable ? {
      true     => 'present',
      default  => 'absent',
    },
    content      => [$menu_payload, $mcx_payload, $homesync_payload],
    displayname  => 'Managed Mac: Portable Home Directories',
    description  => 'Portable Home Directory configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
  }

}