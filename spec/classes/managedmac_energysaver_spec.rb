require 'spec_helper'

describe 'managedmac::energysaver', :type => 'class' do
  
  context "when it is passed no params" do
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  context "when it is passed a BAD param" do
    let(:params) do
      { :options => "Icanhazstring", }
    end
    
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  # Test ensurability
  context "when $ensure => 'absent'" do
    
    let(:params) do
      { :ensure  => 'absent' }
    end
    
    it { should contain_mobileconfig('managedmac.energysaver.alacarte')\
      .with_ensure('absent') }
  end
  
  context "when the machine_type is uknown" do
    let(:facts) { { :productname => 'FOO', } }
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
    
  context "when the machine is a portable" do
    
    let(:facts) { { :productname => 'MacBook', } }
    
    context "when there are no portable options set" do
      let(:params) do
        { 
          :options => { 'desktop' => {} }
        }
      end
      specify { expect { should compile }.to raise_error(Puppet::Error) }
    end
    
    context "when portable options are set" do
      let(:params) do
        { 
          :options => { 'portable' => {} }
        }
      end
      specify do
        should contain_mobileconfig('managedmac.energysaver.alacarte')
      end
    end
    
    context "when ACPower options are invalid" do      
      let(:params) do
        { 
          :options => { 
            'portable' => { 'ACPower' => 'I should be a Hash' }
          }
        }
      end
      specify { expect { should compile }.to raise_error(Puppet::Error) }
    end
    
    context "when ACPower options are valid" do
      let(:params) do
        { 
          :options => options_energysaver
        }
      end
      specify do
        should contain_mobileconfig('managedmac.energysaver.alacarte')\
        .with_content(/ACPower.*/)
      end
    end
    
    context "when BatteryPower options are invalid" do      
      let(:params) do
        { 
          :options => { 
            'portable' => { 'BatteryPower' => 'I should be a Hash' }
          }
        }
      end
      specify { expect { should compile }.to raise_error(Puppet::Error) }
    end
    
    context "when BatteryPower options are valid" do
      let(:params) do
        { 
          :options => options_energysaver
        }
      end
      specify do
        should contain_mobileconfig('managedmac.energysaver.alacarte')\
        .with_content(/BatteryPower.*/)
      end
    end
    
  end
  
  context "when the machine is a desktop" do
    let(:facts) { { :productname => 'iMac', } }
    
    context "when there are no desktop options set" do
      let(:params) do
        { 
          :options => { 'portable' => {} }
        }
      end
      specify { expect { should compile }.to raise_error(Puppet::Error) }
    end
    
    context "when desktop options are set" do
      let(:params) do
        { 
          :options => { 'desktop' => {} }
        }
      end
      specify do
        should contain_mobileconfig('managedmac.energysaver.alacarte')
      end
    end
    
    context "when ACPower options are invalid" do      
      let(:params) do
        { 
          :options => { 
            'desktop' => { 'ACPower' => 'I should be a Hash' }
          }
        }
      end
      specify { expect { should compile }.to raise_error(Puppet::Error) }
    end
    
    context "when ACPower options are valid" do
      let(:params) do
        { 
          :options => options_energysaver
        }
      end
      specify do
        should contain_mobileconfig('managedmac.energysaver.alacarte')\
        .with_content(/ACPower.*/)
      end
    end
    
    context "when Schedule options are invalid" do      
      let(:params) do
        { 
          :options => { 
            'desktop' => { 'Schedule' => 'I should be a Hash' }
          }
        }
      end
      specify { expect { should compile }.to raise_error(Puppet::Error) }
    end
    
    context "when Schedule options are valid" do
      let(:params) do
        { 
          :options => options_energysaver
        }
      end
      specify do
        should contain_mobileconfig('managedmac.energysaver.alacarte')\
        .with_content(/RepeatingPowerOff.*/)
      end
    end
    
  end
  
end