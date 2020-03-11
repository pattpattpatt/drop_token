# frozen_string_literal: true

class UuidValidator < Validator
  # Only allow UUIDs
  VALIDATION_REGEX = /\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b/
end
