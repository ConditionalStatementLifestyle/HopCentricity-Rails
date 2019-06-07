class ChangeScraperUrlToSearchParams < ActiveRecord::Migration[5.2]
  def change
    rename_column :scrapers, :url, :search_params
  end
end
