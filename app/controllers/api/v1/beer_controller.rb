class Api::V1::BeerController < ApplicationController

    def search
        @beer_results = Beer.where("name like ?", "%#{params['query']}%")
        # if @beer_results.empty?
            # scraper = Scraper.new
            # scraper.search_params = params['query']
            # @prospective_beers = scraper.scrapeForNewBeer
        end
        render json: @prospective_beers
    end 

    def create
        @beer = Beer.create_new(params)
        render json: @beer
    end
end
 