# frozen_string_literal: true

# game board
# {
#   1: {
#     player_id: 1,
#     win_scenarios: [
#       [2,3,4],
#       [6,11,16],
#       [5,9,13]
#     ]
#   }, ..16
# }

# 1  2  3  4
# 5  6  7  8
# 9  10 11 12
# 13 14 15 16

class GameChecker
  attr_accessor :board
  def initialize(game)
    @board = game.board
  end

  def move_wins_game?(move)
    # If all of the indexes in one of the three possible win scenarios
    # Contain the player_id, then the player has won the game

    board[move.index][:win_scenarios].each do |scenario|
      scenario_met = scenario.all? do |index|
                       board[index][:player_id] == move.player_id ? true : false
                     end
      return true if scenario_met
    end
    false
  end
end
