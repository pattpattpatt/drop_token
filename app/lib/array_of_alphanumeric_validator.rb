# frozen_string_literal: true

class ArrayOfAlphanumericValidator < Validator
  VALIDATION_REGEX = /^[A-Za-z0-9]+$/

  # override default validator for custom implementation
  def validate!
    raise ValidationError unless value.is_a? Array
    value.each { |element| raise ValidationError unless element.match? VALIDATION_REGEX }
  end
end
