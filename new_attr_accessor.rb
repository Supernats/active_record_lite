class Class

  def new_attr_accessor(*attributes)
    attributes.each do |attribute|
      puts "ATTRIBUTE: "
      p attribute

      self.send(:define_method, "#{attribute}") do
        self.instance_variable_get("@#{attribute.to_s}")
      end

      self.send(:define_method, "#{attribute}=") do |val|
        self.instance_variable_set("@#{attribute.to_s}", val)
      end

    end
    nil
  end

end