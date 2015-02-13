require 'spec_helper'

describe 'managedmac::desktop', :type => 'class' do

  context "when none of the params are set" do
    it do
      should_not contain_mobileconfig('managedmac.desktop.alacarte')
    end
  end

end
