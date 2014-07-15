require 'spec_helper'

describe 'managedmac::activedirectory', :type => 'class' do

  context "when $enable == undef" do
    it { should compile.with_all_deps }
  end

  context "when $enable == false" do
    let(:params) do
      { :enable => false }
    end
    specify do
      should contain_mobileconfig('managedmac.activedirectory.alacarte').with_ensure('absent')
    end
  end

  context "when $enable == true but REQUIRED params params are NOT set" do
    let(:params) do
      { :enable => true }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /You must specify a.*param/)
    end
  end

  context "when $enable == true and REQUIRED params are set" do
    let(:params) do
      {
        :enable   => true,
        :hostname => 'foo.ad.com',
        :username => 'account',
        :password => 'password',
      }
    end
    specify do
      should contain_mobileconfig('managedmac.activedirectory.alacarte').with_ensure('present')
    end
  end

end