require 'spec_helper'

describe 'logstashforwarder::file', :type => 'define' do

  let(:title) { 'foo' }
  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux'
  } end

  let(:pre_condition) { 'class {"logstashforwarder": servers => [ "192.168.0.1" ], ssl_ca => "/path/to/ssl.ca", ssl_key  => "/path/to/ssl.key", ssl_cert => "/path/to/ssl.cert" }' }

  context "Add a file" do

    let :params do {
      :paths => [ '/var/log/message' ]
    } end

    it { should contain_logstashforwarder__file('foo') }
    it { should contain_logstashforwarder_fragment('foo').with(:content => "    {\n      \"paths\": [ \"/var/log/message\" ]}") }
  end

  context "Set some extra fields" do

    let :params do {
      :paths => [ '/var/log/message' ],
      :fields => { 'field1' => 'value1', 'field2' => 'value2' }
    } end

    it { should contain_logstashforwarder__file('foo') }
    it { should contain_logstashforwarder_fragment('foo').with(:content => "    {\n      \"paths\": [ \"/var/log/message\" ],\n      \"fields\": { \"field1\": \"value1\", \"field2\": \"value2\" }\n    }") }

  end

end
