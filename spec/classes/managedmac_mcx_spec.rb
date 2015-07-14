require 'spec_helper'

describe 'managedmac::mcx', :type => 'class' do

  let(:facts) do
    { :macosx_productversion_major => "10.9" }
  end

  context "when passed NO params" do
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'absent')
    }
  end

  context "when passed ANY valid param" do
    let(:params) do
      { :bluetooth => 'on' }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'present')
    }
  end

  context "when passed a BAD param" do
    let(:params) do
      { :bluetooth => 'foo' }
    end
    it { should raise_error(Puppet::Error, /not a boolean/) }
  end

  context "when $bluetooth == on" do
    let(:params) do
      { :bluetooth => 'on' }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'present')
    }
  end

  context "when $bluetooth == off" do
    let(:params) do
      { :bluetooth => 'off' }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'present')
    }
  end

  context "when $bluetooth == enable" do
    let(:params) do
      { :bluetooth => 'enable' }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'present')
    }
  end

  context "when $bluetooth == disable" do
    let(:params) do
      { :bluetooth => 'disable' }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'present')
    }
  end

  context "when $bluetooth == true" do
    let(:params) do
      { :bluetooth => true }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'present')
    }
  end

  context "when $bluetooth == false" do
    let(:params) do
      { :bluetooth => false }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'present')
    }
  end

  context "when $wifi == true" do
    let(:params) do
      { :wifi => true }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'present')
    }
  end

  context "when $wifi == ''" do
    let(:params) do
      { :wifi => '' }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'absent')
    }
  end

  context "when $bluetooth == ''" do
    let(:params) do
      { :bluetooth => '' }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'absent')
    }
  end

  context "when $logintitems are defined" do
    let(:params) do
      { :loginitems => ['/path/to/some/file'] }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_content(
      /\/path\/to\/some\/file/)
    }
  end

  context "when NO $logintitems are defined" do
    let(:params) do
      { :loginitems => [] }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'absent')
    }
  end

  context "when $logintitems is not an Array" do
    let(:params) do
      { :loginitems => 'foo' }
    end
    it { should raise_error(Puppet::Error, /not an Array/) }
  end

  context "when $suppress_icloud_setup == false" do
    let(:params) do
      { :suppress_icloud_setup => false }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'absent')
    }
  end

  context "when $suppress_icloud_setup == true" do
    let(:params) do
      { :suppress_icloud_setup => true }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_content(
      /DidSeeCloudSetup/)
    }
  end

  context "$suppress_icloud_setup == true, NO $logintitems are defined" do
    let(:params) do
      {
        :suppress_icloud_setup => true,
        :loginitems => [],
      }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_content(
      /DidSeeCloudSetup/)
    }
    it { should_not contain_mobileconfig('managedmac.mcx.alacarte').with_content(
      /AutoLaunchedApplicationDictionary-managed/)
    }
  end

  context "when $hidden_preference_panes are defined" do
    let(:params) do
      { :hidden_preference_panes => ['com.apple.preferences.icloud'] }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_content(
      /com\.apple\.preferences\.icloud/)
    }
  end

  context "when NO $hidden_preference_panes are defined" do
    let(:params) do
      { :hidden_preference_panes => [] }
    end
    it { should contain_mobileconfig('managedmac.mcx.alacarte').with_ensure(
      'absent')
    }
  end

  context "when $hidden_preference_panes is not an Array" do
    let(:params) do
      { :hidden_preference_panes => 'foo' }
    end
    it { should raise_error(Puppet::Error, /not an Array/) }
  end

end
