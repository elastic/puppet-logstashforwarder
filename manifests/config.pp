# == Class: logstashforwarder::config
#
# FIXME/TODO Please check if you want to remove this class because it may be
#            unnecessary for your module. Don't forget to update the class
#            declarations and relationships at init.pp afterwards (the relevant
#            parts are marked with "FIXME/TODO" comments).
#
# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
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
#   class { 'logstashforwarder::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class logstashforwarder::config {

  #### Configuration

  File {
    owner => $logstashforwarder::logstashforwarder_user,
    group => $logstashforwarder::logstashforwarder_group
  }

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  if ( $logstashforwarder::ensure == 'present' ) {

    $ssldir = "${logstashforwarder::configdir}/ssl"

    $notify_service = $logstashforwarder::restart_on_change ? {
      true  => Class['logstashforwarder::service'],
      false => undef,
    }

    file { $logstashforwarder::configdir:
      ensure => directory,
      mode   => '0644',
      purge  => $logstashforwarder::purge_configdir,
      force  => $logstashforwarder::purge_configdir
    }

    file { $ssldir:
      ensure  => directory,
      require => File[$logstashforwarder::configdir]
    }

    # SSL Files
    $ssl_cert = $logstashforwarder::ssl_cert
    $ssl_ca = $logstashforwarder::ssl_ca
    $ssl_key = $logstashforwarder::ssl_key

    if $ssl_cert =~ /^puppet\:\/\// {

      $filenameArray_ssl_cert = split($ssl_cert, '/')
      $basefilename_ssl_cert = $filenameArray_ssl_cert[-1]

      file { "${ssldir}/${basefilename_ssl_cert}":
        source  => $ssl_cert,
        mode    => '0440',
        require => File[$ssldir]
      }
      $opt_ssl_cert = "${ssldir}/${basefilename_ssl_cert}"
    } else {
      $opt_ssl_cert = $ssl_cert
    }

    if $ssl_ca =~ /^puppet\:\/\// {

      $filenameArray_ssl_ca = split($ssl_ca, '/')
      $basefilename_ssl_ca = $filenameArray_ssl_ca[-1]

      file { "${ssldir}/${basefilename_ssl_ca}":
        source  => $ssl_ca,
        mode    => '0440',
        require => File[$ssldir]
      }
      $opt_ssl_ca = "${ssldir}/${basefilename_ssl_ca}"
    } else {
      $opt_ssl_ca = $ssl_ca
    }

    if $ssl_key =~ /^puppet\:\/\// {

      $filenameArray_ssl_key = split($ssl_key, '/')
      $basefilename_ssl_key = $filenameArray_ssl_key[-1]

      file { "${ssldir}/${basefilename_ssl_key}":
        source  => $ssl_key,
        mode    => '0440',
        require => File[$ssldir]
      }
      $opt_ssl_key = "${ssldir}/${basefilename_ssl_key}"
    } else {
      $opt_ssl_key = $ssl_key
    }

    $server_list = $logstashforwarder::servers
    # Server list
    $opt_servers = inline_template('<%= "[ "+@server_list.sort.collect { |k| "\"#{k}\""}.join(", ")+" ]" %>')

    $opt_timeout = $logstashforwarder::timeout

    $main_config = "{\n  \"network\": {\n    \"servers\": ${opt_servers},\n    \"ssl certificate\": \"${opt_ssl_cert}\",\n    \"ssl ca\": \"${opt_ssl_ca}\",\n    \"ssl key\": \"${opt_ssl_key}\",\n    \"timeout\": ${opt_timeout}\n  },"

    logstashforwarder_config { 'lsf-config':
      ensure  => 'present',
      config  => $main_config,
      path    => "${logstashforwarder::configdir}/config.json",
      tag     => "LSF_CONFIG_${::fqdn}",
      owner   => $logstashforwarder::logstashforwarder_user,
      group   => $logstashforwarder::logstashforwarder_group,
      notify  => $notify_service,
      require => File[$logstashforwarder::configdir]
    }

  } elsif ( $logstashforwarder::ensure == 'absent' ) {

    file { $logstashforwarder::configdir:
      ensure  => 'absent',
      recurse => true,
      force   => true
    }

  }

}
