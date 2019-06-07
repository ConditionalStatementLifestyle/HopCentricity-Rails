class AddRelativePathToScraper < ActiveRecord::Migration[5.2]
  def change
    add_column :scrapers, :relative_path, :string
  end
end
