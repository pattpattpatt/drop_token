class Player < ApplicationRecord
  has_one :game
  has_many :moves
end
