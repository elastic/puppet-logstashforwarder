# == Class: logstashforwarder::repo
#
# This class exists to install and manage yum and apt repositories
# that contain elasticsearch official Logstash Forwarder packages
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
#   class { 'logstashforwarder::repo': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class logstashforwarder::repo {

  Exec {
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd       => '/',
  }

  case $::osfamily {
    'Debian': {
      if !defined(Class['apt']) {
        class { 'apt': }
      }

      apt::source { 'logstashforwarder':
        location    => 'http://packages.elasticsearch.org/logstashforwarder/debian',
        release     => 'stable',
        repos       => 'main',
        key         => 'D88E42B4',
        key_source  => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
        include_src => false,
      }
    }
    'RedHat', 'Linux': {
      yumrepo { 'logstashforwarder':
        descr    => 'Logstash Forwarder repo',
        baseurl  => 'http://packages.elasticsearch.org/logstashforwarder/centos',
        gpgcheck => 1,
        gpgkey   => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
        enabled  => 1,
      }
    }
    'Suse': {
      exec { 'logstashforwarder_suse_import_gpg':
        command => 'rpmkeys --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
        unless  => 'test $(rpm -qa gpg-pubkey | grep -i "D88E42B4" | wc -l) -eq 1 ',
        notify  => [ Zypprepo['elasticsearch'] ]
      }

      zypprepo { 'logstashforwarder':
        baseurl     => 'http://packages.elasticsearch.org/logstashforwarder/centos',
        enabled     => 1,
        autorefresh => 1,
        name        => 'logstashforwarder',
        gpgcheck    => 1,
        gpgkey      => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
        type        => 'yum'
      }
    }
    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
    }
  }
}
