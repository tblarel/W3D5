require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    line = Array.new
    params.keys.each do |key|
      line << "#{key} = ?"
    end
    line = line.join(" AND ")
    
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{line}
    SQL
    
    results = parse_all(results)
    if results.nil?
      return []
    else
      results
    end
  end
end

class SQLObject
  extend Searchable
end

