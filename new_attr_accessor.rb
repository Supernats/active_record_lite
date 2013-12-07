class Object

  def new_attr_accessor(*args)
    args.each do |arg|
      self.send(:define_method, "#{arg}") do
        self.instance_variable_get(:@arg)
      end

      self.send(:define_method, "#{arg}=()") do
        self.instance_variable_set(:@arg, val)
      end
    end
    nil
  end

end