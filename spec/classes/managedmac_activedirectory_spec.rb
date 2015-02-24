require 'spec_helper'

describe 'managedmac::activedirectory', :type => 'class' do

  context "when $enable == undef" do
    it { should compile.with_all_deps }
  end

  context 'when $enable == false' do

    context 'when $provider is INVALID' do
      let(:params) do
        ad_params_enable_false({ :provider => 'whatever' })
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
          ad_params_enable_false({ :evaluate => 'false' })
        end
        specify do
          should_not contain_mobileconfig('managedmac.activedirectory.alacarte')
        end
      end

      context "when $evaluate == 'no'" do
        let(:params) do
          ad_params_enable_false({ :evaluate => 'no' })
        end
        specify do
          should_not contain_mobileconfig('managedmac.activedirectory.alacarte')
        end
      end

      context "when $evaluate == true" do
        let(:params) do
          { :enable => false }
        end
        specify do
          should contain_mobileconfig('managedmac.activedirectory.alacarte').with_ensure('absent')
        end
      end

    end
  end

  context 'when $enable == true' do

    context 'when $provider is INVALID' do
      let(:params) do
        ad_params_enable_true({ :provider => 'whatever' })
      end
      specify do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /Parameter :provider must be 'mobileconfig' or 'dsconfigad'/)
      end
    end

    context "when REQUIRED params are NOT set" do
      let(:params) do
        ad_params_enable_true
      end
      specify do
        expect {
          should compile
        }.to raise_error(Puppet::Error, /You must specify a.*param/)
      end
    end

    context "when $seatbelt is INVALID" do
      let(:params) do
        ad_params_enable_true({
          :hostname  => 'foo.ad.com',
          :username  => 'account',
          :password  => 'password',
          :evaluate  =>  "whatever",
        })
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
          ad_params_enable_true({
            :hostname => 'foo.ad.com',
            :username => 'account',
            :password => 'password',
          })
        end
        specify do
          should contain_mobileconfig('managedmac.activedirectory.alacarte').with_ensure('present')
        end
      end

      context "when $evaluate == undef" do
        let(:params) do
          ad_params_enable_true({
            :hostname  => 'foo.ad.com',
            :username  => 'account',
            :password  => 'password',
            :evaluate  => '',
          })
        end
        specify do
          should contain_mobileconfig('managedmac.activedirectory.alacarte').with_ensure('present')
        end
      end

      context "when $evaluate == 'true'" do
        let(:params) do
          ad_params_enable_true({
            :hostname  => 'foo.ad.com',
            :username  => 'account',
            :password  => 'password',
            :evaluate  => 'true',
          })
        end
        specify do
          should contain_mobileconfig('managedmac.activedirectory.alacarte').with_ensure('present')
        end
      end

      context "when $evaluate == 'yes'" do
        let(:params) do
          ad_params_enable_true({
            :hostname  => 'foo.ad.com',
            :username  => 'account',
            :password  => 'password',
            :evaluate  => 'yes',
          })
        end
        specify do
          should contain_mobileconfig('managedmac.activedirectory.alacarte').with_ensure('present')
        end
      end

      context "when $evaluate == 'no'" do
        let(:params) do
          ad_params_enable_true({
            :hostname  => 'foo.ad.com',
            :username  => 'account',
            :password  => 'password',
            :evaluate  => 'no',
          })
        end
        specify do
          should_not contain_mobileconfig('managedmac.activedirectory.alacarte')
        end
      end

      context "when $evaluate == 'false'" do
        let(:params) do
          ad_params_enable_true({
            :hostname  => 'foo.ad.com',
            :username  => 'account',
            :password  => 'password',
            :evaluate  => 'false',
          })
        end
        specify do
          should_not contain_mobileconfig('managedmac.activedirectory.alacarte')
        end
      end

    end

  end

end