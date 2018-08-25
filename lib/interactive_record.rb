require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord


#creates a downcased, plural table name based on the Class name - abstraction
  def self.table_name
    self.to_s.downcase.pluralize
  end

#returns an array of SQL column names - from table already stored
  def self.column_names
    DB[:conn].results_as_hash = true # returns an array of hashes describing the table itself.

    sql = "pragma table_info('#{table_name}')"

      table_info = DB[:conn].execute(sql)
      column_names = []
      table_info.each do |row|
      column_names << row["name"] #iterate over the resulting array of hashes to collect just the name of each column
      end
    column_names.compact#get rid of any nil values
  end

  #creates new instance of student object from a hash of keys values pairs
  #creates instance with attributes using metaprogramming
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  #returns table name when called on an instnace of Student
  def table_name_for_insert
    self.class.table_name
  end

  #reuses the .column_names method  when called on an instance of Student for insert!
  #removes id column because we don't need it for insert
  #join puts the column names into comma separated list, contained in a string for SQL insert
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end


  #formats the column names to be used in a SQL statement
  #pushes the return value of invoking a method via the #send method, unless that value is nil
  #return value must be wrapped in ' '
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil? #send must act on the values
    end
    values.join(", ")#()"'Sam'", "'11'")
  end

  #saves the student to the db
  #sets the students id
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

#finds a row by name - table is abstracted so string interpolation is ok
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

#find a row by the attribute hash passed into the method
  def self.find_by(attribute_hash)
    value = attribute_hash.values.first
    key = attribute_hash.keys.first.to_s
    sql = "SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}'"
    DB[:conn].execute(sql)
  end

end
