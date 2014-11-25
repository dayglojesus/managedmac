require 'spec_helper'

describe "managedmac::portablehomes", :type => 'class' do

  context "product version doesn't matter when $enable is a BOOL" do

    context "when product version is 10.9 and $enable == true" do
      let :facts do
        {
          :macosx_productversion_major => '10.9',
        }
      end

      let(:params) do
        { :enable => true }
      end
      it do
        should contain_mobileconfig('managedmac.portablehomes.alacarte').with_ensure('present')
      end
    end

    context "when product version is 10.9 and $enable == false" do
      let :facts do
        {
          :macosx_productversion_major => '10.9',
        }
      end

      let(:params) do
        { :enable => false }
      end
      it do
        should contain_mobileconfig('managedmac.portablehomes.alacarte').with_ensure('absent')
      end
    end

    context "when product version is 10.10 and $enable == true" do
      let :facts do
        {
          :macosx_productversion_major => '10.10',
        }
      end

      let(:params) do
        { :enable => true }
      end
      it do
        should contain_mobileconfig('managedmac.portablehomes.alacarte').with_ensure('present')
      end
    end

    context "when product version is 10.10 and $enable == false" do
      let :facts do
        {
          :macosx_productversion_major => '10.10',
        }
      end

      let(:params) do
        { :enable => false }
      end
      it do
        should contain_mobileconfig('managedmac.portablehomes.alacarte').with_ensure('absent')
      end
    end

  end

  context "when $enable == $macosx_productversion_major" do
    let :facts do
      {
        :macosx_productversion_major => '10.10',
      }
    end

    let(:params) do
      { :enable => '10.10' }
    end
    it do
      should contain_mobileconfig('managedmac.portablehomes.alacarte').with_ensure('present')
    end
  end

  context "when $enable != $macosx_productversion_major" do
    let :facts do
      {
        :macosx_productversion_major => '10.9',
      }
    end

    let(:params) do
      { :enable => '10.10' }
    end
    it do
      should contain_mobileconfig('managedmac.portablehomes.alacarte').with_ensure('absent')
    end
  end

  context "when $enable is passed a BAD param" do
    let(:params) do
      { :enable => 'Whimmy wham wham wozzle!' }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /does not match/)
    end
  end

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