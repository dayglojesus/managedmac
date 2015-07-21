require 'spec_helper'

describe 'managedmac::softwareupdate', :type => 'class' do

  let(:mobileconfig_name)   { 'managedmac.softwareupdate.alacarte' }
  let(:asus_plist)          { '/Library/Preferences/com.apple.SoftwareUpdate.plist' }

  context "when setting $catalog_url" do
    context "when undef" do
      let(:params) do
        { :catalog_url  => '' }
      end
      it { should contain_mobileconfig(mobileconfig_name)\
        .with_ensure('absent') }
    end
    context "when not a URL-like" do
      let(:params) do
        { :catalog_url => 'foo' }
      end
      it { should raise_error(Puppet::Error, /does not match/) }
    end
    context "when a URL" do
      let(:params) do
        { :catalog_url => 'http://foo.bar.com/foo.sucatalog' }
      end
      it { should contain_mobileconfig(mobileconfig_name)\
        .with_ensure('present') }
    end
  end

  context "when setting $allow_pre_release_installation" do
    context "when undef" do
      let(:params) do
        { :allow_pre_release_installation  => '' }
      end
      it { should contain_mobileconfig(mobileconfig_name)\
        .with_ensure('absent') }
    end
    context "when not Boolean" do
      let(:params) do
        { :allow_pre_release_installation => 'foo' }
      end
      it { should raise_error(Puppet::Error, /not a boolean/) }
    end
    context "when a Boolean" do
      let(:params) do
        { :allow_pre_release_installation => false }
      end
      it { should contain_mobileconfig(mobileconfig_name)\
        .with_ensure('present') }
    end
  end

  context "when setting $automatic_update_check" do
    context "when a undef" do
      let(:params) do
        { :automatic_update_check => '' }
      end
      it { should_not contain_propertylist(asus_plist) }
    end
    context "when not a boolean" do
      let(:params) do
        { :automatic_update_check => 'foo' }
      end
      it { should raise_error(Puppet::Error, /not a boolean/) }
    end
    context "when a boolean" do
      let(:params) do
        { :automatic_update_check => true }
      end
      it { should contain_propertylist(asus_plist)
        .with_ensure('present') }
    end
  end

  context "when setting $automatic_download" do
    context "when a undef" do
      let(:params) do
        { :automatic_download => '' }
      end
      it { should_not contain_propertylist(asus_plist) }
    end
    context "when not a boolean" do
      let(:params) do
        { :automatic_download => 'foo' }
      end
      it { should raise_error(Puppet::Error, /not a boolean/) }
    end
    context "when a boolean" do
      let(:params) do
        { :automatic_download => true }
      end
      it { should contain_propertylist(asus_plist)
        .with_ensure('present') }
    end
  end

  context "when setting $config_data_install" do
    context "when a undef" do
      let(:params) do
        { :config_data_install => '' }
      end
      it { should_not contain_propertylist(asus_plist) }
    end
    context "when not a boolean" do
      let(:params) do
        { :config_data_install => 'foo' }
      end
      it { should raise_error(Puppet::Error, /not a boolean/) }
    end
    context "when a boolean" do
      let(:params) do
        { :config_data_install => true }
      end
      it { should contain_propertylist(asus_plist)
        .with_ensure('present') }
    end
  end

  context "when setting $critical_update_install" do
    context "when a undef" do
      let(:params) do
        { :critical_update_install => '' }
      end
      it { should_not contain_propertylist(asus_plist) }
    end
    context "when not a boolean" do
      let(:params) do
        { :critical_update_install => 'foo' }
      end
      it { should raise_error(Puppet::Error, /not a boolean/) }
    end
    context "when a boolean" do
      let(:params) do
        { :critical_update_install => true }
      end
      it { should contain_propertylist(asus_plist)
        .with_ensure('present') }
    end
  end

  os_specific_mappings = {
    '10.9'  => '/Library/Preferences/com.apple.storeagent.plist',
    '10.10' => '/Library/Preferences/com.apple.commerce.plist',
  }

  os_specific_mappings.each do |os_rev, plist|

    context "on #{os_rev}" do

      let(:facts)         { { :macosx_productversion_major => os_rev } }
      let(:store_plist)   { plist }

      describe '$auto_update_apps' do
        context "when undef" do
          let(:params) do
            { :auto_update_apps => '' }
          end
          it { should_not contain_propertylist(store_plist) }
        end
        context "when not a boolean" do
          let(:params) do
            { :auto_update_apps => 'foo' }
          end
          it { should raise_error(Puppet::Error, /not a boolean/) }
        end
        context "when a boolean" do
          let(:params) do
            { :auto_update_apps => true }
          end
          it { should contain_propertylist(store_plist)
            .with_ensure('present') }
        end
      end

      if os_rev == '10.9'

        describe '$auto_update_restart_required' do
          let(:params) do
            { :auto_update_restart_required => true }
          end
          it { should_not contain_propertylist(store_plist) }
        end

      else

        describe '$auto_update_restart_required' do
          context "when undef" do
            let(:params) do
              { :auto_update_restart_required => '' }
            end
            it { should_not contain_propertylist(store_plist) }
          end
          context "when not a boolean" do
            let(:params) do
              { :auto_update_restart_required => 'foo' }
            end
            it { should raise_error(Puppet::Error, /not a boolean/) }
          end
          context "when a boolean" do
            let(:params) do
              { :auto_update_restart_required => true }
            end
            it { should contain_propertylist(store_plist)
              .with_ensure('present') }
          end
        end

      end

    end

  end

end
