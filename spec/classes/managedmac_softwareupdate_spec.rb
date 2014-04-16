require 'spec_helper'

describe 'managedmac::softwareupdate', :type => 'class' do
  
  context "when it is passed no params" do
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  # Test ensurability
  context "when $ensure => 'absent'" do
    let(:params) do
      { :ensure  => 'absent' }
    end
    
    it { should contain_mobileconfig('managedmac.softwareupdate.alacarte')\
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
  
  context "when $catalog_url is valid URL" do
    let(:params) do
      { :catalog_url => 'http://swscan.apple.com/content/catalogs/index-1.sucatalog' }
    end
    
    specify do
      should contain_mobileconfig('managedmac.softwareupdate.alacarte').\
        with_content(/CatalogURL.*swscan\.apple\.com.*/)
    end
  end
  
  context "when $catalog_url is INVALID" do
    let(:params) do
      { :catalog_url => 'swscan.apple.com/content/catalogs/index-1.sucatalog' }
    end
    
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  context "when it is passed a BAD $options" do
    let(:params) do
      { :options => "Icanhazstring", }
    end
    
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  context "when passed a Hash parameter with valid options" do
    
    let(:params) do
      { :options => options_softwareupdate, }
    end
    
    specify do
      should contain_mobileconfig('managedmac.softwareupdate.alacarte').\
        with_content(/CatalogURL.*catalogs\.sucatlog/)
    end
        
    it { should compile.with_all_deps }
  end
  
  context "when params and options Hash contain the same keys" do
    options_catalog_url = 'http://swscan.apple.com/content/catalogs/index-1.sucatalog'
    params_catalog_url  = 'http://swscan.apple.com/content/catalogs/index-2.sucatalog'
    let(:params) do
      { 
        :catalog_url => params_catalog_url,
        :options     => { 'CatalogURL' => options_catalog_url } 
      }
    end
    
    it { should contain_mobileconfig('managedmac.softwareupdate.alacarte')\
      .with_content(/#{params_catalog_url}/) }
  end
  
end