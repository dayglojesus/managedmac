require 'spec_helper'

describe 'managedmac::energysaver', :type => 'class' do

  context "when $desktop is not a Hash" do
    let(:params) do
      { :desktop => "Icanhazstring", }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $portable is not a Hash" do
    let(:params) do
      { :desktop => "Icanhazstring", }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $desktop is an empty Hash" do
    let(:params) do
      { :desktop => {}, }
    end
    it do
      should contain_mobileconfig('managedmac.energysaver.alacarte').with_ensure('absent')
    end
  end

  context "when $portable is an empty Hash" do
    let(:params) do
      { :portable => {}, }
    end
    it do
      should contain_mobileconfig('managedmac.energysaver.alacarte').with_ensure('absent')
    end
  end

  context "when $desktop is NOT an empty Hash" do
    let(:params) do
      { :desktop => options_energysaver['desktop'], }
    end
    it do
      should contain_mobileconfig('managedmac.energysaver.alacarte').with_ensure('present')
    end
  end

  context "when $portable is NOT an empty Hash" do
    let(:params) do
      { :portable => options_energysaver['portable'], }
    end
    it do
      should contain_mobileconfig('managedmac.energysaver.alacarte').with_ensure('present')
    end
  end

end
