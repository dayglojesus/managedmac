require 'spec_helper'

describe 'mmv3::ntp', :type => 'class' do

  # The remainder of our specs will go inside this context block
  context "on a supported operating system and product version" do
    # On our target platform, we should have green lights.
    let :facts do
      {
        :osfamily => 'Darwin',
        :macosx_productversion_major => '10.9',
      }
    end
    
    it { should compile.with_all_deps }
    
  end
  
end