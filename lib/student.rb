require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

# inherits from InteractiveRecord class
class Student < InteractiveRecord

#creates attr_accessors for each column name
attr_accessor :id, :name, :grade



end
