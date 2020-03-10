# frozen_string_literal: true

module BoardHelper
  def move_wins_game?(move_index)
    # Get all the indexes necessary to check for a win
    win_scenarios(move_index + 1).each do |scenario|
      # Find the token values in each win scenario.
      # If all the tokens are not nil #compact
      # And all the tokens are for the same player #uniq.count == 1
      # Then the win scenario is true and that player has won the game!
      # This is essentially O(n) where n is the number of tokens in a row
      # needed to win the game.
      scenario_met = tokens_in_scenario(scenario).compact.uniq.count == 1
      return true if scenario_met
    end
    false
  end

  def tokens_in_scenario(scenario)
    scenario.map do |check_index|
      board[check_index]
    end
  end

  # Drop a token in the indicated column and update the board object
  def drop_token_in(column)
    # Get start and end indexes for the column in the board array
    start_index = column_start_index(column)
    end_index = start_index + rows - 1 # range operator is inclusive of the end_index

    (start_index..end_index) do |index|
      # skip until we find the first empty spot
      next unless board[index].nil?

      # insert token into spot for current player
      board[index] = current_player

      # no sense in going further. Return index
      return index
    end

    # If there are no empty spots, the move is invalid
    raise Game::ColumnFull
  end

  def column_start_index(column)
    # Board is a single array.
    # Find the starting index given the human readable column number

    (column - 1) * rows
  end
end

# Mimic a stack for each column
# 4 8 12 16
# 3 7 11 15
# 2 6 10 14
# 1 5 9  13

# This could be dynamically generated based on the columns and rows for each game, alternatively we could store it as a config.
# This is a naive implementation for simplicity's sake.
def win_scenarios(index)
  {
    "1" => {
      win_scenarios: [
        [2,3,4],
        [6, 11, 16],
        [5,9,13]
      ]
    },
    "2" => {
      win_scenarios: [
        [1,3,4],
        [6,10,14]
      ]
    }
    ,
    "3" => {
      win_scenarios: [
        [1,2,4],
        [7,11,15]
      ]
    },
    "4" => {
      win_scenarios: [
        [8,12,16],
        [1,2,3],
        [7,10,13]
      ]
    },
    "5" => {
      win_scenarios: [
        [1,9,13],
        [6,7,8]
      ]
    },
    "6" => {
      win_scenarios: [
        [5,7,8],
        [2,10,14]
      ]
    },
    "7" => {
      win_scenarios: [
        [5,6,8],
        [3,11,15]
      ]
    },
    "8" => {
      win_scenarios: [
        [5,6,7],
        [4,12,16]
      ]
    },
    "9" => {
      win_scenarios: [
        [1,5,13],
        [10,11,12]
      ]
    },
    "10" => {
      win_scenarios: [
        [9,11,12],
        [2,6,14]
      ]
    },
    "11" => {
      win_scenarios: [
        [9,10,12],
        [2,6,14]
      ]
    },
    "12" => {
      win_scenarios: [
        [9,10,11],
        [4,8,16]
      ]
    },
    "13" => {
      win_scenarios: [
        [1,5,9],
        [14,15,16],
        [4,7,10]
      ]
    },
    "14" => {
      win_scenarios: [
        [2,6,10],
        [13,15,16]
      ]
    },
    "15" => {
      win_scenarios: [
        [3,7,11],
        [13,14,16]
      ]
    },
    "16" => {
      win_scenarios: [
        [4,8,12],
        [1,6,11],
        [13,14,15]
      ]
    }
  }
end
