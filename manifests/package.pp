# == Class: logstashforwarder::package
#
# This class exists to coordinate all software package management related
# actions, functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'logstashforwarder::package': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class logstashforwarder::package {


  #### Package management

  # set params: in operation
  if $logstashforwarder::ensure == 'present' {

    # Check if we want to install a specific version or not
    if $logstashforwarder::version == false {

      $package_ensure = $logstashforwarder::autoupgrade ? {
        true  => 'latest',
        false => 'present',
      }

    } else {

      # install specific version
      $package_ensure = $logstashforwarder::version

    }

    # action
    if ($logstashforwarder::package_url != undef) {

      $package_dir = $logstashforwarder::package_dir

      case $logstashforwarder::package_provider {
        'package': { $before = Package[$logstashforwarder::params::package]  }
        default:   { fail("software provider \"${logstashforwarder::package_provider}\".") }
      }

      # Create directory to place the package file
      exec { 'create_package_dir_logstashforwarder':
        cwd     => '/',
        path    => ['/usr/bin', '/bin'],
        command => "mkdir -p ${logstashforwarder::package_dir}",
        creates => $logstashforwarder::package_dir;
      }

      file { $package_dir:
        ensure  => 'directory',
        purge   => $logstashforwarder::purge_package_dir,
        force   => $logstashforwarder::purge_package_dir,
        require => Exec['create_package_dir_logstashforwarder'],
      }

      $filenameArray = split($logstashforwarder::package_url, '/')
      $basefilename = $filenameArray[-1]

      $sourceArray = split($logstashforwarder::package_url, ':')
      $protocol_type = $sourceArray[0]

      $extArray = split($basefilename, '\.')
      $ext = $extArray[-1]

      $pkg_source = "${package_dir}/${basefilename}"

      case $protocol_type {

        puppet: {

          file { $pkg_source:
            ensure  => present,
            source  => $logstashforwarder::package_url,
            require => File[$package_dir],
            backup  => false,
            before  => $before
          }

        }
        ftp, https, http: {

          exec { 'download_package_logstashforwarder':
            command => "${logstashforwarder::params::download_tool} ${pkg_source} ${logstashforwarder::package_url} 2> /dev/null",
            path    => ['/usr/bin', '/bin'],
            creates => $pkg_source,
            timeout => $logstashforwarder::package_dl_timeout,
            require => File[$package_dir],
            before  => $before
          }

        }
        file: {

          $source_path = $sourceArray[1]
          file { $pkg_source:
            ensure  => present,
            source  => $source_path,
            require => File[$package_dir],
            backup  => false,
            before  => $before
          }

        }
        default: {
          fail("Protocol must be puppet, file, http, https, or ftp. You have given \"${protocol_type}\"")
        }
      }

      case $ext {
        'deb':   { $pkg_provider = 'dpkg' }
        'rpm':   { $pkg_provider = 'rpm'  }
        default: { fail("Unknown file extention \"${ext}\".") }
      }

    } else {
      $pkg_source = undef
      $pkg_provider = undef
    }

  # Package removal
  } else {

    $pkg_source = undef
    $pkg_provider = undef
    $package_ensure = 'purged'
  }

  case $logstashforwarder::package_provider {
    'package': {

      package { $logstashforwarder::params::package:
        ensure   => $package_ensure,
        source   => $pkg_source,
        provider => $pkg_provider
      }

    }
    default: {
      fail("\"${logstashforwarder::package_provider}\" is not supported as package provider")
    }
  }

}
