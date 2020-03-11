require 'rails_helper'

RSpec.describe Game do
  describe '#set_defaults' do
    let(:game) { build(:game) }

    it 'sets the state to the default state' do
      game.set_defaults
      expect(game.state).to eq Game::ACTIVE_STATE
    end

    it 'creates the board' do
      game.set_defaults
      expect(game.board).to match_array(Array.new(game.columns * game.rows))
    end

    it "sets the current player" do
      game.set_defaults
      expect(game.current_player).to eq game.players.first
    end
  end

  describe '#board_full?' do
    context "when the board is full" do
      let(:game) { create(:game) }

      before do
        game.board = ["hi"]
        game.save!
      end

      it "returns true" do
        expect(game.board_full?).to eq true
      end
    end

    context "when the board is not full" do
      let(:game) { create(:game) }

      it "returns false" do
        expect(game.board_full?).to eq false
      end
    end
  end

  describe "#finish_game" do
    let(:game) { create(:game) }

    it "sets the state to done" do
      game.finish_game
      expect(game.state).to eq Game::DONE_STATE
    end
  end

  describe "#set_winner" do
    let(:game) { create(:game) }

    before do
      allow(game).to receive(:finish_game)
    end

    it "sets the winner to the current player" do
      game.set_winner
      expect(game.winner).to eq game.current_player
    end

    it "finishes the game" do
      expect(game).to receive(:finish_game)
      game.set_winner
    end
  end

  describe "#make_move" do
    let(:player) { game.players.first }

    context "when the column is full" do
      let(:game) { create(:game, :with_full_column) }

      it "raises a ColumnFull error" do
        expect { game.make_move(1, player) }.to raise_error(Game::ColumnFull)
      end

      it "does not add a move" do
        expect { game.make_move(1, player) }.to raise_error(Game::ColumnFull)
        expect(game.reload.moves).to match_array []
      end

      it "does not update the game state" do
        state = game.state
        expect { game.make_move(1, player) }.to raise_error(Game::ColumnFull)
        expect(game.reload.state).to eq state
      end
    end

    context "when the column is not full" do
      let(:game) { create(:game) }
      let(:column) { 3 }
      let(:token_index) { (column - 1) * game.rows }

      it "drops the token to the correct index" do
        game.make_move(column, player)
        expect(game.reload.board[token_index]).to eq game.players.first
      end

      it "updates the current_player" do
        current_player = game.current_player
        game.make_move(column, player)
        expect(game.reload.current_player).to eq game.players.second
      end

      context "when the move wins the game" do
        let(:game) { create(:game, :ready_for_win) }

        it "sets the winner" do
          expect(game.winner).to be_nil
          game.make_move(1, player)
          expect(game.reload.winner).to eq game.players.first
        end

        it "does not update the current player" do
          game.make_move(column, player)
          expect(game.reload.current_player).to eq game.players.first
        end
      end
    end
  end

  describe "#validate_move!" do
    let(:game) { create(:game) }
    let(:column) { 1 }
    let(:player) { game.players.first }

    context "when the game is done" do
      let(:game) { create(:game, :done) }

      it "raises a GameIsDone error" do
        expect { game.validate_move!(column, player) }.to raise_error(Game::GameIsDone)
      end
    end

    context "when the column is invalid" do
      context "when the column is zero" do
        let(:column) { 0 }

        it "raises a InvalidColumn error" do
          expect { game.validate_move!(column, player) }.to raise_error(Game::InvalidColumn)
        end
      end

      context "when the column is > the number of columns" do
        let(:column) { game.columns + 1 }

        it "raises a InvalidColumn error" do
          expect { game.validate_move!(column, player) }.to raise_error(Game::InvalidColumn)
        end
      end
    end

    context "when it is not the players turn" do
      let(:player) { game.players.last }

      it "raises a NotYoTurn error" do
        expect { game.validate_move!(column, player) }.to raise_error(Game::NotYoTurn)
      end
    end

    context "when the player is not in the game" do
      let(:player) { "bilbo baggins" }

      it "raises a InvalidPlayer error" do
        expect { game.validate_move!(column, player) }.to raise_error(Game::InvalidPlayer)
      end
    end
  end

  describe "#deactivate_player" do
    let(:game) { create(:game) }
    let(:player) { game.players.first }

    context "when the game is done" do
      let(:game) { create(:game, :done) }

      it "raises a GameIsDone error" do
        expect { game.deactivate_player(player) }.to raise_error(Game::GameIsDone)
      end
    end

    context "when the player is not part of the game" do
      let(:player) { "bilbo baggins" }

      it "raises a PlayerNotFound error" do
        expect { game.deactivate_player(player) }.to raise_error(Game::PlayerNotFound)
      end
    end

    it "removes the player from the game" do
      game.deactivate_player(player)
      expect(game.reload.players.include? player).to eq false
    end

    it "makes the remaining player the current player" do
      second_player = game.players.second
      game.deactivate_player(player)
      expect(game.reload.current_player).to eq second_player
    end

    it "adds a quit move" do
      game.deactivate_player(player)
      expect(game.reload.moves.last).to eq({ "type" => Game::DEACTIVATE_PLAYER_MOVE_TYPE, "player" => player})
    end

    context "when there is only one remaining player" do
      it "makes the remaining player the winner" do
        second_player = game.players.second
        game.deactivate_player(player)
        expect(game.reload.winner).to eq second_player
      end
    end

    context "when there is more than one remaining player" do
      let(:game) { create(:game, :with_three_players) }

      it "does not set a winner" do
        second_player = game.players.second
        game.deactivate_player(player)
        expect(game.reload.winner).to be_nil
      end
    end
  end
end