# frozen_string_literal: true

class Game < ApplicationRecord
  include BoardHelper

  ACTIVE_STATE = 'IN_PROGRESS'
  DONE_STATE = 'DONE'
  DEFAULT_MOVE_TYPE = 'MOVE'
  DEACTIVATE_PLAYER_MOVE_TYPE = 'QUIT'
  # Extend the standard error class for implicit message codes
  class GameError < StandardError
    def message
      @message ||= self.class.name.to_s.split('::').last.underscore
    end
  end

  InvalidColumn = Class.new(GameError)
  InvalidPlayer = Class.new(GameError)
  NotYoTurn = Class.new(GameError)
  GameIsDone = Class.new(GameError)
  PlayerNotFound = Class.new(GameError)
  ColumnFull = Class.new(GameError)

  before_create :set_defaults

  def set_defaults
    self.state = ACTIVE_STATE

    # Create an empty board with the proper size
    self.board = Array.new(self.columns * self.rows)
    self.current_player = self.players.first
  end

  def not_enough_players?
    self.players.size <= 1
  end

  def board_full?
    # Return false if there are any empty elements.
    !self.board.any?(&:nil?)
  end

  def finish_game
    self.state = DONE_STATE
  end

  def set_winner
    self.winner = self.current_player
    finish_game
  end

  def make_move(column, player)
    # Roll back all changes unless all operations are successful!
    Game.transaction do
      moves << build_move(DEFAULT_MOVE_TYPE, column)
      move_token_index = drop_token_in(column)
      game_won = check_for_win(move_token_index)

      # no need to set the next turn if the game is done!
      set_next_turn unless game_won
      save!
    end
    moves.last
  end

  def validate_move!(column, player)
    raise GameIsDone if game_is_done?
    raise InvalidColumn if column <= 0 || column > columns
    raise InvalidPlayer unless player_in_game?(player)
    raise NotYoTurn unless player == current_player
  end

  def check_for_win(move_index)
    set_winner if move_wins_game?(move_index) || board_full?
  end

  def current_move_number
    # Get the current move number indexed from 0
    [moves.size - 1, 0].max
  end

  def build_move(move_type, column=nil)
    # This defines the move JSON structure stored in the database
    move = {
      type: move_type,
      player: current_player
    }
    column.nil? ? move : move.merge(column: column)
  end

  def deactivate_player(player)
    raise GameIsDone if game_is_done?
    raise PlayerNotFound unless player_in_game?(player)

    moves << build_move(DEACTIVATE_PLAYER_MOVE_TYPE)

    # remove player from players array
    self.players -= [player]

    # make the last player the current player
    set_next_turn

    # If there are less than 2 players, the last player wins
    set_winner if not_enough_players?
    save!
  end

  def player_in_game?(player)
    self.players.include?(player)
  end

  def game_is_done?
    self.state == DONE_STATE
  end

  def set_next_turn
    self.current_player = next_player
  end

  def next_player
    (self.players - [current_player]).first
  end
end
