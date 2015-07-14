require 'spec_helper'

describe 'managedmac::security', :type => 'class' do

  context "when none of the params is set" do
    it do
      should contain_mobileconfig('managedmac.security.alacarte').with_ensure('absent')
    end
  end

  context "when passed a BAD param" do
    let(:params) do
      { :ask_for_password => 'a string', }
    end
    it { should raise_error(Puppet::Error, /not a boolean/) }
  end

  context "when one of the params is set" do
    let(:params) do
      { :ask_for_password => true }
    end
    it do
      should contain_mobileconfig('managedmac.security.alacarte').with_ensure('present')
    end
  end

end