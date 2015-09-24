require 'spec_helper'

describe "managedmac::propertylists", :type => 'class' do

  context "when $files is invalid" do
    let(:params) do
      { :files => 'This is not a Hash.' }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $defaults is invalid" do
    let(:params) do
      {
        :files => { :fake => 'data' },
        :defaults => 'This is not a Hash.',
      }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $payloads is empty" do
    let(:params) do
      { :files => {} }
    end
    specify do
      should_not contain_propertylist
    end
  end

  context "when $payloads contains invalid data" do
    let(:params) do
      the_data = content_propertylists.merge({ 'bad_data' => 'Not a Hash.'})
      { :files => the_data }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $payloads is VALID" do
    let(:params) do
      {
        :defaults => { 'owner' => 'root', 'group' => 'admin' },
        :files => content_propertylists,
      }
    end
    specify do
      should contain_propertylist('/path/to/a/file.plist')\
        .with_content(/A string/)
    end
    specify do
      should contain_propertylist('/path/to/b/file.plist')\
        .with_content(/foo/)
    end
  end

end