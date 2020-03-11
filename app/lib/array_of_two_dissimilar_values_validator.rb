# frozen_string_literal: true

class ArrayOfTwoDissimilarValuesValidator < Validator
  VALIDATION_REGEX = /^[A-Za-z0-9]+$/

  # override default validator for custom implementation
  def validate!
    raise ValidationError unless value.is_a? Array

    #ensure there are 2 distinct players
    raise ValidationError unless value.compact.uniq.count == 2
  end
end
