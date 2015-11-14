class CreateKomatsuPrices < ActiveRecord::Migration
  def change
    create_table :komatsu_prices do |t|
      t.date :trading_date
      t.float :hajimene
      t.float :takane
      t.float :yasune
      t.float :owarine
      t.float :dekidaka

      t.timestamps null: false
    end
  end
end
