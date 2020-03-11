# frozen_string_literal: true

class NonNegativeIntegerValidator < Validator
  # Only allow 1 or more digits
  VALIDATION_REGEX = /^\d+$/
end
