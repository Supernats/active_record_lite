require_relative './db_connection'

module Searchable
  # takes a hash like { :attr_name => :search_val1, :attr_name2 => :search_val2 }
  # map the keys of params to an array of  "#{key} = ?" to go in WHERE clause.
  # Hash#values will be helpful here.
  # returns an array of objects
  def where(params)
    where_line = params.keys.map do |key|
      "#{key} = ?"
    end
    where_line = where_line.join(" AND ")
    results = DBConnection.execute(<<-SQL, params.values)
    SELECT
      "#{self.class.table_name}".*
    FROM
      "#{self.class.table_name}"
    WHERE
      "#{where_line}"
    SQL
    self.class.parse_all(results)
  end
end