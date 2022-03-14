class Base

    def self.inherited(subclass)
      subclass.column_names.each do |column_name|
        subclass.attr_accessor(column_name)
      end
    end
  
    def self.all
      table_name_is_valid!
      # makes sure the table name exists before we use it in a query
  
      rows = DB.execute("SELECT * from #{self.table_name}")
      rows.map do|row| 
        attributes = rows.reject {|k, v| k.is_a?(Integer)}
        self.new(attributes)
      end
      
    end
  
    def self.table_name
      self.name.tableize
      # converts string in upper camelcase (singular)
      # -> into a string in lower snake case (plural)
      # so we can interpolate it
    end
  
    def self.columns
      table_name_is_valid!
      DB.execute("PRAGMA table_info(#{self.table_name})").map do |column|
        {
          name: c["name"],
          type: c["type"]
        }
      end
    end
  
    def column_names
      self.columns.map{|column| c[:name]}
    end
  
  
  
    def initialize(row)
      row.each do |column_name, value|
        self.send("#{column_name}=", value)
      end
    end
  
    private
  
    # we need a method to raise an error if:
    # the table_name method returns something
    # that is not a table in our database
  
    def self.table_name_is_valid!
      raise StandardError.new("#{self.table_name} table does not exist") unless DB.execute
      ("SELECT * FROM sqlite_master WHERE type='table'").map {|t| t[1]}.include?(self.table_name)
  
      # gets all table names
      #     then checks if those names include the return value of table_name
      #     if there is a match we don't raise an exception
  
      # we call this method first ever time we:
      #     make a query where we interpolate the query_name into it
  
      # this is to make sure that we're 'sanititzing'
      #     i.e. make sure the table name exists before using it in a query
  
    end
  
  end
  
  
  
  class Dog < Base
  
  end  