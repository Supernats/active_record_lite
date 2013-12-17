require_relative './associatable'
require_relative './db_connection' # use DBConnection.execute freely here.
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'

class SQLObject < MassObject
  # sets the table_name
  def self.set_table_name(table_name)
    @table_name = table_name.underscore
  end

  # gets the table_name
  def self.table_name
    @table_name
  end

  # querys database for all records for this type. (result is array of hashes)
  # converts resulting array of hashes to an array of objects by calling ::new
  # for each row in the result. (might want to call #to_sym on keys)
  def self.all
    rows = DBConnection.execute(<<-SQL,)
      SELECT
        "#{table_name}".*
      FROM
        "#{table_name}"
      SQL
    objects = []
    rows.each do |hash|
      objects << self.new(hash)
    end
    objects
  end

  # querys database for record of this type with id passed.
  # returns either a single object or nil.
  def self.find(id)
    found_cats = DBConnection.execute(<<-SQL, :id => id)
      SELECT
        "#{table_name}".*
      FROM
        "#{table_name}"
      WHERE
        "#{table_name}".id = :id
      LIMIT
        1
      SQL
    return nil if found_cats.empty?
    self.new(found_cats[0])
  end

  # executes query that creates record in db with objects attribute values.
  # use send and map to get instance values.
  # after, update the id attribute with the helper method from db_connection
  def create
    attribute_values = self.attribute_values
    attribute_names = self.class.attributes.join(", ")
    question_string = (['?'] * attribute_values.count).join(", ")

    # query = { :attr_values => *attribute_values
    #           :question_marks => question_string
    #         }
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        "#{table_name}" #{attribute_names}
      VALUES
        "#{question_string}"
      SQL
    self.id = DBConnection.last_insert_row_id
  end

  # executes query that updates the row in the db corresponding to this instance
  # of the class. use "#{attr_name} = ?" and join with ', ' for set string.

  def insert
    col_names = self.class.attributes.join(", ")
    question_marks = (["?"] * self.attributes.count).join(", ")
  end

  def update
    set_line = self.class.attributes.map do |attr_name|
      "#{attr_name} = ?"
    end
    DBConnection.execute(<<-SQL, *self.attributes_values, self.id)
      UPDATE
        "#{table_name}"
      SET
        "#{set_line}"
      WHERE
        id = ?
    SQL
  end

  # call either create or update depending if id is nil.
  def save
    if self.id.nil?
      self.create
    else
      self.update
    end
  end

  # helper method to return values of the attributes.
  def attribute_values
    [].tap do |attribute_values|
      self.instance_variables.each do |attr_name|
        attribute_values.concat(self.send("#{attr_name}"))
      end
    end
  end

end
