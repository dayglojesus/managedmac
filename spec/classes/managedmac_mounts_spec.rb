require 'spec_helper'

describe 'managedmac::mounts', :type => 'class' do

  context "when none of the params are set" do
    it do
      should contain_mobileconfig('managedmac.mounts.alacarte').with_ensure('absent')
    end
  end

  context "when passed a BAD param" do
    let(:params) do
      { :urls => 'not a valid path', }
    end
    it { should raise_error(Puppet::Error, /not an Array/) }
  end

  context "when a URLs array is specified" do
    let(:params) do
      { :urls => ['afp://some.server.com/volume', 'smb://some.server.com/volume'] }
    end
    it do
      should contain_mobileconfig('managedmac.mounts.alacarte').with_ensure('present')
    end
  end

end