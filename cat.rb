require_relative 'new_attr_accessor'

class Cat
  new_attr_accessor :name, :color

  def initialize(options = {})
    @name = options[:name]
    @color = options[:color]
  end

end

