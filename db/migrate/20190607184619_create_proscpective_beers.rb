class CreateProscpectiveBeers < ActiveRecord::Migration[5.2]
  def change
    create_table :proscpective_beers do |t|
      t.string :name
      t.string :style
      t.float :abv
      t.integer :ibu
      t.float :rating
      t.string :img_url
      t.string :brewery
      t.timestamps
    end
  end
end
