module Statsample
  class Vector

    # Return a new Vector with values computed apply the math operation specified
    def math(operation, *args)
      recode do |value|
        Math.send(operation, value, *args)
      end
    end

    # Modify the current Vector with the math function applied over all the data
    def math!(operation, *args)
      recode! do |value|
        Math.send(operation, value, *args)
      end
    end

  end #Vector

  class Dataset

    # Return a new Dataset with the math function applied over all the vectors
    def math(operation, *args)
      ds=dup_empty # duplicate current dataset
      each_vector do |k,v|
        ds[k]=v.math operation,*args
      end
      ds.update_valid_data
      ds
    end

    # Modify the current Dataset with the math function applied over all the vectors
    def math!(operation, *args)
      each_vector do |k,v|        
          v.math! operation, *args
      end
      update_valid_data
      self
    end

  end #Dataset
end #Statsample
