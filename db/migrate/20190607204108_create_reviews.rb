class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.float :rating
      t.string :content
      t.integer :user_id
      t.integer :beer_id
      t.timestamps
    end
  end
end
