require 'spec_helper'

describe 'managedmac', :type => 'class' do

  # managedmac is for Darwin and more specfically, macosx_productversion_major >= 10.9
  context "on an unsupported operating system" do
    # setup some variables
    unsupported_examples = ['Debian', 'RedHat', 'CentOS', 'Windows', 'OpenSuSE', 'SuSE']
    random_os_family = unsupported_examples[rand(unsupported_examples.length - 1)]
    # fabricate a Facter fact
    let :facts do
      { :osfamily => random_os_family }
    end
    # Finally, test the code
    it "should raise a Puppet:Error" do
      should raise_error(Puppet::Error, /unsupported osfamily/)
    end
  end

  context "on an unsupported product version" do
    # here we setup two fake facts:
    # yes, we are Darwin
    # no, we are not Mavericks (10.9)
    let :facts do
      {
        :osfamily => 'Darwin',
        :macosx_productversion_major => '10.8',
      }
    end
    # Test the Puppet fail directive
    it "should raise a Puppet:Error" do
      should raise_error(Puppet::Error, /unsupported product version/)
    end
  end

  # The remainder of our specs will go inside this context block
  context "on a supported operating system and product version" do
    # On our target platform, we should have green lights.
    let :facts do
      {
        :osfamily => 'Darwin',
        :macosx_productversion_major => '10.10',
      }
    end

    it { should contain_class('managedmac::ntp') }
    it { should contain_class('managedmac::activedirectory') }
    it { should contain_class('managedmac::security') }
    it { should contain_class('managedmac::desktop') }
    it { should contain_class('managedmac::mcx') }
    it { should contain_class('managedmac::filevault') }
    it { should contain_class('managedmac::loginwindow') }
    it { should contain_class('managedmac::softwareupdate') }
    it { should contain_class('managedmac::authorization') }
    it { should contain_class('managedmac::energysaver') }
    it { should contain_class('managedmac::portablehomes') }
    it { should contain_class('managedmac::mounts') }
    it { should contain_class('managedmac::loginhook') }
    it { should contain_class('managedmac::logouthook') }
    it { should contain_class('managedmac::sshd') }
    it { should contain_class('managedmac::remotemanagement') }
    it { should contain_class('managedmac::screensharing') }
    it { should contain_class('managedmac::mobileconfigs') }
    it { should contain_class('managedmac::propertylists') }
    it { should contain_class('managedmac::execs') }
    it { should contain_class('managedmac::files') }
    it { should contain_class('managedmac::users') }
    it { should contain_class('managedmac::groups') }
    it { should contain_class('managedmac::cron') }

  end

end
