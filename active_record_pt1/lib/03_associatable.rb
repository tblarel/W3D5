require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end

end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {}) 
    default = {
      :foreign_key => "#{name}_id".to_sym,
      :class_name => name.to_s.camelcase,
      :primary_key => :id
    }
    
    default.keys.each do |key|
      if options.empty?
        self.send("#{key}=", default[key])
      else
        self.send("#{key}=", options[key])
      end
    end

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    default = {
      :foreign_key => "#{self_class_name.underscore}_id".to_sym,
      :class_name => name.to_s.singularize.camelcase,
      :primary_key => :id
    }

    default.keys.each do |key|
      if options.empty?
        self.send("#{key}=", default[key])
      else
        self.send("#{key}=", options[key])
      end
    end

  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
