require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if !@columns.nil?
    @columns = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    @columns = @columns[0]
    @columns.each_with_index do |ele, i|
      @columns[i] = ele.to_sym
    end
    @columns
  end

  def self.finalize!
    self.columns.each do |col_name| 
      define_method(col_name) do 
        self.attributes[col_name]
      end

      define_method("#{col_name}=") do |value|
        self.attributes[col_name] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore+'s'
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT 
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results)
    arr = Array.new
    results.each do |result|
       arr << self.new(result)
    end
    if arr.empty?
      return nil
    else
      return arr
    end
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
    SQL
    results = parse_all(data)
    if results.nil?
      return nil
    else
      return results[0]
    end
  end

  def initialize(params = {})
    params.each do |attr_name, attr_val|
      attr_name = attr_name.to_sym
      if !self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      else
        self.send("#{attr_name}=", attr_val)
      end
    end
  end

  def attributes
    @attributes ||= Hash.new
  end

  def attribute_values
    values = []
    self.class.columns.each do |attr| 
      values << self.send(attr)
    end
    if values.empty?
      return nil
    else
      return values
    end
  end

  def insert
    columns = self.class.columns[1..-1]
    col_names = columns.map(&:to_s).join(", ")
    questions_arr = Array.new
    columns.length.times do
      questions_arr << "?"
    end
    questions_arr = questions_arr.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values[1..-1])
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{questions_arr})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_arr = Array.new
    self.class.columns.each do |attr_name|
      set_arr <<  "#{attr_name} = ?"
    end
    line = set_arr.join(", ")
    
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name} 
      SET
        #{line}
      WHERE
        #{self.class.table_name}.id = ?    
    SQL
  end

  def save
    if id.nil?
      self.insert
    else
      self.update
    end
  end
  
end
