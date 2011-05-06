
module Bio
  class Gex
    attr_accessor :name #String
    attr_accessor :genes_descriptions #Array
    attr_accessor :genes #Array
    attr_accessor :dataset #Statsample::Dataset

    # name, {genes: val,data_set:val, genes_descriptions: val}
    def initialize(name, options=Hash.new)
      @name = name
      @genes = options[:genes]
      @dataset = options[:dataset]
      @genes_descriptions = options[:genes_descriptions]
    end
    
    # Duplicate the current Gex
    # TODO: fix duplication now is wrong.
    def dup
      Gex.new(name, genes:genes.dup, genes_descriptions:genes_descriptions.dup, dataset:dataset.dup)
    end

    def genes=(genes_list)
      @genes=genes_list
    end

    def descriptions=(descriptions_list)
      @genes_descriptions=descriptions_list
    end

    # Apply the block of code to all the dataset with the recode!, the dataset is modified
    def recode!(field, &block )
      dataset.recode!(field, &block)
      self
    end

    # Return a new dataset with the true cases 
    # Apply the block of code to all the dataset with the recode!, the dataset is modified
    def filter(&block )
      dataset.filter(&block)
    end
    
    # Return a new dataset with the true cases for a specific field
    # Apply the block of code to all the dataset with the recode!, the dataset is modified
    def filter(field, &block )
      dataset.filter(field, &block)
    end
    
    
    # Return the newly created dataset
    # data is an hash of array
    def add_dataset(hash_data)      
      hash_data.each_pair do |data_name, data_array|
        hash_data[data_name]=data_array.to_scale
      end

      if @dataset.nil?
        @dataset = hash_data.to_dataset
      else
        @dataset=@dataset.merge(hash_data.to_dataset)
      end
    end

    # Return a new dataset with all samples gex data transformed in log.
    def log(base=1)
      gd=dup
      gd.dataset.math! :log, base
      gd
    end
    
    # Return the current dataset with all samples gex data transformed in log.
    def log!(base=1)
      dataset.math! :log, base
      self
    end
    
    # Return the names tags used in the dataset (Satsample::Datasets)
    def samples
      dataset.fields
    end
    
    def differential_expression
      # data here, must be filtered and inserted as with a valid p-value
      # I expect to have a not, valid with nil
      # log2 all samples
      # mean centering, do not consider nil values in computation
      # plotting heat-map
    end
    

    # Create a string with tab separated name, description, sample and values 
    def to_tab
      hash_output = HashOfArrays.new
      hash_output["NAME"]= genes
      hash_output["Description"]= genes_descriptions || genes
      hash_output.merge!(datasets)
      hash_output.transpose_to_str(genes.size,separator="\t", order=["NAME","Description"]+dataset.keys)
    end


    # Export the Gene Expression data to Gene Pattern Format GCT
    def to_gct
      str_out_header = "#1.2"
      str_out_numbers = "#{genes.size}\t#{dataset.size}"
      "#{str_out_header}\n#{str_out_numbers}\n#{to_tab}"

      # hash_output = HashOfArrays.new
      # hash_output["NAME"]= genes
      # hash_output["Description"]= genes_descriptions || genes
      # hash_output.merge!(dataset)
      # str_out_body=hash_output.transpose_to_str(genes.size,separator="\t", order=["NAME","Description"]+dataset.keys)
      # [str_out_header,str_out_numbers,str_out_body].join("\n")
    end
  end #GeneExpression
end #Bio