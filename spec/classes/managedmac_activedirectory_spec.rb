require 'spec_helper'

describe 'managedmac::activedirectory', :type => 'class' do

  context "when $enable == undef" do
    it { should compile.with_all_deps }
  end

  context 'when $enable == false' do

    context 'when $provider is INVALID' do
      let(:params) do
        ad_params_base({ :provider => 'whatever' })
      end
      specify do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /Parameter :provider must be 'mobileconfig' or 'dsconfigad'/)
      end
    end

    context 'when $provider == :mobileconfig' do

      context 'when $evaluate is false' do
        let(:params) do
          ad_params_base({ :evaluate => 'false' })
        end
        specify do
          should_not contain_mobileconfig('managedmac.activedirectory.alacarte')
        end
      end

      context "when $evaluate == 'no'" do
        let(:params) do
          ad_params_base({ :evaluate => 'no' })
        end
        specify do
          should_not contain_mobileconfig('managedmac.activedirectory.alacarte')
        end
      end

      context "when $evaluate == true" do
        let(:params) do
          ad_params_base({ :evaluate => true })
        end
        specify do
          should contain_mobileconfig('managedmac.activedirectory.alacarte').with_ensure('absent')
        end
      end

    end

    context 'when $provider == :dsconfigad' do

      context 'when $evaluate is false' do
        let(:params) do
          ad_params_base({ :evaluate => false }, false, true)
        end
        specify do
          should_not contain_dsconfigad
        end
      end

      context "when $evaluate == 'no'" do
        let(:params) do
          ad_params_base({ :evaluate => 'no' }, false, true)
        end
        specify do
          should_not contain_dsconfigad
        end
      end

      context "when $evaluate == true" do
        let(:params) do
          ad_params_base({ :evaluate => true, :hostname => 'foo.ad.com' }, false, true)
        end
        specify do
          should contain_dsconfigad('foo.ad.com').with_ensure('absent')
        end
      end

    end

  end

  context 'when $enable == true' do

    required_params = {
      :hostname  => 'foo.ad.com',
      :username  => 'account',
      :password  => 'password',
    }

    context 'when $provider is INVALID' do
      let(:params) do
        ad_params_base({ :provider => 'whatever' }, true)
      end
      specify do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /Parameter :provider must be 'mobileconfig' or 'dsconfigad'/)
      end
    end

    context "when REQUIRED params are NOT set" do
      let(:params) do
        ad_params_base({}, true)
      end
      specify do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /You must specify a.*param/)
      end
    end

    context "when $seatbelt is INVALID" do
      let(:params) do
        ad_params_base(required_params.merge({:evaluate  => 'whatever'}), true)
      end
      specify do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /Parameter.*must be/)
      end
    end

    context 'when $provider == :mobileconfig' do

      context "when REQUIRED params are set" do
        let(:params) do
          ad_params_base(required_params, true)
        end
        specify do
          should contain_mobileconfig('managedmac.activedirectory.alacarte').with_ensure('present')
        end
      end

      context "when $evaluate == undef" do
        let(:params) do
          ad_params_base(required_params.merge({:evaluate  => ''}), true)
        end
        specify do
          should contain_mobileconfig('managedmac.activedirectory.alacarte').with_ensure('present')
        end
      end

      context "when $evaluate == 'true'" do
        let(:params) do
          ad_params_base(required_params.merge({:evaluate  => 'true'}), true)
        end
        specify do
          should contain_mobileconfig('managedmac.activedirectory.alacarte').with_ensure('present')
        end
      end

      context "when $evaluate == 'yes'" do
        let(:params) do
          ad_params_base(required_params.merge({:evaluate  => 'yes'}), true)
        end
        specify do
          should contain_mobileconfig('managedmac.activedirectory.alacarte').with_ensure('present')
        end
      end

      context "when $evaluate == 'no'" do
        let(:params) do
          ad_params_base(required_params.merge({:evaluate  => 'no'}), true)
        end
        specify do
          should_not contain_mobileconfig('managedmac.activedirectory.alacarte')
        end
      end

      context "when $evaluate == 'false'" do
        let(:params) do
          ad_params_base(required_params.merge({:evaluate  => 'false'}), true)
        end
        specify do
          should_not contain_mobileconfig('managedmac.activedirectory.alacarte')
        end
      end

    end

    context 'when $provider == :dsconfigad' do

      context "when REQUIRED params are set" do
        let(:params) do
          ad_params_base(required_params, true, true)
        end
        specify do
          should contain_dsconfigad('foo.ad.com').with_ensure('present')
        end
      end

      context "when $evaluate == undef" do
        let(:params) do
          ad_params_base(required_params.merge({:evaluate  => ''}), true, true)
        end
        specify do
          should contain_dsconfigad('foo.ad.com').with_ensure('present')
        end
      end

      context "when $evaluate == 'true'" do
        let(:params) do
          ad_params_base(required_params.merge({:evaluate  => 'true'}), true, true)
        end
        specify do
          should contain_dsconfigad('foo.ad.com').with_ensure('present')
        end
      end

      context "when $evaluate == 'yes'" do
        let(:params) do
          ad_params_base(required_params.merge({:evaluate  => 'yes'}), true, true)
        end
        specify do
          should contain_dsconfigad('foo.ad.com').with_ensure('present')
        end
      end

      context "when $evaluate == 'no'" do
        let(:params) do
          ad_params_base(required_params.merge({:evaluate  => 'no'}), true, true)
        end
        specify do
          should_not contain_dsconfigad('foo.ad.com')
        end
      end

      context "when $evaluate == 'false'" do
        let(:params) do
          ad_params_base(required_params.merge({:evaluate  => 'false'}), true, true)
        end
        specify do
          should_not contain_dsconfigad('foo.ad.com')
        end
      end

    end

  end

end