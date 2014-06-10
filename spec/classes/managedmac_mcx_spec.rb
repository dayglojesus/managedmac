require 'spec_helper'

describe 'managedmac::mcx', :type => 'class' do

  it { should contain_exec('refresh_mcx') }

  context "when passed a BAD param" do
    let(:params) do
      { :bluetooth => 'foo' }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /not a boolean/)
    end
  end

  context "when $bluetooth == on" do
    let(:params) do
      { :bluetooth => 'on' }
    end
    it do
      should contain_computer('mcx_puppet').with_ensure(
      'present')
    end
    it do
      should contain_mcx('/Computers/mcx_puppet').with_content(
        /DisableBluetooth/)
    end
  end

  context "when $bluetooth == off" do
    let(:params) do
      { :bluetooth => 'off' }
    end
    it do
      should contain_computer('mcx_puppet').with_ensure(
      'present')
    end
    it do
      should contain_mcx('/Computers/mcx_puppet').with_content(
        /DisableBluetooth/)
    end
  end

  context "when $bluetooth == enable" do
    let(:params) do
      { :bluetooth => 'enable' }
    end
    it do
      should contain_computer('mcx_puppet').with_ensure(
      'present')
    end
    it do
      should contain_mcx('/Computers/mcx_puppet').with_content(
        /DisableBluetooth/)
    end
  end

  context "when $bluetooth == disable" do
    let(:params) do
      { :bluetooth => 'disable' }
    end
    it do
      should contain_computer('mcx_puppet').with_ensure(
      'present')
    end
    it do
      should contain_mcx('/Computers/mcx_puppet').with_content(
        /DisableBluetooth/)
    end
  end

  context "when $bluetooth == true" do
    let(:params) do
      { :bluetooth => true }
    end
    it do
      should contain_computer('mcx_puppet').with_ensure(
      'present')
    end
    it do
      should contain_mcx('/Computers/mcx_puppet').with_content(
        /DisableBluetooth/)
    end
  end

  context "when $bluetooth == false" do
    let(:params) do
      { :bluetooth => false }
    end
    it do
      should contain_computer('mcx_puppet').with_ensure(
      'present')
    end
    it do
      should contain_mcx('/Computers/mcx_puppet').with_content(
        /DisableBluetooth/)
    end
  end

  context "when $wifi == true" do
    let(:params) do
      { :wifi => true }
    end
    it do
      should contain_computer('mcx_puppet').with_ensure(
      'present')
    end
    it do
      should contain_mcx('/Computers/mcx_puppet').with_content(
        /DisableAirPort/)
    end
  end

  context "when $wifi == ''" do
    let(:params) do
      { :wifi => '' }
    end
    it do
      should contain_computer('mcx_puppet').with_ensure(
      'absent')
    end
    it do
      should contain_mcx('/Computers/mcx_puppet').with_content('')
    end
  end

  context "when $bluetooth == ''" do
    let(:params) do
      { :bluetooth => '' }
    end
    it do
      should contain_computer('mcx_puppet').with_ensure(
      'absent')
    end
    it do
      should contain_mcx('/Computers/mcx_puppet').with_content('')
    end
  end

  context "when $logintitems are defined" do
    let(:params) do
      { :loginitems => ['/path/to/some/file'] }
    end
    it do
      should contain_computer('mcx_puppet').with_ensure(
      'present')
    end
    it do
      should contain_mcx('/Computers/mcx_puppet').with_content(
        /\/path\/to\/some\/file/)
    end
  end

  context "when NO $logintitems are defined" do
    let(:params) do
      { :loginitems => [] }
    end
    it do
      should contain_computer('mcx_puppet').with_ensure(
      'absent')
    end
    it do
      should contain_mcx('/Computers/mcx_puppet').with_content('')
    end
  end

  context "when $logintitems is not an Array" do
    let(:params) do
      { :loginitems => 'foo' }
    end
    specify do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /not an Array/)
    end
  end

end
