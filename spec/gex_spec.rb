require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Initialize Gex" do
  it "with name only should have an empty dataset" do
    gex = Bio::Gex.new("Experiment")
    gex.should be_empty
  end

  it "with name and it should be the same for Gex and internal Dataset" do
    gex = Bio::Gex.new("Experiment")
    gex.name.should == gex.dataset.name
  end

  it "with name and description" do
    gex = Bio::Gex.new("Experiment", description:"Test experiment for Bio::Gex")
    gex.name.should == "Experiment"
    gex.description.should == "Test experiment for Bio::Gex"
  end

  it "with name, description and dataset" do
    ds = Statsample::CSV.read(File.join(File.dirname(__FILE__),"../fixtures/test_csv.csv"))
    gex = Bio::Gex.new("Experiment", description:"Test experiment for Bio::Gex", dataset:ds)
    gex.dataset.should_not be_nil
  end

  it "with a field as index" do
    ds = Statsample::CSV.read(File.join(File.dirname(__FILE__),"../fixtures/test_csv.csv"))
    gex = Bio::Gex.new("Experiment", description:"Test experiment for Bio::Gex", dataset:ds, indexes:%w(name city))
    gex.indexes.should == {"Alex"=>[0], "New York"=>[0], "Claude"=>[1], "London"=>[1, 2], 
                           "Peter"=>[2], "Franz"=>[3], "Paris"=>[3], "George"=>[4], 
                           "Tome"=>[4], "Fernand"=>[5], "city_NA"=>[5, 6], "Dick"=>[6]}
  end

  describe "filled dataset" do
    before do
      ds = Statsample::CSV.read(File.join(File.dirname(__FILE__),"../fixtures/test_csv.csv"))
      gex = Bio::Gex.new("Experiment", description:"Test experiment for Bio::Gex", dataset:ds)
      @dataset = gex.dataset
      @ds = ds
    end

    #    it "with name, description and dataset, the dataset should be completely filled" do
    context "with fields" do 
      subject {@dataset.fields}
      it { should == ["id", "name", "age", "city", "a1"] }
    end

    context "with cases" do
      subject {@dataset.cases}
      it { should == 7}
    end

    context "with id" do
      subject {@dataset.vectors["id"]}
      it { should == @ds["id"]}
    end
  end #"filled dataset"

  describe "when load Cufflinks Gene Quanatification" do
    before { @gex = Bio::Gex.new("Experiment", description:"Test experiment for Bio::Gex", :adapter=>:cufflinks_quantification, source:File.join(File.dirname(__FILE__),"../fixtures/cufflinks_gene_quantification.csv"))}

    context "the example loaded" do
      subject {@gex.dataset}
      it "should not have problems" do      
        subject.should == Statsample::CSV.read(File.join(File.dirname(__FILE__),"../fixtures/cufflinks_gene_quantification.csv"), empty=[''], ignore_lines=0, fs=" ")
      end
    end

    context "the example loaded" do
      subject {@gex.dataset.name}
      it "should have the same name than Bio::Gex" do
        should == @gex.name
      end
    end 

  end #when load Cufflinks Gene Quanatification
end #Initialize Gex

describe "Use Gex"  do
  before do
    @gex = Bio::Gex.new("Experiment", description:"Test experiment for Bio::Gex", :adapter=>:cufflinks_quantification, source:File.join(File.dirname(__FILE__),"../fixtures/cufflinks_gene_quantification.csv"))
    @gex.index=%w(gene_id status)
  end

  context "with a math operation" do
    it "when log transforms the Gex on default fields" do
      original = @gex.dataset['fpkm'].dup
      log = @gex.log!["fpkm"]
      infy = [-1.0/0.0,-1.0/0.0,-1.0/0.0,-1.0/0.0,-1.0/0.0,-1.0/0.0,0.04512140405482081,-0.4439424345387633,-0.4794198494421218,-1.6567945956197383,-1.0/0.0,-4.405582923219904,-2.269560894254616,-1.0/0.0,-1.0/0.0,-1.0/0.0,-1.0/0.0,-1.0/0.0,-1.0/0.0,-1.5248569952563322,0.7156737655481872,-2.225477313783075,-3.913140161548815]
      
      log.should == infy
    end
  end

  context "to set indexes" do
    it "should return the indexes created" do
      @gex.indexes.should == {
        "ENSG00000240361"=>[0], 
        "OK"=>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22], 
        "ENSG00000177693"=>[1], "ENSG00000239906"=>[2], "ENSG00000237613"=>[3], "ENSG00000222623"=>[4],
        "ENSG00000241599"=>[5], "ENSG00000239368"=>[6], "ENSG00000228463"=>[7], "ENSG00000241670"=>[8], "ENSG00000238009"=>[9], 
        "ENSG00000239945"=>[10], "ENSG00000233750"=>[11], "ENSG00000241860"=>[12], "NO"=>[12], "ENSG00000233653"=>[13], 
        "ENSG00000236601"=>[14], "ENSG00000224813"=>[15], "ENSG00000235249"=>[16], "ENSG00000236812"=>[17], "ENSG00000236743"=>[18],
        "ENSG00000240876"=>[19], "ENSG00000237094"=>[20], "ENSG00000250575"=>[21], "ENSG00000253101"=>[22]}
    end
  
    context "adding chr" do
      subject do 
        @gex.index="chr"
        @gex
      end 
      
      it "should add an index on chr and return total number of elements" do
        subject["1"].size.should == 23
      end
  
      it "should search for multiple keys at the same time (strings and row number)" do
        subject["ENSG00000240361","ENSG00000239906", 20].should == [{"gene_id"=>"ENSG00000240361", "bundle_id"=>33128, "chr"=>1, "left"=>62947, "right"=>63887, "fpkm"=>0, "fpkm_conf_lo"=>0, "fpkm_conf_hi"=>0, "status"=>"OK"}, {"gene_id"=>"ENSG00000239906", "bundle_id"=>33132, "chr"=>1, "left"=>139789, "right"=>140339, "fpkm"=>0, "fpkm_conf_lo"=>0, "fpkm_conf_hi"=>0, "status"=>"OK"}, {"gene_id"=>"ENSG00000237094", "bundle_id"=>33138, "chr"=>1, "left"=>320161, "right"=>328580, "fpkm"=>1.64225, "fpkm_conf_lo"=>0, "fpkm_conf_hi"=>4.03146, "status"=>"OK"}]
      end

      it "should search for multiple keys at the same time (strings, row number, range)" do
        subject[(1..5),"ENSG00000240361","ENSG00000239906", 20].should == [
          {"gene_id"=>"ENSG00000177693", "bundle_id"=>33129, "chr"=>1, "left"=>69054, "right"=>70108, "fpkm"=>0, "fpkm_conf_lo"=>0, "fpkm_conf_hi"=>0, "status"=>"OK"},
          {"gene_id"=>"ENSG00000239906", "bundle_id"=>33132, "chr"=>1, "left"=>139789, "right"=>140339, "fpkm"=>0, "fpkm_conf_lo"=>0, "fpkm_conf_hi"=>0, "status"=>"OK"},
          {"gene_id"=>"ENSG00000237613", "bundle_id"=>33127, "chr"=>1, "left"=>34553, "right"=>36081, "fpkm"=>0, "fpkm_conf_lo"=>0, "fpkm_conf_hi"=>0, "status"=>"OK"},
          {"gene_id"=>"ENSG00000222623", "bundle_id"=>33134, "chr"=>1, "left"=>157783, "right"=>157887, "fpkm"=>0, "fpkm_conf_lo"=>0, "fpkm_conf_hi"=>0, "status"=>"OK"},
          {"gene_id"=>"ENSG00000241599", "bundle_id"=>33135, "chr"=>1, "left"=>160445, "right"=>161525, "fpkm"=>0, "fpkm_conf_lo"=>0, "fpkm_conf_hi"=>0, "status"=>"OK"},
          {"gene_id"=>"ENSG00000240361", "bundle_id"=>33128, "chr"=>1, "left"=>62947, "right"=>63887, "fpkm"=>0, "fpkm_conf_lo"=>0, "fpkm_conf_hi"=>0, "status"=>"OK"},
          {"gene_id"=>"ENSG00000239906", "bundle_id"=>33132, "chr"=>1, "left"=>139789, "right"=>140339, "fpkm"=>0, "fpkm_conf_lo"=>0, "fpkm_conf_hi"=>0, "status"=>"OK"},
          {"gene_id"=>"ENSG00000237094", "bundle_id"=>33138, "chr"=>1, "left"=>320161, "right"=>328580, "fpkm"=>1.64225, "fpkm_conf_lo"=>0, "fpkm_conf_hi"=>4.03146, "status"=>"OK"}]
      end

      
    end
  end


  context "to access data in a smart way" do
    it "should get a row using a single key from the indexes" do
      @gex["ENSG00000241860"].should == [{"gene_id"=>"ENSG00000241860", "bundle_id"=>33133, "chr"=>1, "left"=>141473, "right"=>149707, "fpkm"=>0.207393, "fpkm_conf_lo"=>0, "fpkm_conf_hi"=>1.1182, "status"=>"NO"}]
    end    
  end


end


# 
# Bio::Gex.new("Naive", :file_name=>"prova.csv", :adapter=>:cufflinks_quantitation)
# 
# Posso passare qualsiasi parametro il controllo verrà fatto nel momento in cui chiamerò le singole funzioni per il caricamento dei dati.
# Poterbbe anche essere che io passi già un dataset inizializzato, a quel punto il nome del dataset potrebbe andare a sovrascrivere il nome della gex che sto
# creando nel caso in cui non venga specificato un nome ( in questo caso l'init dovrebbe avere tutto come opzionale stabilendo stabilendo una precedenza.)
# Sarebbe utile avere i riferimenti o sapere su cosa calcolare gli indici.