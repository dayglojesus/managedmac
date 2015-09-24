require 'spec_helper'

describe 'managedmac::sshd', :type => 'class' do

  context "when $enable == undef" do
    let(:params) do
      { :enable => '', }
    end
    it { should_not contain_macgroup('com.apple.access_ssh-disabled') }
    it { should_not contain_macgroup('com.apple.access_ssh') }
    it { should_not contain_service('com.openssh.sshd') }
    it { should_not contain_file('sshd_config') }
    it { should_not contain_file('sshd_banner') }
  end

  context "when $enable != undef" do

    context "when $enable == false" do
      let(:params) do
        { :enable => false, }
      end
      it do
        should contain_macgroup(
          'com.apple.access_ssh-disabled').with_ensure('absent')
      end
      it do
        should contain_macgroup(
          'com.apple.access_ssh').with_nestedgroups(
            ['ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050']
          )
      end
      it do
        should contain_service('com.openssh.sshd').with_ensure(false)
      end
    end

    context "when $enable == true" do
      let(:params) do
        { :enable => true, }
      end
      it do
        should contain_macgroup(
          'com.apple.access_ssh-disabled').with_ensure('absent')
      end
      it do
        should contain_macgroup(
          'com.apple.access_ssh').with_nestedgroups(
            ['ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050']
          )
      end
      it do
        should contain_service('com.openssh.sshd').with_ensure(true)
      end

      context "when users are defined" do
        let(:params) do
          { :enable => true, :users => ['foo', 'bar', 'bar'] }
        end
        it do
          should contain_macgroup(
            'com.apple.access_ssh').with_users(
              ['foo', 'bar', 'bar']
            )
        end
        it do
          should contain_service('com.openssh.sshd').with_ensure(true)
        end
      end

      context "when groups are defined" do
        let(:params) do
          { :enable => true, :groups => ['foo', 'bar', 'bar'] }
        end
        it do
          should contain_macgroup(
            'com.apple.access_ssh').with_nestedgroups(
              ['foo', 'bar', 'bar']
            )
        end
        it do
          should contain_service('com.openssh.sshd').with_ensure(true)
        end
      end

      context "when sshd_config is defined" do
        let(:params) do
          {
            :enable      => true,
            :sshd_config => 'puppet:///modules/mmv2/services/sshd/sshd_config'
          }
        end
        it do
          should contain_file('sshd_config').with_ensure('file')
        end
        it do
          should contain_service('com.openssh.sshd').with_ensure(true)
        end
      end

      context "when sshd_banner is defined" do
        let(:params) do
          {
            :enable      => true,
            :sshd_banner => 'puppet:///modules/mmv2/services/sshd/sshd_banner'
          }
        end
        it do
          should contain_file('sshd_banner').with_ensure('file')
        end
        it do
          should contain_service('com.openssh.sshd').with_ensure(true)
        end
      end

      context "when sshd_banner is a BAD path" do
        let(:params) do
          {
            :enable      => true,
            :sshd_banner => 'this is not valid'
          }
        end
        it { should raise_error(Puppet::Error, /does not match/) }
      end

    end

  end

end