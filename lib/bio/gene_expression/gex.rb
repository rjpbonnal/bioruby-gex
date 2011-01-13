module Statsample
  class Vector

    # Return a new vector with values computed apply the math operation specified
    def math(operation, *args)
      recode do |value|
        Math.send(operation, value, *args)
      end
    end

    def math!(operation, *args)
      recode! do |value|
        Math.send(operation, value, *args)
      end
    end

  end #Vector

  class Dataset

    # Return a new dataset with the math function applied over all the vectors
    def math(operation, *args)
      ds=dup_empty # duplicate current dataset
      each_vector do |k,v|
        ds[k]=v.math operation,*args
      end
      ds.update_valid_data
      ds
    end

    # Modify the current dataset with the math function applied over all the vectors
    def math!(operation, *args)
      each_vector do |k,v|        
          v.math! operation, *args
      end
      update_valid_data
      self
    end

  end #Dataset
end #Statsample



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