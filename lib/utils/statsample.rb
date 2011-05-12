module Statsample
  class Vector

    # Return a new Vector with values computed apply the math operation specified
    def math(operation, *args)
      recode do |value|
        Math.send(operation, value, *args) unless value.nil?
      end
    end

    # Modify the current Vector with the math function applied over all the data
    def math!(operation, *args)
      recode! do |value|
        Math.send(operation, value, *args) unless value.nil?
      end
    end

  end #Vector

  class Dataset

    # Return a new Dataset with the math function applied over all the vectors
    # apply only on NON-nominal data
    # apply_on_fields  is an Array on fields on which apply the math operation. Empty array means on ALL fields
    def math(operation, apply_on_fields, *args)
      if apply_on_fields.kind_of? Array
        not_apply_on_fields = fields-apply_on_fields
        ds=dup_empty # duplicate current dataset
        each_vector do |k,v|
          (not_apply_on_fields.include? k || v.type==:nominal) ? ds[k]=v : ds[k]=v.math(operation,*args)
        end

        ds.update_valid_data
        ds
      else
        raise "apply_on_fields must be an Array at least empty."
      end
    end

    # Modify the current Dataset with the math function applied over all the vectors
    def math!(operation, apply_on_fields, *args)
      if apply_on_fields.kind_of? Array
        not_apply_on_fields = fields-apply_on_fields
        each_vector do |k,v|        
          v.math!(operation, *args) unless (v.type==:nominal || not_apply_on_fields.include?(k))
        end
        update_valid_data
        self
      else
        raise "apply_on_fields must be an Array at least empty."
      end
    end

    # Create a copy of the old_name vector with the new_name and then delete the old_name vector
    def rename(old_name, new_name)
      add_vector new_name, self[old_name]
      delete_vector old_name
    end

  end #Dataset
end #Statsample
