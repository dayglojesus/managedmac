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
  
  context "when the options param is not a Hash" do
    message = 'This is a loginwindow.'
    let(:params) do
      { :options => message }
    end
    
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  context "when the options param is empty" do
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  context "when the options param is a Hash with at least one key" do
    message = 'This is a loginwindow.'
    let(:params) do
      { :options => { 'BannerText' => message } }
    end
    
    it { should contain_mobileconfig('managedmac.loginwindow.alacarte')\
      .with_content(/#{message}/) }
  end
  
end