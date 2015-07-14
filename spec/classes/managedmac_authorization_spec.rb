require 'spec_helper'

describe "managedmac::authorization", :type => 'class' do

  context "when passed no params" do
    it { should compile.with_all_deps }
  end

  context "when passed BAD params" do
    let(:params) do
      { :allow_timemachine => 'This is not a Bool.' }
    end
    it { should raise_error(Puppet::Error)  }
  end

  context "when at least one parameter == true" do
    let(:params) do
      { :allow_energysaver => false,
        :allow_datetime => false,
        :allow_timemachine => true,
      }
    end

    it do
      should contain_macauthdb('system.preferences').with(
        'group' => 'everyone',
      )
    end
  end

  context "when $allow_energysaver == true" do
    let(:params) do
      { :allow_energysaver => true,
        :allow_datetime => false,
        :allow_timemachine => false,
      }
    end

    it do
      should contain_macauthdb('system.preferences.energysaver').with(
        'group' => 'everyone',)
    end

    it do
      should contain_macauthdb('system.preferences.datetime').with(
        'group' => 'admin',)
    end

    it do
      should contain_macauthdb('system.preferences.timemachine').with(
        'group' => 'admin',)
    end
  end

  context "when $allow_datetime == true" do
    let(:params) do
      { :allow_energysaver => false,
        :allow_datetime => true,
        :allow_timemachine => false,
      }
    end

    it do
      should contain_macauthdb('system.preferences.energysaver').with(
        'group' => 'admin',)
    end

    it do
      should contain_macauthdb('system.preferences.datetime').with(
        'group' => 'everyone',)
    end

    it do
      should contain_macauthdb('system.preferences.timemachine').with(
        'group' => 'admin',)
    end
  end

  context "when $allow_timemachine == true" do
    let(:params) do
      { :allow_energysaver => false,
        :allow_datetime => false,
        :allow_timemachine => true,
      }
    end

    it do
      should contain_macauthdb('system.preferences.energysaver').with(
        'group' => 'admin',)
    end

    it do
      should contain_macauthdb('system.preferences.datetime').with(
        'group' => 'admin',)
    end

    it do
      should contain_macauthdb('system.preferences.timemachine').with(
        'group' => 'everyone',)
    end
  end

  context "when $allow_printers == true" do
    let(:params) do
      { :allow_energysaver => false,
        :allow_datetime => false,
        :allow_printers => true,
      }
    end

    it do
      should contain_macauthdb('system.preferences.energysaver').with(
        'group' => 'admin',)
    end

    it do
      should contain_macauthdb('system.preferences.datetime').with(
        'group' => 'admin',)
    end

    it do
      should contain_macauthdb('system.preferences.printing').with(
        'group' => 'everyone',)
    end
  end

  context "when $allow_dvd_setregion_initial == true" do
    let(:params) do
      { :allow_energysaver => false,
        :allow_datetime => false,
        :allow_dvd_setregion_initial => true,
      }
    end

    it do
      should contain_macauthdb('system.preferences.energysaver').with(
        'group' => 'admin',)
    end

    it do
      should contain_macauthdb('system.preferences.datetime').with(
        'group' => 'admin',)
    end

    it do
      should contain_macauthdb('system.device.dvd.setregion.initial').with(
        'auth_class' => 'user',)
    end
  end

end
