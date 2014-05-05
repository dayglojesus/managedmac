require 'spec_helper'

describe 'managedmac::ntp', :type => 'class' do

  context "when $ensure is invalid" do
    let(:params) do
      { :ensure => 'whatever' }
    end

    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /Parameter Error/)
    end
  end

  # Test ensurability
  context "when $ensure => 'absent'" do

    let(:facts) { { :ntp_offset => 300, } }

    let(:params) do
      { :ensure  => 'absent' }
    end

    it { should contain_file('ntp_conf')\
      .with_content('time.apple.com') }

    it { should contain_service('org.ntp.ntpd')\
      .with_ensure('stopped') }

    it { should_not contain_exec('ntp_sync') }

  end

  context "when it is passed no params" do
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end

  context "when it is passed a BAD param" do
    let(:params) do
      { :options => "Icanhazstring", }
    end

    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end

  context "when passed a Hash parameter with valid options" do

    let(:facts) { { :ntp_offset => 60, } }

    let(:params) do
      { :options => options_ntp, }
    end

    specify do
      should contain_file('ntp_conf').that_notifies('Service[org.ntp.ntpd]')\
        .with({
          'content' => "server\stime.apple.com\nserver\stime1.google.com"
        })
    end

    specify do
      should contain_service('org.ntp.ntpd').that_requires('File[ntp_conf]')\
        .with({ 'ensure' => 'running', 'enable' => 'true' })
    end

    context "when max_offset is not exceeded" do
      specify do
        should_not contain_exec('ntp_sync')
      end
    end

    context "when max_offset is positively exceeded" do
      let(:facts) { { :ntp_offset => 300, } }
      specify do
        should contain_exec('ntp_sync').that_requires(
          'Service[org.ntp.ntpd]')
      end
    end

    context "when max_offset is negatively exceeded" do
      let(:facts) { { :ntp_offset => -300, } }
      specify do
        should contain_exec('ntp_sync').that_requires(
          'Service[org.ntp.ntpd]')
      end
    end

    it { should compile.with_all_deps }
  end

end