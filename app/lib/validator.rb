class Validator
  attr_accessor :value

  ValidationError = Class.new(StandardError)

  def initialize(value)
    @value = value
  end

  def validate!
    # General string matching case. Extensible for array and other matching values
    raise ValidationError unless value.is_a? String
    raise ValidationError unless value.match? self.class::VALIDATION_REGEX
  end
end
