
module Bio
  class Gex
    attr_accessor :name, :description #String
    attr_accessor :adapter, :source #adapter is a symbol Bio::Gex::Adapter.ROUTE, source is for instance a path to file
    attr_accessor :genes, :genes_descriptions, :math_fields #Array
    attr_accessor :dataset #Statsample::Dataset
    attr_reader :indexes, :index_fields

    # name, {genes: val,data_set:val, genes_descriptions: val, adapter:(Cufflinks_Quantification,PlainText,Csv,Tab,...), filename:...}
    def initialize(name, options=Hash.new)
      @adapter = options[:adapter]
      @source = options[:source] #filesystem dbi etc,,,
      @name = name
      @adapter_handler = Bio::Gex::Adapter
      @description = options[:description]
      @genes = options[:genes]
      @dataset = options[:dataset] || (options[:adapter] && options[:source] && @adapter_handler.read(options[:adapter], options[:source])) || Statsample::Dataset.new
      @dataset.name = name
      @genes_descriptions = options[:genes_descriptions]
      @index_fields = Array.new  
      @indexes = set_indexes(options[:indexes]) #this field is use to make an access by row to the dataset ( there will be a dictionary with key/row for each index)
      @math_fields = options[:math_fields] || (options[:adapter] && @adapter_handler.math_fields(@adapter)) || [] #fArray of ields on which every math operation will be applied, [] means all fields.
    end

    #try to be smart as possible
    # Return an Array of rows if you pass multiple keys or if the key has multiple rows
    # with a range is mostly an access by row, in the original dataset the rage is used to retrve the fields/columns
    # output Array is not unique, is important to keep an association one-to-one between the input query and the output.
    # gex[(Range|Array|String|Integer),...]
    # the query can be a range, an array of fields, a list of indexes or an integer
    def[](*clausle)
      clausle.map do |i|
        if is_for_dataset?(i)
          #TODO: case is range ? case is array?
          if i.is_a? Integer
            @dataset.case_as_hash(i)
          elsif i.is_a? Range
            i.map do |idx|
            @dataset.case_as_hash(idx)
          end
          else
            @dataset[i]
          end
        elsif is_an_index?(i)
          #check if it's an index
          @indexes[i].map do |idx|
            dataset.case_as_hash idx
          end#.flatten
        elsif are_indexes?(i)
          #return an array of hashes 
          i.map do |key|
            @indexes[key].map do |idx|
              dataset.case_as_hash  idx
            end
          end#.flatten
        else
          raise "You are trying to extract some information from the dataset but I dunno what to do with #{i}. It's not a field and there are no indexes with it."
        end
      end.flatten
    end


    #add/update the main index
    def index=(indexes_list)
      set_indexes(indexes_list).each do |key, idx|
        @indexes[key] = idx
      end
    end

    alias :add_index :index=


    # Duplicate the current Gex
    # TODO: fix duplication now is wrong.
    def dup
      Gex.new(name, genes:dup_attribute(genes), description:dup_attribute(description),
      genes_descriptions:dup_attribute(genes_descriptions), indexes:dup_attribute(indexes),
      index_fields:dup_attribute(index_fields), adapter:adapter, source:dup_attribute(source), 
      dataset:dup_attribute(dataset))
    end

    def empty?
      dataset.cases.nil?
    end

    def genes=(genes_list)
      @genes=genes_list
    end

    def descriptions=(descriptions_list)
      @genes_descriptions=descriptions_list
    end

    # Reload the internal dataset and return self, if adapter and source are defined, otherwise nil
    def load
      if (adapter && source)
        @dataset = @adapter_handler.read(adapter, source)
        self
      end
    end
    alias :reload :load

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
    def log(base=2)
      gd=dup
      gd.dataset.math! :log, math_fields, base
      gd
    end

    # Return the current dataset with all samples gex data transformed in log.
    def log!(base=2)
      dataset.math! :log, math_fields, base
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
    
    def method_missing(method, *args)
      @dataset.send method, *args
    end

    private
    def is_for_dataset?(param)
      if param.is_a? Integer
        true
      elsif  param.is_a? Range
        true
      elsif param.is_a? Array # the element in the array are all part of the dataset's field
        (param - dataset.fields).size == 0
      elsif param.is_a?(String) && @dataset.fields.include?(param)
        true
      end
    end

    def is_an_index?(param)
      param.is_a?(String) &&  @indexes.key?(param)
    end

    #param in this case is an array
    def are_indexes?(param)
      if param.is_a? Array
        param.each do |key|
          return false unless is_an_index?(key)
        end
        return true
      end
    end

    #indexes_list must be an array of fields
    def set_indexes(indexes_list)
      idxs = Hash.new {|h,k| h[k]=Array.new}
      unless indexes_list.nil?
        if invalid_fields = !is_for_dataset?(indexes_list)
          warn "Some index can not be used because is not a valid dataset's field"
        end
        unless invalid_fields
          indexes_list = [indexes_list] if indexes_list.is_a? String
          @index_fields+=indexes_list
          @index_fields.uniq!
          @dataset.each_with_index do |row, idx|
            indexes_list.each do |key|
              format_row = row[key].nil? ? "#{key}_NA" : row[key].to_s
              idxs[format_row].push(idx)
            end
          end
        end
      end
      idxs
    end

    #attribute is a symbol
    def dup_attribute(attribute)
      attribute.nil? ? nil : attribute.dup
    end

  end #GeneExpression
end #Bio