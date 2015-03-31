# == Class: logstashforwarder
#
# This class is able to install or remove logstashforwarder on a node.
# It manages the status of the related service.
#
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed software packages are being uninstalled.
#   * Any traces of the packages will be purged as good as possible. This may
#     include existing configuration files. The exact behavior is provider
#     dependent. Q.v.:
#     * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
#     * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   * System modifications (if any) will be reverted as good as possible
#     (e.g. removal of created users, services, changed log settings, ...).
#   * This is thus destructive and should be used with care.
#   Defaults to <tt>present</tt>.
#
# [*autoupgrade*]
#   Boolean. If set to <tt>true</tt>, any managed package gets upgraded
#   on each Puppet run when the package provider is able to find a newer
#   version than the present one. The exact behavior is provider dependent.
#   Q.v.:
#   * Puppet type reference: {package, "upgradeable"}[http://j.mp/xbxmNP]
#   * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   Defaults to <tt>false</tt>.
#
# [*status*]
#   String to define the status of the service. Possible values:
#   * <tt>enabled</tt>: Service is running and will be started at boot time.
#   * <tt>disabled</tt>: Service is stopped and will not be started at boot
#     time.
#   * <tt>running</tt>: Service is running but will not be started at boot time.
#     You can use this to start a service on the first Puppet run instead of
#     the system startup.
#   * <tt>unmanaged</tt>: Service will not be started at boot time and Puppet
#     does not care whether the service is running or not. For example, this may
#     be useful if a cluster management software is used to decide when to start
#     the service plus assuring it is running on the desired node.
#   Defaults to <tt>enabled</tt>. The singular form ("service") is used for the
#   sake of convenience. Of course, the defined status affects all services if
#   more than one is managed (see <tt>service.pp</tt> to check if this is the
#   case).
#
# [*version*]
#   String to set the specific version you want to install.
#   Defaults to <tt>false</tt>.
#
# [*restart_on_change*]
#   Boolean that determines if the application should be automatically restarted
#   whenever the configuration changes. Disabling automatic restarts on config
#   changes may be desired in an environment where you need to ensure restarts
#   occur in a controlled/rolling manner rather than during a Puppet run.
#
#   Defaults to <tt>true</tt>, which will restart the application on any config
#   change. Setting to <tt>false</tt> disables the automatic restart.
#
# [*configdir*]
#   Path to directory containing the Logstash Forwarder configuration.
#   Use this setting if your packages deviate from the norm (/etc/logstashforwarder)
#
# [*package_url*]
#   Url to the package to download.
#   This can be a http,https or ftp resource for remote packages
#   puppet:// resource or file:/ for local packages
#
# [*package_provider*]
#   Way to install the packages, currently only packages are supported.
#
# [*package_dir*]
#   Directory where the packages are downloaded to
#
# [*purge_package_dir*]
#   Purge package directory on removal
#
# [*package_dl_timeout*]
#   For http,https and ftp downloads you can set howlong the exec resource may take.
#   Defaults to: 600 seconds
#
# [*logstashforwarder_user*]
#   The user Logstash Forwarder should run as. This also sets the file rights.
#
# [*logstashforwarder_group*]
#   The group Logstash Forwarder should run as. This also sets the file rights
#
# [*purge_configdir*]
#   Purge the config directory for any unmanaged files
#
# [*service_provider*]
#   Service provider to use. By Default when a single service provider is possibe that one is selected.
#
# [*init_defaults*]
#   Defaults file content in hash representation
#
# [*init_defaults_file*]
#   Defaults file as puppet resource
#
# [*init_template*]
#   Service file as a template
#
# [*manage_repo*]
#   Enable repo management by enabling our official repositories
#
# [*servers*]
#   A list of downstream servers listening for our messages.
#   logstash-forwarder will pick one at random and only switch if
#   the selected one appears to be dead or unresponsive
#
# [*ssl_cert*]
#   The path to your client ssl certificate
#
# [*ssl_key*]
#   The path to your client ssl key
#
# [*ssl_ca*]
#   The path to your trusted ssl CA file. This is used
#   to authenticate your downstream server.
#
# [*timeout*]
#   Network timeout in seconds. This is most important for
#   logstash-forwarder determining whether to stop waiting for an
#   acknowledgement from the downstream server. If an timeout is reached,
#   logstash-forwarder will assume the connection or server is bad and
#   will connect to a server chosen at random from the servers list.
#
# The default values for the parameters are set in logstashforwarder::params. Have
# a look at the corresponding <tt>params.pp</tt> manifest file if you need more
# technical information about them.
#
#
# === Examples
#
# * Installation, make sure service is running and will be started at boot time:
#     class { 'logstashforwarder': }
#
# * Removal/decommissioning:
#     class { 'logstashforwarder':
#       ensure => 'absent',
#     }
#
# * Install everything but disable service(s) afterwards
#     class { 'logstashforwarder':
#       status => 'disabled',
#     }
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elastic.co>
#
class logstashforwarder(
  $ensure                  = $logstashforwarder::params::ensure,
  $servers                 = undef,
  $ssl_cert                = undef,
  $ssl_key                 = undef,
  $ssl_ca                  = undef,
  $timeout                 = 15,
  $status                  = $logstashforwarder::params::status,
  $restart_on_change       = $logstashforwarder::params::restart_on_change,
  $autoupgrade             = $logstashforwarder::params::autoupgrade,
  $version                 = false,
  $package_provider        = 'package',
  $package_url             = undef,
  $package_dir             = $logstashforwarder::params::package_dir,
  $purge_package_dir       = $logstashforwarder::params::purge_package_dir,
  $package_dl_timeout      = $logstashforwarder::params::package_dl_timeout,
  $logstashforwarder_user  = $logstashforwarder::params::logstashforwarder_user,
  $logstashforwarder_group = $logstashforwarder::params::logstashforwarder_group,
  $configdir               = $logstashforwarder::params::configdir,
  $purge_configdir         = $logstashforwarder::params::purge_configdir,
  $service_provider        = 'init',
  $init_defaults           = $logstashforwarder::params::init_defaults,
  $init_defaults_file      = undef,
  $init_template           = undef,
  $manage_repo             = false
) inherits logstashforwarder::params {

  anchor {'logstashforwarder::begin': }
  anchor {'logstashforwarder::end': }


  #### Validate parameters

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }


  #### Manage actions

  # package(s)
  class { 'logstashforwarder::package': }

  # configuration
  class { 'logstashforwarder::config': }

  # service(s)
  class { 'logstashforwarder::service': }

  if ($manage_repo == true) {
    # Set up repositories
    class { 'logstashforwarder::repo': }

    # Ensure that we set up the repositories before trying to install
    # the packages
    Anchor['logstashforwarder::begin']
    -> Class['logstashforwarder::repo']
    -> Class['logstashforwarder::package']
  }

  #### Manage relationships

  if $ensure == 'present' {

    # autoupgrade
    validate_bool($autoupgrade)

    # service status
    if ! ($status in [ 'enabled', 'disabled', 'running', 'unmanaged' ]) {
      fail("\"${status}\" is not a valid status parameter value")
    }

    # restart on change
    validate_bool($restart_on_change)

    # purge conf dir
    validate_bool($purge_configdir)

    if ! ($service_provider in $logstashforwarder::params::service_providers) {
      fail("\"${service_provider}\" is not a valid provider for \"${::operatingsystem}\"")
    }

    validate_bool($manage_repo)

    validate_array($servers)
    validate_string($ssl_key, $ssl_ca, $ssl_cert)

    if (!is_integer($timeout)) {
      fail("\"${timeout}\" is not a valid timeout value")
    }

    # we need the software before configuring it
    Anchor['logstashforwarder::begin']
    -> Class['logstashforwarder::package']
    -> Class['logstashforwarder::config']

    # we need the software and a working configuration before running a service
    Class['logstashforwarder::package'] -> Class['logstashforwarder::service']
    Class['logstashforwarder::config']  -> Class['logstashforwarder::service']

    Class['logstashforwarder::service'] -> Anchor['logstashforwarder::end']

  } else {

    # make sure all services are getting stopped before software removal
    Anchor['logstashforwarder::begin']
    -> Class['logstashforwarder::service']
    -> Class['logstashforwarder::package']
    -> Anchor['logstashforwarder::end']

  }

}
