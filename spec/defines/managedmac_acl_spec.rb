require 'spec_helper'

describe "managedmac::acl" do

  let(:title) { 'com.apple.access_loginwindow' }

  context "when passed no params" do
    it do
      should contain_macgroup('com.apple.access_loginwindow') \
        .with_users([])
    end
    it do
      should contain_macgroup('com.apple.access_loginwindow') \
        .with_nestedgroups([])
    end

    it { should compile.with_all_deps }
  end

  context "with users => $users" do
    let(:params) { {:users => ['foo', 'bar', 'baz'] } }
    it do
      should contain_macgroup('com.apple.access_loginwindow') \
        .with_users(['foo', 'bar', 'baz'])
    end
  end

  context "with groups => $groups" do
    let(:params) { {:groups => ['foo', 'bar', 'baz'] } }
    it do
      should contain_macgroup('com.apple.access_loginwindow') \
        .with_nestedgroups(['foo', 'bar', 'baz'])
    end
  end

  context "with state => disabled" do
    let(:params) { {:state => 'disabled'} }
    it do
      should contain_macgroup('com.apple.access_loginwindow') \
        .with_users([])
    end
    it do
      should contain_macgroup('com.apple.access_loginwindow') \
        .with_nestedgroups(["ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050"])
    end
  end

  context "with state => disabled AND destroy => true" do
    let(:params) { {:state => 'disabled', :destroy => true} }

    it do
      should contain_macgroup('com.apple.access_loginwindow') \
        .with_ensure('absent')
    end

    it do
      should_not contain_macgroup('com.apple.access_loginwindow') \
        .with_nestedgroups(["ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050"])
    end
  end

end
