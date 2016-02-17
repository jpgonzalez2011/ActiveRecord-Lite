require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    result = []
    params_string = params.keys.map { |key| "#{key} = ?" }.join(" AND ")
    finds = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{params_string}
    SQL
    finds.each do |find|
      result << new(find)
    end
    result
  end
end

class SQLObject
  extend Searchable
end
