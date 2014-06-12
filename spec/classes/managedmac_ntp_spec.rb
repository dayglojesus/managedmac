require 'spec_helper'

describe 'managedmac::ntp', :type => 'class' do

  context "when $enable is invalid" do
    let(:params) do
      { :enable => 'whatever' }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /not a boolean/)
    end
  end

  context "when $servers is invalid" do
    let(:params) do
      { :enable => 'whatever' }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /not a boolean/)
    end
  end

  context "when $enable == undef" do
    let(:params) do
      { :enable => '' }
    end
    it { should compile.with_all_deps }
  end

  context "when $enable == false" do
    let(:params) do
      {
        :enable  => false,
        :servers => ['time.apple.com', 'time1.google.com']
      }
    end
    specify do
      should contain_file('ntp_conf').that_notifies('Service[org.ntp.ntpd]')\
        .with({
          'content' => "server\stime.apple.com"
        })
    end
    specify do
      should contain_service('org.ntp.ntpd').that_requires('File[ntp_conf]')\
        .with({ 'ensure' => false, 'enable' => 'true' })
    end
    it { should_not contain_exec('ntp_sync') }
  end

  context "when $enable == false" do
    let(:params) do
      {
        :enable  => true,
        :servers => ['time.apple.com', 'time1.google.com']
      }
    end
    specify do
      should contain_file('ntp_conf').that_notifies('Service[org.ntp.ntpd]')\
        .with({
          'content' => "server\stime.apple.com\nserver\stime1.google.com"
        })
    end
    specify do
      should contain_service('org.ntp.ntpd').that_requires('File[ntp_conf]')\
        .with({ 'ensure' => true, 'enable' => 'true' })
    end
    it { should contain_exec('ntp_sync') }
  end

end