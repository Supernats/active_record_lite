class MassObject

  # takes a list of attributes.
  # adds attributes to whitelist.
  def self.my_attr_accessible(*attributes)
    self.attributes.concat(attributes)
  end

  # takes a list of attributes.
  # makes getters and setters
  def self.my_attr_accessor(*attributes)
    attributes.each do |attribute|

      define_method(attribute) do
        self.instance_variable_get("@#{attribute}")
      end

      define_method("#{attribute}=") do |val|
        self.instance_variable_set("@#{attribute}", val)
      end

    end
    nil
  end

  # returns list of attributes that have been whitelisted.
  def self.attributes
    @attributes ||= []
  end

  # takes an array of hashes.
  # returns array of objects.
  def self.parse_all(results)
    objects = []
    results.each do |hash|
      objects << self.new(hash)
    end
    objects
  end

  # takes a hash of { attr_name => attr_val }.
  # checks the whitelist.
  # if the key (attr_name) is in the whitelist, the value (attr_val)
  # is assigned to the instance variable.
  def initialize(params = {})

    params.each do |attr_name, attr_value|
      attr_name = attr_name.to_sym if attr_name.is_a?(String)
      if self.class.attributes.include?(attr_name)
        self.send("#{attr_name}=", attr_value)
      else
        raise "mass assignment to unregistered attribute not_protected"
      end
    end

  end

end
