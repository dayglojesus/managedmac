require 'spec_helper'

describe 'managedmac::softwareupdate', :type => 'class' do
  
  context "when it is passed no params" do
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end
  
  context "when it is passed a BAD param" do
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
  
end