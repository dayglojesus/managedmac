require 'spec_helper'

describe 'managedmac::screensharing', :type => 'class' do


  context "when $enable == undef" do
    let(:params) do
      { :enable => '', }
    end
    it { should_not contain_macgroup('com.apple.access_screensharing') }
    it { should_not contain_service('com.apple.screensharing') }
  end

  context "when $enable != undef" do

    context "when $enable == false" do
      let(:params) do
        { :enable => false, }
      end
      it do
        should contain_macgroup(
          'com.apple.access_screensharing').with_nestedgroups(
            ['ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050']
          )
      end
      it do
        should contain_service('com.apple.screensharing').with_ensure(false)
      end
    end

    context "when $enable == true" do
      let(:params) do
        { :enable => true, }
      end
      it do
        should contain_macgroup(
          'com.apple.access_screensharing').with_nestedgroups(
            ['ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050']
          )
      end
      it do
        should contain_service('com.apple.screensharing').with_ensure(true)
      end

      context "when users are defined" do
        let(:params) do
          { :enable => true, :users => ['foo', 'bar', 'bar'] }
        end
        it do
          should contain_macgroup(
            'com.apple.access_screensharing').with_users(
              ['foo', 'bar', 'bar']
            )
        end
        it do
          should contain_service('com.apple.screensharing').with_ensure(true)
        end
      end

      context "when groups are defined" do
        let(:params) do
          { :enable => true, :groups => ['foo', 'bar', 'bar'] }
        end
        it do
          should contain_macgroup(
            'com.apple.access_screensharing').with_nestedgroups(
              ['foo', 'bar', 'bar']
            )
        end
        it do
          should contain_service('com.apple.screensharing').with_ensure(true)
        end
      end

    end

  end

end