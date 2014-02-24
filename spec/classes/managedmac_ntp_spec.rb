require 'spec_helper'

describe 'managedmac::ntp', :type => 'class' do

  # The remainder of our specs will go inside this context block
  context "on a supported operating system and product version" do
    # On our target platform, we should have green lights.
    let :facts do
      {
        :osfamily => 'Darwin',
        :macosx_productversion_major => '10.9',
      }
    end
    
    context "when it is passed no params" do
      specify { expect { should compile }.to raise_error(Puppet::Error) }
    end
    
    context "when it is passed a BAD param" do
      let :hiera_data do
        { 'managedmac::ntp::options' => "Icanhazstring" }
      end
      specify { expect { should compile }.to raise_error(Puppet::Error) }
    end
    
    context "when passed a Hash parameter" do
      hash = { 'servers' => ['time.apple.com', 'time1.google.com'], 
               'max_offset' => 120 }
      
      let :hiera_data do 
        { 'managedmac::ntp::options' => hash }
      end
      
      specify do
        should contain_file('ntp_conf').with 
        { 'content' => "time.apple.com\ntime1.google.com" }
      end
      
      specify do
        should contain_service("org.ntp.ntpd").with
        { 'ensure' => 'running', 'enable' => 'true'}
      end
      
      it { should compile.with_all_deps }
    end
    
  end
  
end