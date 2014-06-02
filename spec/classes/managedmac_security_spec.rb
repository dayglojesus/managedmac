require 'spec_helper'

describe 'managedmac::security', :type => 'class' do

  context "when $enable == true" do
    let(:params) do
      { :enable => true }
    end
    it do
      should contain_mobileconfig('managedmac.security.alacarte').with_ensure('present')
    end
  end

  context "when $enable == false" do
    let(:params) do
      { :enable => false }
    end
    it do
      should contain_mobileconfig('managedmac.security.alacarte').with_ensure('absent')
    end
  end

  context "when passed a BAD param" do
    let(:params) do
      { :enable => true, :ask_for_password => 'a string', }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /not a boolean/)
    end
  end

end