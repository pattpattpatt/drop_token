class DropTokenController < ApplicationController
  GAME_NOT_FOUND_ERROR = 'game_not_found'

  attr_accessor :game

  # POST /drop_token
  # Params
  # {
  #   "players": ["player1", "player2"],
  #   "columns": 4,
  #   "rows": 4
  # }
  # Output:
  # { "gameId": "some_string_token"}
  # Status codes
  # • 200 - OK. On success
  # • 400 - Malformed request
  def new
    game = Game.create!(params.permit(:columns, :rows).merge(players: JSON.parse(params[:players])))
    render json: { gameId: game.id }
  end

  # GET /drop_token
  # Response
  # { "games" : ["gameid1", "gameid2"] }
  # Status codes
  # • 200 - OK. On success
  def get_games
    # pluck only selects the id column
    game_ids = Game.all.pluck(:id)
    render json: { games: game_ids }
  end

  # GET /drop_token/{gameId}
  # Response:
  # {
  #   "players" : ["player1", "player2"], # Initial list of players.
  #   "state": "DONE/IN_PROGRESS", # in case of draw, winner will be null, state will be DONE.
  #   "winner": "player1", # in case game is still in progess, key should not exist.
  # }
  # Status codes
  # • 200 - OK. On success
  # • 400 - Malformed request
  # • 404 - Game/moves not found.
  def get_game
    game = Game.find params[:game_id]
    response = {
      players: game.players,
      state: game.state
    }
    response.merge!(winner: game.winner) if game.winner.present?
    render json: response
  rescue ActiveRecord::RecordNotFound
    render json: { code: 'GAME_NOT_FOUND' }, status: 404
  rescue
    render json: { code: 'BAD_REQUEST' }, status: 400
  end

  #  GET /drop_token/{gameId}/moves
  # Optional Query parameters: GET /drop_token/{gameId}/moves?start=0&until=1.
  # Output:
  # {
  #   "moves": [
  #     {"type": "MOVE", "player": "player1", "column":1},
  #     {"type": "QUIT", "player": "player2"}
  #   ]
  # }
  # Status codes
  # • 200 - OK. On success
  # • 400 - Malformed request
  # • 404 - Game/moves not found
  def get_moves
    render json: { moves: game.moves(params[:start]..params[:until]) }
  rescue ActiveRecord::RecordNotFound
    render json: { code: 'GAME_NOT_FOUND' }, status: 404
  end

  # POST /drop_token/{gameId}/{playerId}
  # Params
  # {
  #   "column" : 2
  # }
  # Response Body:
  # {
  #   "move": "{gameId}/moves/{move_number}"
  # }
  # Status codes
  # • 200 - OK. On success
  # • 400 - Malformed input. Illegal move
  # • 404 - Game not found or player is not a part of it.
  # • 409 - Player tried to post when it’s not their turn.
  def make_move
    with_game(with_lock: true) do
      raise Game::InvalidColumn if params[:column] <= 0 || params[:column] > game.columns
      game.make_move(params[:column])
      render json: { move: "#{game.id}/moves/#{game.current_move_number}" }
    end
  rescue Game::InvalidColumn => e
    render json: { code: e.message }, status: 400
  rescue Game::InvalidPlayer => e
    render json: { code: e.message }, status: 404
  rescue Game::NotYoTurn => e
    render json: { code: e.message }, status: 409
  rescue Game::ColumnFull => e
    render json: { code: e.message }, status: 400
  end

  # GET /drop_token/{gameId}/moves/{move_number}
  # Output:
  # {
  #   "type" : "MOVE",
  #   "player": "player1",
  #   "column": 2
  # }
  # Status codes
  # • 200 - OK. On success
  # • 400 - Malformed request
  # • 404 - Game/moves not found.
  def get_move
    with_game do
      render json: game.moves[params[:move_number].to_i]
    end
  end

  # DELETE /drop_token/{gameId}/{playerId}
  # Status codes
  # • 202 - OK. On success
  # • 404 - Game not found or player is not a part of it.
  # • 410 - Game is already in DONE state.
  def deactivate_player
    with_game(with_lock: true) do
      game.deactivate_player(params[:player_id])
    end
    render json: {}, status: 202
  rescue Game::GameIsDone => e
    render json: { code: e.message }, status: 410
  rescue Game::PlayerNotFound => e
    render json: { code: e.message }, status: 404
  end

  private

  def with_game(with_lock: false)
    # Find game by ID and assign to instance variable
    @game = Game.find params[:game_id]
    @game.lock! if with_lock

    # execute the given block of code
    yield
  rescue ActiveRecord::RecordNotFound
    render json: {}, status: 404
  end
end