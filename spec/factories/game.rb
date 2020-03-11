FactoryBot.define do
  factory :game do
    players { ["player1", "player2"] }
    columns { 4 }
    rows { 4 }

    trait :with_full_column do
      after(:create) do |game|
        # fill the first column
        game.rows.times do |index|
          game.board[index] = game.players.first
        end
        game.save!
      end
    end

    trait :ready_for_win do
      after(:create) do |game|
        # pack all but the top row in the first column
        (game.rows - 1).times do |index|
          game.board[index] = game.players.first
        end
        game.save!
      end
    end

    trait :done do
      after(:create) do |game|
        game.finish_game
        game.save!
      end
    end

    trait :with_three_players do
      after(:create) do |game|
        game.players << "player3"
        game.save!
      end
    end
  end
end
