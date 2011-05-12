require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Adapter" do
  it  "should load test data with no error" do
    Bio::Gex::Adapter.read(:cufflinks_quantification, File.join(File.dirname(__FILE__),"../fixtures/cufflinks_gene_quantification.csv")).should_not be_nil
  end
  
  it "should return the fields on which math operation will be applied" do
    Bio::Gex::Adapter.math_fields(:cufflinks_quantification).should == ["fpkm"]
  end
end