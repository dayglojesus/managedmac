require 'spec_helper'

describe 'managedmac::remotemanagement', :type => 'class' do

  context "when none of the params is set" do
    it do
      should_not contain_remotemanagement('apple_remote_desktop')
    end
  end

  context "when passed a BAD param" do
    let(:params) do
      {
        :enable => true,
        :allow_all_users => 'a string',
      }
    end
    it { should raise_error(Puppet::Error, /not a boolean/) }
  end

  context "when $enable == false" do
    let(:params) do
      { :enable => false }
    end
    it do
      should contain_remotemanagement('apple_remote_desktop').with_ensure('stopped')
    end
  end

  context "when $enable == true" do
    let(:params) do
      { :enable => true  }
    end
    it do
      should contain_remotemanagement('apple_remote_desktop').with_ensure('running')
    end
  end

end