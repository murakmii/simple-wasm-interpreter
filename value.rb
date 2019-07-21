class Value
  attr_reader :type, :value

  # @param [Int] type
  # @param [Integer] value
  def initialize(type, value = nil)
    @type = type
    @value = @type.uninterpret(value || @type.default_value)
  end

  def assign(other_value)
    raise "Invalid value" if !other_value.is_a?(Value) || 
                             type != other_value.type

    @value = other_value.value
  end

  def inspect
    "#<#{self.class}(#{@type.inspect}) #{@value.inspect}>"
  end
end
