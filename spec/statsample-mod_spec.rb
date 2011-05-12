require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Math operation"  do
  before { @ds = Statsample::CSV.read(File.join(File.dirname(__FILE__),"../fixtures/test_csv.csv"))}
  subject { @ds }
  it "log should transform the dataset" do |variable|    
    subject.math!(:log, ["age"], 2)["age"].should == [4.321928094887363,4.523561956057013,4.643856189774724,4.754887502163469,2.4594316186372973,nil,nil].to_scale
  end
end