require 'spec_helper'

describe 'mmv3', :type => 'class' do
  
  # mmv3 is for Darwin and more specfically, macosx_productversion_major >= 10.9
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
      expect { should compile }.to raise_error(Puppet::Error, /unsupported osfamily/)
    end
  end
  
end