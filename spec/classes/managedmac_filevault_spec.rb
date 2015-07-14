require 'spec_helper'

describe 'managedmac::filevault', :type => 'class' do

  context "when $enable == false" do
    let(:params) do
      { :enable => false }
    end
    it do
      should contain_mobileconfig('managedmac.filevault.alacarte').with_ensure('absent')
    end
    it do
      should_not contain_exec('decrypt_the_disk')
    end
  end

  context "when $enable == false and $remove_fde and $::filevault_active == true" do
    let(:facts) { { :filevault_active => true, } }
    let(:params) do
      { :enable => false, :remove_fde => true }
    end
    it do
      should contain_mobileconfig('managedmac.filevault.alacarte').with_ensure('absent')
    end
    it do
      should contain_exec('decrypt_the_disk')
    end
  end

  context "when $enable == false and $remove_fde and $::filevault_active == false" do
    let(:facts) { { :filevault_active => false, } }
    let(:params) do
      { :enable => false, :remove_fde => true }
    end
    it do
      should contain_mobileconfig('managedmac.filevault.alacarte').with_ensure('absent')
    end
    it do
      should_not contain_exec('decrypt_the_disk')
    end
  end

  context "when $enable == true" do

    context "when $output_path has BAD param" do
      let(:params) do
        { :enable => true, :output_path => 'some_file' }
      end
      it { should raise_error(Puppet::Error, /not an absolute path/) }
    end

    context "when $use_recovery_key has a BAD param" do
      let(:params) do
        { :enable => true, :use_recovery_key => 'a_string' }
      end
      it { should raise_error(Puppet::Error, /not a boolean/) }
    end

    context "when the params are GOOD" do
      let(:params) do
        { :enable => true }
      end
      it do
        should contain_mobileconfig('managedmac.filevault.alacarte').with_ensure('present')
      end
    end

    context "when $use_keychain == true and $keychain_file is not set" do
      let(:params) do
        { :enable => true, :use_keychain => true, :keychain_file => '' }
      end
      it { should raise_error(Puppet::Error, /not an absolute path/) }
    end

    context "when $use_keychain == true and $keychain_file is a puppet path" do
      let(:params) do
        { :enable => true,
          :use_keychain => true,
          :keychain_file => 'puppet:///modules/somemodule/fvmi/FileVaultMaster.keychain'
        }
      end
      it do
        should contain_mobileconfig('managedmac.filevault.alacarte').with_ensure('present')
      end
      it do
        should contain_file('filevault_master_keychain')
      end
    end

    context "when $use_keychain == true and $keychain_file is local path" do
      let(:params) do
        { :enable => true,
          :use_keychain => true,
          :keychain_file => '/var/root/fvmi/FileVaultMaster.keychain'
        }
      end
      it do
        should contain_mobileconfig('managedmac.filevault.alacarte').with_ensure('present')
      end
      it do
        should contain_file('filevault_master_keychain')
      end
    end
  end

end