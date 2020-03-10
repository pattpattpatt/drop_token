class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games, id: :uuid do |t|
      t.uuid :winner
      t.string :board, array: true
      t.text :players, array: true
      t.jsonb :moves, array: true, default: []
      t.string :current_player
      t.string :state
      t.integer :columns
      t.integer :rows
      t.timestamps
    end
  end
end
