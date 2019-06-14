class Api::V1::BeerController < ApplicationController

    def search
        if params['type'] == 'beername'
            @beer_results = Beer.where("name like ?", "%#{params['query']}%")
              if @beer_results.empty?
                scraper = Scraper.new
                scraper.search_params = params['query']
                @beer_results = scraper.scrapeForNewBeer
            end
        elsif params['type'] == 'beertype'
            query = params['query'][6..-1]
            @beer_results = Beer.where("style like ?", "%#{query}%")
        else
            @beer_results = []
            brewery_matches = Brewery.where("name like ?", "%#{params['query']}%")
                brewery_matches.each do |brewery|
                    beers = Beer.where(brewery_id: brewery.id)
                    beers.each do |beer|
                        @beer_results << beer 
                    end 
                end 
        end
        # if @beer_results.empty?
            # scraper = Scraper.new
            # scraper.search_params = params['query']
            # @prospective_beers = scraper.scrapeForNewBeer
            # render json: @prospective_beers
        # end
        if @beer_results.length > 50 
            start_index = rand(@beer_results.length - 50)
            end_index = start_index + 49
            render json: @beer_results[start_index..end_index]
        else 
            render json: @beer_results
        end
    end 

    def create
        @beer = Beer.create_new(params)
        render json: @beer
    end
end
