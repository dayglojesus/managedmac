require 'spec_helper'

describe "managedmac::execs", :type => 'class' do

  context "when $commands is invalid" do
    let(:params) do
      { :commands => 'This is not a Hash.' }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $defaults is invalid" do
    let(:params) do
      {
        :commands => { :fake => 'data' },
        :defaults => 'This is not a Hash.',
      }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $commands is empty" do
    let(:params) do
      { :commands => {} }
    end
    specify { should_not contain_exec }
  end

  context "when $commands contains invalid data" do
    let(:params) do
      the_data = execs_cmds.merge({ 'bad_data' => 'Not a Hash.'})
      { :commands => the_data }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $commands is VALID" do
    let(:params) do
      { :commands => execs_cmds }
    end
    it do
      should contain_exec('who_dump').with(
        'command' => '/usr/bin/who > /tmp/who.dump',
      )
    end
    it do
      should contain_exec('ps_dump').with(
        'command' => '/bin/ps aux > /tmp/ps.dump',
      )
    end
  end

end