require 'spec_helper'

describe "managedmac::portablehomes", :type => 'class' do

  context "when passed no params" do
    it do
      should contain_mobileconfig('managedmac.portablehomes.alacarte').with_ensure('absent')
    end
  end

  context "when $menuextra has BAD param" do
    let(:params) do
      { :enable => true, :menuextra => 'on' }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /Invalid parameter/)
    end
  end

  context "when $syncPeriodSeconds has BAD param" do
    let(:params) do
      { :enable => true, :syncPeriodSeconds => 'foobar' }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /not an Integer/)
    end
  end

  context "when $syncPreferencesAtLogin has BAD param" do
    let(:params) do
      { :enable => true, :syncPreferencesAtLogin => 'foobar' }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /Parameter Error: invalid value/)
    end
  end

  context "when $loginPrefSyncConflictResolution has BAD param" do
    let(:params) do
      { :enable => true, :loginPrefSyncConflictResolution => 'foobar' }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /Parameter Error: invalid value/)
    end
  end

  context "when $excludedItems has BAD param" do
    let(:params) do
      { :enable => true, :excludedItems => 'foobar' }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /Wrong arg type.*String instead of Hash/)
    end
  end

  context "when $syncedFolders has BAD param" do
    let(:params) do
      { :enable => true, :syncedFolders => 'foobar' }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /Wrong arg type.*String instead of Array/)
    end
  end

  context "when passed good params" do
    let(:params) do
      { :enable => true }
    end
    it do
      should contain_mobileconfig('managedmac.portablehomes.alacarte').with_ensure('present')
    end
  end

end