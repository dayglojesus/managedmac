require 'spec_helper'

describe 'managedmac::filevault', :type => 'class' do

  context "when passed no params" do
    it do
      should contain_mobileconfig('managedmac.filevault.alacarte').with_ensure('absent')
    end
  end

  context "when $enable == true" do

    context "when $output_path has BAD param" do
      let(:params) do
        { :enable => true, :output_path => 'some_file' }
      end
      specify do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /not an absolute path/)
      end
    end

    context "when $defer has a BAD param" do
      let(:params) do
        { :enable => true, :defer => 'a_string' }
      end
      specify do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /not a boolean/)
      end
    end

    context "when the params are GOOD" do
      let(:params) do
        { :enable => true }
      end
      it do
        should contain_mobileconfig('managedmac.filevault.alacarte').with_ensure('present')
      end
    end

  end

end