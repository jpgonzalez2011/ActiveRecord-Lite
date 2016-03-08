require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] ||= "#{name}_id".to_sym
    @primary_key = options[:primary_key] ||= "id".to_sym
    @class_name = options[:class_name] ||= name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] ||= "#{self_class_name.underscore}_id".to_sym
    @primary_key = options[:primary_key] ||= "id".to_sym
    @class_name = options[:class_name] ||= name.to_s.singularize.camelcase
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = options
    define_method(name) do
      @foreign_key = options.send(:foreign_key)
      @class_name = options.model_class
      @primary_key = options.send(:primary_key)
      result = DBConnection.execute(<<-SQL).to_a.first
        SELECT
          #{options.table_name}.*
        FROM
          #{self.class.table_name}
        JOIN
          #{options.table_name}
        WHERE
          "#{self.send(options.send(:foreign_key))} IS NULL
            OR #{self.send(options.send(:foreign_key))}  = #{options.table_name}.#{@primary_key}"
      SQL
      return nil if result.nil?
      options.model_class.new(result)
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    self.assoc_options[name] = options
    define_method(name) do
      @foreign_key = options.send(:foreign_key)
      @class_name = options.model_class
      @primary_key = options.send(:primary_key)
      result = DBConnection.execute(<<-SQL)
        SELECT
          #{options.table_name}.*
        FROM
          #{options.table_name}
        WHERE
          #{options.table_name}.#{@foreign_key} = #{self.attributes[:id]}
      SQL
      final_results = []
      result.to_a.each do |result|
        final_results << options.model_class.new(result)
      end
      final_results
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_assoc_options = self.class.assoc_options[through_name]
      through_table = through_assoc_options.table_name
      through_primary_key  = through_assoc_options.primary_key
      through_foreign_key = through_assoc_options.foreign_key

      source_assoc_options = through_assoc_options.model_class.assoc_options[source_name]
      source_table = source_assoc_options.table_name
      source_primary_key = source_assoc_options.primary_key
      source_foreign_key = source_assoc_options.foreign_key

      key_value = self.send(through_foreign_key)
      results = DBConnection.execute(<<-SQL, key_value)
        SELECT
          #{source_table}.*
        FROM
          #{source_table}
        JOIN
          #{through_table}
        ON
          #{through_table}.#{source_foreign_key} = #{source_table}.#{source_primary_key}
        WHERE
          #{through_table}.#{through_primary_key} = ?
      SQL

      source_assoc_options.model_class.parse_all(results).first
    end
  end
end

class SQLObject
  extend Associatable
end
