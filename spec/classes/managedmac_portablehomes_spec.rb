require 'spec_helper'

describe "managedmac::portablehomes", :type => 'class' do
  
  let(:params) do
    { :enable => true }
  end
  
  it { should compile.with_all_deps }

end