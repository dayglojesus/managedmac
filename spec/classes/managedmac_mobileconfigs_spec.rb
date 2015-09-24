require 'spec_helper'

describe "managedmac::mobileconfigs", :type => 'class' do

  context "when $payloads is invalid" do
    let(:params) do
      { :payloads => 'This is not a Hash.' }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $defaults is invalid" do
    let(:params) do
      {
        :payloads => { :fake => 'data' },
        :defaults => 'This is not a Hash.',
      }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $payloads is empty" do
    let(:params) do
      { :payloads => {} }
    end
    specify do
      should_not contain_mobileconfig
    end
  end

  context "when $payloads contains invalid data" do
    let(:params) do
      the_data = mobileconfigs_payloads.merge({ 'bad_data' => 'Not a Hash.'})
      { :payloads => the_data }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $payloads is VALID" do
    let(:params) do
      {
        :defaults => { 'organization' => 'Puppet Labs'},
        :payloads => mobileconfigs_payloads,
      }
    end
    specify do
      should contain_mobileconfig('managedmac.dock.alacarte')\
        .with_content(/tilesize.*128/)
    end
    specify do
      should contain_mobileconfig('managedmac.dock.alacarte')\
        .with_organization('Puppet Labs')
    end
  end

end