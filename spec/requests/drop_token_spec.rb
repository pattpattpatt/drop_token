require 'rails_helper'

RSpec.describe "drop_token API", type: :request do
  describe "POST /drop_token" do
    let(:params) {
      {
        players: players,
        columns: columns,
        rows: rows
      }
    }
    let(:columns) { 4 }
    let(:rows) { 4 }
    let(:players) { ["player1", "player2"] }

    it "creates a game" do
      post '/drop_token', params: params
      expect(JSON.parse(response.body)).to eq({ "gameId" => Game.first.id })
      expect(response).to have_http_status(200)
      expect(Game.first.players).to match_array(players)
      expect(Game.first.columns).to eq columns
      expect(Game.first.rows).to eq rows
      expect(Game.first.board.size).to eq rows * columns
    end

    context "when players input is invalid" do
      context "when there are no players" do
        let(:players) { [] }
        let(:response_body) {
          {
            "error" => "Validation Error: players must be of type array_of_alphanumeric"
          }
        }
  
        it "raises a param required error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end
  
      context "when there are more than 2 players" do
        let(:players) { ["peter", "paul", "mary"] }
        let(:response_body) {
          {
            "error" => "Validation Error: players must be of type array_of_two_dissimilar_values"
          }
        }
  
        it "raises a validation error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end
  
      context "when there are less than 2 players" do
        let(:players) { ["peter"] }
        let(:response_body) {
          {
            "error" => "Validation Error: players must be of type array_of_two_dissimilar_values"
          }
        }
  
        it "raises a validation error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end
  
      context "when there are invalid player names" do
        let(:players) { ["bobby<"] }
        let(:response_body) {
          {
            "error" => "Validation Error: players must be of type array_of_alphanumeric"
          }
        }
  
        it "raises a validation error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end
  
      context "when players is not an array" do
        let(:players) { "some_bad_input!" }
        let(:response_body) {
          {
            "error" => "Validation Error: players must be of type array_of_alphanumeric"
          }
        }
  
        it "raises a validation error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end
    end
    
    context "when columns input is invalid" do
      context "when columns is not present" do
        let(:params) {
          {
            players: players,
            rows: rows
          }
        }
        let(:response_body) {
          {
            "error" => "param is missing or the value is empty: columns"
          }
        }
  
        it "raises a param required error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end

      context "when columns is not a positive value" do
        let(:columns) { -1 }
        let(:response_body) {
          {
            "error" => "Validation Error: columns must be of type positive_integer"
          }
        }
  
        it "raises a param required error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end

      context "when columns is not a valid integer" do
        let(:columns) { 5.0 }
        let(:response_body) {
          {
            "error" => "Validation Error: columns must be of type positive_integer"
          }
        }
  
        it "raises a param required error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end

      context "when columns is an array" do
        let(:columns) { [] }
        let(:response_body) {
          {
            "error" => "Validation Error: columns must be of type positive_integer"
          }
        }
  
        it "raises a param required error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end
    end

    context "when rows input is invalid" do
      context "when rows is not present" do
        let(:params) {
          {
            players: players,
            columns: columns
          }
        }
        let(:response_body) {
          {
            "error" => "param is missing or the value is empty: rows"
          }
        }
  
        it "raises a param required error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end

      context "when rows is not a positive value" do
        let(:rows) { -1 }
        let(:response_body) {
          {
            "error" => "Validation Error: rows must be of type positive_integer"
          }
        }
  
        it "raises a param required error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end

      context "when rows is not a valid integer" do
        let(:rows) { 5.0 }
        let(:response_body) {
          {
            "error" => "Validation Error: rows must be of type positive_integer"
          }
        }

        it "raises a param required error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end

      context "when rows is an array" do
        let(:rows) { [] }
        let(:response_body) {
          {
            "error" => "Validation Error: rows must be of type positive_integer"
          }
        }
  
        it "raises a param required error" do
          post '/drop_token', params: params
          expect(JSON.parse(response.body)).to eq response_body
          expect(response).to have_http_status(400)
        end
      end
    end
  end

  describe "GET /drop_token" do
    
  end

  describe "GET /drop_token/{gameId}" do
    
  end

  describe "GET /drop_token/{gameId}/moves" do
    
  end

  describe "POST /drop_token/{gameId}/{playerId}" do
    
  end

  describe "GET /drop_token/{gameId}/moves/{move_number}" do
    
  end

  describe "DELETE /drop_token/{gameId}/{playerId}" do
    
  end
end