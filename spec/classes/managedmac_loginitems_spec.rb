require 'spec_helper'

describe 'managedmac::loginitems', :type => 'class' do

  context "when none of the params are set" do
    it do
      should contain_mobileconfig('managedmac.loginitems.alacarte').with_ensure('absent')
    end
  end

  context "when passed a BAD param" do
    let(:params) do
      { :filesandfolders => 'not a valid path', }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /not an Array/)
    end
  end

  context "when a URLs array is specified" do
    let(:params) do
      { :urls => ['afp://some.server.com/volume', 'smb://some.server.com/volume'] }
    end
    it do
      should contain_mobileconfig('managedmac.loginitems.alacarte').with_ensure('present')
    end
  end

  context "when a Files and Folders array is specified" do
    let(:params) do
      { :filesandfolders => ['/Applications/Chess.app', '~/Documents'] }
    end
    it do
      should contain_mobileconfig('managedmac.loginitems.alacarte').with_ensure('present')
    end
  end

end