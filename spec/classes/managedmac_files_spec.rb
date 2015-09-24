require 'spec_helper'

describe "managedmac::files", :type => 'class' do

  context "when $objects is invalid" do
    let(:params) do
      { :objects => 'This is not a Hash.' }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $defaults is invalid" do
    let(:params) do
      {
        :objects => { :fake => 'data' },
        :defaults => 'This is not a Hash.',
      }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $objects is empty" do
    let(:params) do
      { :objects => {} }
    end
    specify { should_not contain_file }
  end

  context "when $objects contains invalid data" do
    let(:params) do
      the_data = files_objects.merge({ 'bad_data' => 'Not a Hash.'})
      { :objects => the_data }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $objects is VALID" do
    let(:params) do
      { :objects => files_objects }
    end
    it do
      should contain_file('/path/to/a/file.txt').with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'admin',
        'mode'    => '0644',
        'content' => "This is an exmaple.",
      )
    end
    it do
      should contain_file('/path/to/a/directory').with(
        'ensure'  => 'directory',
        'owner'   => 'root',
        'group'   => 'admin',
        'mode'    => '0755',
      )
    end
  end

end