require 'spec_helper'

describe 'managedmac::activedirectory', :type => 'class' do
  
  # Load the hiera data with our options
  # Test data courtesy of helpers.rb
  let :hiera_data do
    { 'managedmac::activedirectory::options' => options_activedirectory }
  end
  
  # Here we test against a regex because testing the complete rendering is:
  # a) problematic with ERB
  # b) takes up too much space
  specify do
    should contain_mobileconfig('managedmac.activedirectory.alacarte').with_content(
      /ADDefaultUserShell.*\/bin\/bash/)
  end
  
  it { should compile.with_all_deps }
  
end