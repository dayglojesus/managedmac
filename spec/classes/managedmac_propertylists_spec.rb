require 'spec_helper'

describe "managedmac::propertylists", :type => 'class' do

  context "when passed no params" do
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end

  context "when $propertylists is invalid" do
    let(:params) do
      { :propertylists => 'This is not a Hash.' }
    end
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end

  context "when $defaults is invalid" do
    let(:params) do
      {
        :propertylists => { :fake => 'data' },
        :defaults => 'This is not a Hash.',
      }
    end
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end

  context "when $payloads is empty" do
    let(:params) do
      { :propertylists => {} }
    end
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end

  context "when $payloads contains invalid data" do
    let(:params) do
      the_data = content_propertylists.merge({ 'bad_data' => 'Not a Hash.'})
      { :propertylists => the_data }
    end
    specify { expect { should compile }.to raise_error(Puppet::Error) }
  end

  context "when $payloads is VALID" do
    let(:params) do
      {
        :defaults => { 'owner' => 'root', 'group' => 'admin' },
        :propertylists => content_propertylists,
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