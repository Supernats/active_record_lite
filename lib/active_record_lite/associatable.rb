require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  # will return the actual class of the other object
  def other_class
    @params[:class_name].constantize
  end
  # will return the table of the other object
  def other_table
    other_class.table_name
  end

  def primary_key
    @params[:primary_key]
  end

  def foreign_key
    @params[:foreign_key]
  end

  def class_name
    @params[:class_name]
  end

end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
    @params = {}
    @params[:class_name]  = name.to_s.camelcase
    @params[:foreign_key] = "#{name}_id"
    @params[:primary_key] = "id"
    @params.merge!(params)
  end

  def type
    :belongs_to
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
    @params = {}
    @params[:class_name]  = name.to_s.singularize.camelcase
    @params[:foreign_key] = "#{name}_id"
    @params[:primary_key] = "id"
    @params.merge!(params)
  end

  def type
    :has_many
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    btp = BelongsToAssocParams.new(name, params)
    define_method(name) do

      query = <<-SQL
      SELECT
        *
      FROM
        #{btp.other_table}
      WHERE
        #{btp.other_table}.#{btp.primary_key} = ?
      LIMIT
        1
      SQL


      results = DBConnection.execute(query, self.send(btp.foreign_key))

      btp.other_class.parse_all(results)[0]
    end
  end

  def has_many(name, params = {})
    hmp = HasManyAssocParams.new(name, params, self.class)
    define_method(name) do

      query = <<-SQL
      SELECT
        *
      FROM
        #{self.class.table_name}
      WHERE
        #{hmp.other_table}.#{hmp.foreign_key} = ?
      SQL

      results = DBConnection.execute(query, self.send(hmp.primary_key))
      self.class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)


  end
end
