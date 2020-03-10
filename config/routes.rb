Rails.application.routes.draw do
  get  'drop_token',                                to: 'drop_token#get_games'
  post 'drop_token',                                to: 'drop_token#new'
  get  'drop_token/:game_id',                       to: 'drop_token#get_game'
  post 'drop_token/:game_id/:player_id',            to: 'drop_token#make_move'
  get  'drop_token/:game_id/moves/:move_number',    to: 'drop_token#get_move'
  delete  'drop_token/:game_id/:player_id',         to: 'drop_token#deactivate_player'
end
