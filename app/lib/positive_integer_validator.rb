# frozen_string_literal: true

class PositiveIntegerValidator < Validator
  # Only allow single numeric values
  VALIDATION_REGEX = /^[1-9]$/
end
