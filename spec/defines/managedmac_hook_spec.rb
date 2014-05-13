require 'spec_helper'

describe "managedmac::hook" do

  let(:title) { 'loginhook' }

  context "when passed no params" do

    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /Must pass type/)
    end

  end

  context "when enable == true" do

    context "when type is INVALID" do

      let(:params) { {:type => 'foo' } }

      specify do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /validate_re.*does not match/)
      end

    end

    context "when type is VALID" do

      let(:params) { {:type => 'login' } }

      specify do
        should contain_file('/etc/loginhooks').with(
          { 'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'wheel',
            'mode'   => '0750',
        })
      end

      specify do
        should contain_file('/etc/masterhooks').with(
          { 'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'wheel',
            'mode'   => '0750',
        })
      end

      specify do
        should contain_file('/etc/masterhooks/loginhook.rb').with(
          { 'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'wheel',
            'mode'   => '0750',
        })
      end

      it { should contain_exec('activate_hook') }

    end

  end

  context "when enable == false" do

    context "when type is INVALID" do

      let(:params) do
        { :type => 'foo', :enable => false }
      end

      specify do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /validate_re.*does not match/)
      end

    end

    context "when type is VALID" do

      let(:params) do
        { :type => 'login', :enable => false }
      end

      it { should_not contain_file('/etc/masterhooks').with(
        { 'ensure' => 'absent',}) }

      it { should contain_file('/etc/masterhooks/loginhook.rb').with(
        { 'ensure' => 'absent',}) }

      it { should contain_exec('deactivate_hook') }

    end

  end

end
