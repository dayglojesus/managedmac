require 'spec_helper'

describe 'managedmac::loginwindow', :type => 'class' do
  
  # Test ensurability
  context "when $ensure => 'absent'" do
    let(:params) do
      { :ensure => 'absent' }
    end
    
    it { should contain_mobileconfig('managedmac.loginwindow.alacarte')\
      .with_ensure('absent') }
  end  
  
  context "when $ensure is invalid" do
    let(:params) do
      { :ensure => 'whatever' }
    end
    
    specify do 
      expect { 
        should compile 
      }.to raise_error(Puppet::Error, /Parameter Error/)
    end
  end

  context "when the banner_text param is not a String" do
    let(:params) do
      { :banner_text => ['This is an Array'] }
    end
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  context "when the show_full_name param is not a Boolean" do
    let(:params) do
      { :show_full_name => ['This is an Array'] }
    end
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  context "when the show_buttons param is not a Boolean" do
    let(:params) do
      { :show_buttons => ['This is an Array'] }
    end
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  context "when the options param is not a Hash" do
    message = 'This is a loginwindow.'
    let(:params) do
      { :options => message }
    end
    
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  context "when all the params are empty" do
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  context "when there is at least one param specified" do
    let(:params) do
      { :show_buttons => true }
    end
    
    it { should contain_mobileconfig('managedmac.loginwindow.alacarte')\
      .with_content(/RestartDisabled.*true/) }
  end
  
  context "when the options param is a Hash with at least one key" do
    message = 'This is a loginwindow.'
    let(:params) do
      { :options => { 'BannerText' => message } }
    end
    
    it { should contain_mobileconfig('managedmac.loginwindow.alacarte')\
      .with_content(/#{message}/) }
  end
  
  context "when params and options Hash contain the same keys" do
    options_message = 'OPTIONS: I am a loginwindow.'
    params_message  = 'PARAMS:  I am a loginwindow.'
    let(:params) do
      { 
        :banner_text => params_message,
        :options     => { 'BannerText' => options_message } 
      }
    end
    it { should contain_mobileconfig('managedmac.loginwindow.alacarte')\
      .with_content(/#{params_message}/) }
  end
  
end