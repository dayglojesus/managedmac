require 'spec_helper'

describe "managedmac::cron", :type => 'class' do

  context "when $jobs is invalid" do
    let(:params) do
      { :jobs => 'This is not a Hash.' }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $defaults is invalid" do
    let(:params) do
      {
        :jobs => { :fake => 'data' },
        :defaults => 'This is not a Hash.',
      }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $jobs is empty" do
    let(:params) do
      { :jobs => {} }
    end
    specify { should_not contain_cron }
  end

  context "when $jobs contains invalid data" do
    let(:params) do
      the_data = cron_jobs.merge({ 'bad_data' => 'Not a Hash.'})
      { :jobs => the_data }
    end
    it { should raise_error(Puppet::Error) }
  end

  context "when $jobs is VALID" do
    let(:params) do
      { :jobs => cron_jobs }
    end
    it do
      should contain_cron('who_dump').with(
        'command' => '/usr/bin/who > /tmp/who.dump',
      )
    end
    it do
      should contain_cron('ps_dump').with(
        'command' => '/bin/ps aux > /tmp/ps.dump',
      )
    end
  end

end