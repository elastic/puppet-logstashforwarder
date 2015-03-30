require 'spec_helper_acceptance'

shell("mkdir -p #{default['distmoduledir']}/another/files")
scp_to(default, 'spec/fixtures/ssl/logstash-forwarder.crt', "#{default['distmoduledir']}/another/files/logstash-forwarder.crt")
scp_to(default, 'spec/fixtures/ssl/logstash-forwarder.key', "#{default['distmoduledir']}/another/files/logstash-forwarder.key")

describe "logstashfowarder class:" do

  describe "Standard" do

    it 'should run successfully' do
      pp = "class { 'logstashforwarder': manage_repo => true, servers => ['127.0.0.1:12345'], ssl_key => 'puppet:///modules/another/logstash-forwarder.key', ssl_cert => 'puppet:///modules/another/logstash-forwarder.crt' }
            logstashforwarder::file { 'syslog': paths => [ '/var/log/messages' ] }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end


    describe service('logstash-forwarder') do
      it { should be_enabled }
      it { should be_running }
    end

    describe package('logstash-forwarder') do
      it { should be_installed }
    end

    describe file('/var/run/logstash-forwarder.pid') do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe file('/etc/logstash-forwarder.conf') do
      it { should be_file }
      it { should contain '127.0.0.1:12345' }
    end

  end

  describe "module removal" do

    it 'should run successfully' do
      pp = "class { 'logstashforwarder': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/logstash-forwarder') do
      it { should_not be_directory }
    end

    describe package('logstash-forwarder') do
      it { should_not be_installed }
    end

    describe service('logstash-forwarder') do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

end
