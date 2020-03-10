# frozen_string_literal: true

class Game < ApplicationRecord
  include BoardHelper

  ACTIVE_STATE = 'IN_PROGRESS'
  DONE_STATE = 'DONE'
  DEFAULT_MOVE_TYPE = 'MOVE'

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
  before_commit :update_game_state, on: :update

  def set_defaults
    self.state = ACTIVE_STATE

    # Create an empty board with the proper size
    self.board = Array.new(self.columns * self.rows)
    self.current_player = self.players.first
  end

  def update_game_state
    if self.players.size <= 1 || board_full?
      finish_game
    end
  end

  def board_full?
    # Return false if there are any nil elements.
    !self.board.any?(&:nil?)
  end

  def finish_game
    self.state = DONE_STATE
    set_winner
  end

  def set_winner
    self.winner = self.current_player
  end

  def make_move(column)
    # Roll back all changes unless all operations are successful!
    Game.transaction do
      moves << build_move(column, DEFAULT_MOVE_TYPE)
      move_index = drop_token_in(column)
      check_for_win(move_index)
      save!
    end
    moves.last
  end

  def check_for_win(move_index)
    finish_game if move_wins_game?(move_index) || board_full?
  end

  def current_move_number
    [moves.size - 1, 0].max
  end

  def build_move(column, move_type)
    {
      type: move_type,
      player: current_player,
      column: column
    }
  end

  def deactivate_player(player)
    raise GameIsDone if game_is_done?
    raise PlayerNotFound unless player_in_game?(player)

    Game.transaction do
      # remove player from players array
      self.players -= [player]
      set_next_turn
      save!
    end
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
