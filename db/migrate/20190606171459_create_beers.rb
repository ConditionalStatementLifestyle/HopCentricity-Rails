class CreateBeers < ActiveRecord::Migration[5.2]
  def change
    create_table :beers do |t|
      t.string :name
      t.string :style
      t.float :abv
      t.integer :ibu
      t.float :rating
      t.string :img_url
      t.integer :brewery_id
      t.timestamps
    end
  end
end
