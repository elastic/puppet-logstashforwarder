require 'spec_helper'

describe 'logstashforwarder', :type => 'class' do

    default_params = {
      :servers  => [ '192.168.0.1' ],
      :ssl_ca   => '/path/to/ssl.ca',
      :ssl_key  => '/path/to/ssl.key',
      :ssl_cert => '/path/to/ssl.cert'
    }

  on_supported_os.each do |os, facts|

    context "on #{os} OS" do

      case facts[:osfamily]
      when 'Debian'
        let(:defaults_path) { '/etc/default' }
        let(:pkg_ext) { 'deb' }
        let(:pkg_prov) { 'dpkg' }
      when 'RedHat'
        let(:defaults_path) { '/etc/sysconfig' }
        let(:pkg_ext) { 'rpm' }
        let(:pkg_prov) { 'rpm' }
      when 'Suse'
        let(:defaults_path) { '/etc/sysconfig' }
        let(:pkg_ext) { 'rpm' }
        let(:pkg_prov) { 'rpm' }
      end

      let (:facts) {
        facts
      }

      let (:params) {
        default_params   
      }

      context 'main class tests' do

        # init.pp
        it { should contain_anchor('logstashforwarder::begin') }
        it { should contain_anchor('logstashforwarder::end').that_requires('Class[logstashforwarder::service]') }
        it { should contain_class('logstashforwarder::params') }
        it { should contain_class('logstashforwarder::package').that_requires('Anchor[logstashforwarder::begin]') }
        it { should contain_class('logstashforwarder::config').that_requires('Class[logstashforwarder::package]') }
        it { should contain_class('logstashforwarder::service').that_requires('Class[logstashforwarder::package]').that_requires('Class[logstashforwarder::config]') }

        it { should contain_file('/etc/logstashforwarder') }
        it { should contain_file('/etc/logstashforwarder/ssl') }

        it { should contain_logstashforwarder_config('lsf-config') }
      end

      context 'package installation' do
        
        context 'via repository' do

          context 'with default settings' do
            
           it { should contain_package('logstash-forwarder').with(:ensure => 'present') }

          end

          context 'with specified version' do

            let (:params) {
              default_params.merge({
              :version => '1.0'
              })
            }

            it { should contain_package('logstash-forwarder').with(:ensure => '1.0') }
          end

          context 'with auto upgrade enabled' do

            let (:params) {
              default_params.merge({
              :autoupgrade => true
              })
            }

            it { should contain_package('logstash-forwarder').with(:ensure => 'latest') }
          end

          context 'when setting package version and package_url' do

            let (:params) {
              default_params.merge({
                :version     => '0.90.10',
                :package_url => 'puppet:///path/to/some/logstash-forwarder-0.90.10.#{pkg_ext}'
              })
            }

            it { expect { should raise_error(Puppet::Error) } }
          end

        end

        context 'via package_url setting' do

          context 'using puppet:/// schema' do

            let (:params) {
              default_params.merge({
                :package_url => "puppet:///path/to/package.#{pkg_ext}"
              })
            }

            it { should contain_exec('create_package_dir_logstashforwarder').with(:command => 'mkdir -p /opt/logstashforwarder/swdl') }
            it { should contain_file('/opt/logstashforwarder/swdl/').with(:purge => false, :force => false, :require => "Exec[create_package_dir_logstashforwarder]") }
            it { should contain_file("/opt/logstashforwarder/swdl/package.#{pkg_ext}").with(:source => "puppet:///path/to/package.#{pkg_ext}", :backup => false) }
            it { should contain_package('logstash-forwarder').with(:ensure => 'present', :source => "/opt/logstashforwarder/swdl/package.#{pkg_ext}", :provider => pkg_prov) }
          end

          context 'using http:// schema' do

            let (:params) {
              default_params.merge({
                :package_url => "http://www.domain.com/path/to/package.#{pkg_ext}"
              })
            } 

            it { should contain_exec('create_package_dir_logstashforwarder').with(:command => 'mkdir -p /opt/logstashforwarder/swdl') }
            it { should contain_file('/opt/logstashforwarder/swdl/').with(:purge => false, :force => false, :require => "Exec[create_package_dir_logstashforwarder]") }
            it { should contain_exec('download_package_logstashforwarder').with(:command => "wget -O /opt/logstashforwarder/swdl/package.#{pkg_ext} http://www.domain.com/path/to/package.#{pkg_ext} 2> /dev/null", :require => 'File[/opt/logstashforwarder/swdl]') }
            it { should contain_package('logstash-forwarder').with(:ensure => 'present', :source => "/opt/logstashforwarder/swdl/package.#{pkg_ext}", :provider => pkg_prov) }
          end

          context 'using https:// schema' do

            let (:params) {
              default_params.merge({
                :package_url => "https://www.domain.com/path/to/package.#{pkg_ext}"
              })
            }

            it { should contain_exec('create_package_dir_logstashforwarder').with(:command => 'mkdir -p /opt/logstashforwarder/swdl') }
            it { should contain_file('/opt/logstashforwarder/swdl').with(:purge => false, :force => false, :require => 'Exec[create_package_dir_logstashforwarder]') }
            it { should contain_exec('download_package_logstashforwarder').with(:command => "wget -O /opt/logstashforwarder/swdl/package.#{pkg_ext} https://www.domain.com/path/to/package.#{pkg_ext} 2> /dev/null", :require => 'File[/opt/logstashforwarder/swdl]') }
            it { should contain_package('logstash-forwarder').with(:ensure => 'present', :source => "/opt/logstashforwarder/swdl/package.#{pkg_ext}", :provider => pkg_prov) }
          end

          context 'using ftp:// schema' do

            let (:params) {
              default_params.merge({
                :package_url => "ftp://www.domain.com/path/to/package.#{pkg_ext}"
              })
            }

            it { should contain_exec('create_package_dir_logstashforwarder').with(:command => 'mkdir -p /opt/logstashforwarder/swdl') }
            it { should contain_file('/opt/logstashforwarder/swdl').with(:purge => false, :force => false, :require => 'Exec[create_package_dir_logstashforwarder]') }
            it { should contain_exec('download_package_logstashforwarder').with(:command => "wget -O /opt/logstashforwarder/swdl/package.#{pkg_ext} ftp://www.domain.com/path/to/package.#{pkg_ext} 2> /dev/null", :require => 'File[/opt/logstashforwarder/swdl]') }
            it { should contain_package('logstash-forwarder').with(:ensure => 'present', :source => "/opt/logstashforwarder/swdl/package.#{pkg_ext}", :provider => pkg_prov) }
          end

          context 'using file:// schema' do

            let (:params) {
              default_params.merge({
                :package_url => "file:/path/to/package.#{pkg_ext}"
              })
            }

            it { should contain_exec('create_package_dir_logstashforwarder').with(:command => 'mkdir -p /opt/logstashforwarder/swdl') }
            it { should contain_file('/opt/logstashforwarder/swdl').with(:purge => false, :force => false, :require => 'Exec[create_package_dir_logstashforwarder]') }
            it { should contain_file("/opt/logstashforwarder/swdl/package.#{pkg_ext}").with(:source => "/path/to/package.#{pkg_ext}", :backup => false) }
            it { should contain_package('logstash-forwarder').with(:ensure => 'present', :source => "/opt/logstashforwarder/swdl/package.#{pkg_ext}", :provider => pkg_prov) }
          end

        end

      end # package

      context 'service setup' do

        context 'with provider \'init\'' do

          it { should contain_logstashforwarder__service__init('logstash-forwarder') }

          context 'and default settings' do

            it { should contain_service('logstash-forwarder').with(:ensure => 'running') }

          end

          context 'and set defaults via hash param' do

            let (:params) {
              default_params.merge({
                :init_defaults => { 'SERVICE_USER' => 'root', 'SERVICE_GROUP' => 'root' }
              })
            }

            it { should contain_file("#{defaults_path}/logstash-forwarder").with(:content => "### MANAGED BY PUPPET ###\n\nSERVICE_GROUP=root\nSERVICE_USER=root\n") }

          end

          context 'and set defaults via file param' do

            let (:params) {
              default_params.merge({
                :init_defaults_file => 'puppet:///path/to/logstashforwarder.defaults'
              })
            }

            it { should contain_file("#{defaults_path}/logstash-forwarder").with(:source => 'puppet:///path/to/logstashforwarder.defaults') }

          end

          context 'and set init file via template' do

            let (:params) {
              default_params.merge({
                :init_template => "logstashforwarder/etc/init.d/logstashforwarder.Debian.erb"
              })
            }

            it { should contain_file('/etc/init.d/logstash-forwarder') }

          end

          context 'No service restart when restart_on_change is false' do

            let (:params) {
              default_params.merge({
                :init_template     => "logstashforwarder/etc/init.d/logstashforwarder.Debian.erb",
                :restart_on_change => false
              })
            }

            it { should contain_file('/etc/init.d/logstash-forwarder').without_notify }

          end

          context 'when its unmanaged do nothing with it' do

            let (:params) {
              default_params.merge({
                :status => 'unmanaged'
              })
            }

            it { should contain_service('logstash-forwarder').with(:ensure => nil, :enable => false) }

          end

        end

      end # Services

      context 'When managing the repository' do

        let (:params) {
          default_params.merge({
            :manage_repo => true,
          })
        }
        case facts[:osfamily]
        when 'Debian'
          it { should contain_class('logstashforwarder::repo').that_requires('Anchor[logstashforwarder::begin]') }
          it { should contain_class('apt') }
          it { should contain_apt__source('logstashforwarder').with(:release => 'stable', :repos => 'main', :location => 'http://packages.elasticsearch.org/logstashforwarder/debian') }
        when 'RedHat'
          it { should contain_class('logstashforwarder::repo').that_requires('Anchor[logstashforwarder::begin]') }
          it { should contain_yumrepo('logstashforwarder').with(:baseurl => 'http://packages.elasticsearch.org/logstashforwarder/centos', :gpgkey => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch', :enabled => 1) }
        when 'SuSE'
          it { should contain_class('logstashforwarder::repo').that_requires('Anchor[logstashforwarder::begin]') }
          it { should contain_exec('logstashforwarder_suse_import_gpg') }
          it { should contain_zypprepo('logstashforwarder').with(:baseurl => 'http://packages.elasticsearch.org/logstashforwarder/centos') }
        end

      end

      context 'when setting the module to absent' do

        let (:params) {
          default_params.merge({
            :ensure => 'absent'
          })
        }

        it { should contain_file('/etc/logstashforwarder').with(:ensure => 'absent', :force => true, :recurse => true) }
        it { should contain_package('logstash-forwarder').with(:ensure => 'purged') }
        it { should contain_service('logstash-forwarder').with(:ensure => 'stopped', :enable => false) }

      end

    end

  end

end
