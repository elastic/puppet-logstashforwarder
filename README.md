# puppet-logstashforwarder

A puppet module for managing [logstash-forwarder](https://github.com/elastic/logstash-forwarder)

[![Build Status](https://travis-ci.org/elastic/puppet-logstashforwarder.png?branch=master)](https://travis-ci.org/elastic/puppet-logstashforwarder)

## Requirements

* Puppet 2.7.x or better.
* The [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) Puppet library.

Optional:
* The [apt](http://forge.puppetlabs.com/puppetlabs/apt) Puppet library when using repo management on Debian/Ubuntu.

## Usage

Installation, make sure service is running and will be started at boot time:

     class { 'logstashforwarder': }

Install a certain version:

     class { 'logstashforwarder':
       version => '1.0'
     }

In the absense of an appropriate package for your environment it is possible to install from other sources as well.

http/https/ftp source:

     class { 'logstashforwarder':
       package_url => 'http://download.website.com/packages/logstashforwarder.rpm'
     }

`puppet://` source:

     class { 'logstashforwarder':
       package_url => 'puppet:///path/to/logstashforwarder.rpm'
     }

Local file source:

     class { 'logstashforwarder':
       package_url => 'file:/path/to/logstashforwarder.rpm'
     }

Attempt to upgrade logstashforwarder if a newer package is detected (`false` by default):

     class { 'logstashforwarder':
       autoupgrade => true
     }

Install everything but *disable* the service (useful for pre-configuring systems):

     class { 'logstashforwarder':
       status => 'disabled'
     }

Under normal circumstances a modification to the logstashforwarder configuration will trigger a restart of the service. This behaviour can be disabled:

     class { 'logstashforwarder':
       restart_on_change => false
     }
     
Disable and remove logstashforwarder entirely:

     class { 'logstashforwarder':
       ensure => 'absent'
     }     

## Configuration

### Network and SSL

For the network part of the configuration you need to set the servers and ssl information.

     class { 'logstashforwarder':
       servers  => [ 'logstash.yourdomain.com' ],
       ssl_key  => 'puppet:///path/to/your/ssl.key',
       ssl_ca   => 'puppet:///path/to/your/ssl.ca',
       ssl_cert => 'puppet:///path/to/your/ssl.cert'
     }

If you already manage the SSL files you can also specify them as the full path.

     class { 'logstashforwarder':
       servers  => [ 'logstash.yourdomain.com' ],
       ssl_key  => '/path/to/your/ssl.key',
       ssl_ca   => '/path/to/your/ssl.ca',
       ssl_cert => '/path/to/your/ssl.cert'
     }

### Files

For configuring the files you want to process you can use the 'file' define:

     logstashforwarder::file { 'apache':
       paths  => [ '/var/log/apache/access.log' ],
       fields => { 'type' => 'apache' },
     }

The 'fields' hash allows you to set custom fields which you can use in Logstash.

## Repository management

Most sites will manage repositories seperately; however, this module can manage the repository for you.

     class { 'logstashforwarder':
       manage_repo  => true
     }

Note: When using this on Debian/Ubuntu you will need to add the [Puppetlabs/apt](http://forge.puppetlabs.com/puppetlabs/apt) module to your modules.

## Service Management

Currently only the basic SysV-style [init](https://en.wikipedia.org/wiki/Init) service provider is supported but others could be implemented relatively easily (pull requests welcome).

### init

#### Defaults File

The *defaults* file (`/etc/defaults/logstashforwarder` or `/etc/sysconfig/logstashforwarder`) for the logstashforwarder service can be populated as necessary. This can either be a static file resource or a simple key value-style  [hash](http://docs.puppetlabs.com/puppet/latest/reference/lang_datatypes.html#hashes) object, the latter being particularly well-suited to pulling out of a data source such as Hiera.

##### file source

     class { 'logstashforwarder':
       init_defaults_file => 'puppet:///path/to/defaults'
     }

##### hash representation

     $config_hash = {
       'logstashforwarder_USER' => 'logstashforwarder',
       'logstashforwarder_GROUP' => 'logstashforwarder',
     }

     class { 'logstashforwarder':
       init_defaults => $config_hash
     }


## Support

Need help? Join us in `#logstash` on Freenode IRC or on the https://discuss.elastic.co/c/logstash discussion forum.
