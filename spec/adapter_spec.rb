require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Adapter" do
  it  "should load test data with no error" do
    Bio::Gex::Adapter.read(:cufflinks_quantification, File.join(File.dirname(__FILE__),"../fixtures/cufflinks_gene_quantification.csv")).should_not be_nil
  end
  
  it "should return the fields on which math operation will be applied" do
    Bio::Gex::Adapter.math_fields(:cufflinks_quantification).should == ["fpkm"]
  end
end

describe "Cufflinks" do
  before {@gex = Bio::Gex::Adapter.read(:cufflinks_quantification, File.join(File.dirname(__FILE__),"../fixtures/cufflinks_gene_quantification.csv"))}
  describe "quantification" do
    context "genes" do
      it "should have all the fields" do
        @gex.fields.should == ["gene_id", "bundle_id", "chr", "left", "right", "fpkm", "fpkm_conf_lo", "fpkm_conf_hi", "status"]
      end
      it "should return the fields on which math operations will be applied" do
        Bio::Gex::Cufflinks::Quantification.math_fields.should == ["fpkm"]
      end
      
    end
  end
end


