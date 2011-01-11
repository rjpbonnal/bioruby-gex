module Bio
  class Gex
    attr_accessor :name
    attr_accessor :genes_descriptions
    attr_accessor :genes
    attr_accessor :data_sets

    def initialize(name)
      @name = name
      @genes = nil
      @data_sets = Statsample::Dataset.new
      @genes_description = nil
    end

    def genes=(genes_list)
      @genes=genes_list
    end

    def descriptions=(descriptions_list)
      @genes_descriptions=descriptions_list
    end
    # data is an hash of array
    def add_dataset(data)
      data.each_pair do |data_name, data_array|
        @data_sets[data_name]=data_array.to_scale
      end
    end

    # Create a string with tab separated name, description, sample and values 
    def to_tab
      hash_output = HashOfArrays.new
      hash_output["NAME"]= genes
      hash_output["Description"]= genes_descriptions || genes
      hash_output.merge!(data_sets)
      hash_output.transpose_to_str(genes.size,separator="\t", order=["NAME","Description"]+data_sets.keys)
    end

    
    # Export the Gene Expression data to Gene Pattern Format GCT
    def to_gct
      str_out_header = "#1.2"
      str_out_numbers = "#{genes.size}\t#{data_sets.size}"
       "#{str_out_header}\n#{str_out_numbers}\n#{to_tab}"
      
      # hash_output = HashOfArrays.new
      # hash_output["NAME"]= genes
      # hash_output["Description"]= genes_descriptions || genes
      # hash_output.merge!(data_sets)
      # str_out_body=hash_output.transpose_to_str(genes.size,separator="\t", order=["NAME","Description"]+data_sets.keys)
      # [str_out_header,str_out_numbers,str_out_body].join("\n")
    end
  end #GeneExpression
end #Bio