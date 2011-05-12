#
#  quantification.rb - Cufflinks quantification rader
#
# Copyright:: Copyright (C) 2011
#     Raoul J.P. Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#

module Bio
  class Gex

    module Adapter
      ROUTES = {:cufflinks_quantification=>"Cufflinks::Quantification"}

      class << self
        def read(path, source)
          if valid?(path)
            eval(ROUTES[path]).send :read, source
          else
            raise "There is not route to #{path} in Bio::Gex::Adapters"
          end
        end

        def valid?(path)
          ROUTES.key?(path)
        end
        
        # each adapter must implement this function and return at least an empty array.
        # this is used to apply math operation on specific fields and not all dataset
        # by default.
        def math_fields(path)
          if valid?(path)
            eval(ROUTES[path]).send :math_fields
          else
            raise "There is not route to #{path} in Bio::Gex::Adapters"
          end          
        end
      end
    end


    module Cufflinks
      module Quantification

        class << self
          # Read a tab delimited file, produced by cufflink
          # Return a Statsample::Dataset
          def read(file_name)
            if file_name.nil?
              raise "File name not valid, it's nil"
            else
              Statsample::CSV.read(file_name, empty=[''], ignore_lines=0, fs=" ")
            end
          end
          
          # Return an Array, filled with fields name into the dataset or an empty array
          # an empty array means that the math operation will be applied on all scale fields.  
          def math_fields
            ["fpkm"]
          end
            
        end #self
      end #Quantification
    end #Cufflinks

    # module Plain
    #   def read
    #     Statsample::PlainText.read
    #   end
    # end
  end #Gex
end #Bio