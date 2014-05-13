require 'spec_helper'

describe "managedmac::logouthook", :type => 'class' do

  context "when passed no params" do
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /Must pass enable/)
    end
  end

  context "when enable == true" do

    context "when $scripts is undefined" do
      let(:params) do
        { :enable => true }
      end

      it { should contain_managedmac__hook('logout').with(
        'enable'  => true,
        'scripts' => '/etc/logouthooks',
      )}
    end

    context "when scripts is defined" do
      the_scripts = '/Library/Logouthooks'
      let(:params) do
        { :enable => true, :scripts => the_scripts }
      end

      it { should contain_managedmac__hook('logout').with(
        'enable'  => true,
        'scripts' => the_scripts,
      )}
    end

  end

  context "when enable == false" do
    let(:params) do
      { :enable => false }
    end

    it { should contain_managedmac__hook('logout').with(
      'enable'  => false,
      'scripts' => '/etc/logouthooks',
    )}
  end

end