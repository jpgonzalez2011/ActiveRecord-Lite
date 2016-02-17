require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject

  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end
    end
    self.columns.each do |column|
      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "#{self}".tableize
  end

  def self.all
    all = DBConnection.execute(<<-SQL).to_a
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
    all_cats = self.parse_all(all)
  end

  def self.parse_all(results)
    objects = []
    results.each do |result|
      objects << self.new(result)
    end
    objects
  end

  def self.find(id)
    found_row = DBConnection.execute(<<-SQL).to_a.first
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = #{id}
    SQL
    return nil if found_row.nil?
    self.new(found_row)
  end

  def initialize(params = {})
    columns = self.class.columns
    params.each do |key, value|
      raise "unknown attribute \'#{key}\'" unless columns.include?(key.to_sym)
    end
    params.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    columns = self.class.columns
    values = columns.map { |column| self.attributes[column] }
  end

  def insert
    columns = self.class.columns.drop(1)
    columns_string = columns.join(', ')
    question_marks = columns.map { |column| "?" }.join(', ')
    DBConnection.execute(<<-SQL, *self.attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{columns_string})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
      columns = self.class.columns.drop(1)
      columns_string = columns.map { |column| "#{column} = ?"}.join(', ')
      question_marks = columns.map { |column| "?" }.join(', ')
      DBConnection.execute(<<-SQL, *self.attribute_values.drop(1))
        UPDATE
          #{self.class.table_name}
        SET
          #{columns_string}
        WHERE
          id = #{self.id}
      SQL
  end

  def save
    self.id.nil? ? insert : update
  end
end
